###
# Computing (tropical) Groebner polyhedra in Oscar
# ================================================
#
# For a definition of tropical Groebner cones see Section 2.5 in:
#   D. Maclagan, B. Sturmfels: Introduction to tropical geometry
# To see how they can be computed using standard bases see:
#   T. Markwig, Y. Ren: Computing tropical varieties over fields with valuation
###


#=======
tropical Groebner polyhedron
todo: proper documentation
Example:

val_2 = TropicalSemiringMap(QQ,2)
Kx,(x,y,z) = PolynomialRing(QQ,3)
w = [0,0,0]
I = ideal([x+2*y,y+2*z])
groebner_polyhedron(I,val_2,w)

Kt,t = RationalFunctionField(QQ,"t")
val_t = TropicalSemiringMap(Kt,t)
Ktx,(x,y,z) = PolynomialRing(Kt,3)
w = [0,0,0]
I = ideal([x+t*y,y+t*z])
groebner_polyhedron(I,val_t,w)
=======#
function groebner_polyhedron(I,val::TropicalSemiringMap{K,p} where {K,p},w::Vector{Int})
  GB,LI = groebner_basis(I,val,w,complete_reduction=true,return_lead=true)

  return groebner_polyhedron(GB,val,w,pertubation=pertubation,skip_reduction=skip_reduction)
end

function groebner_polyhedron(GB::Vector{<:MPolyElem}, val::TropicalSemiringMap, w::Vector; pertubation::Vector=[], skip_reduction::Bool=false)
  if !skip_reduction
    GB = interreduce_tropically(GB,val,w,pertubation=pertubation)
  end

  return groebner_polyhedron(GB,val,w,pertubation=pertubation,skip_reduction=skip_reduction)
end

function groebner_polyhedron(GB::Vector{<:MPolyElem}, val::ValuationMap, w::Vector; pertubation::Vector=[], skip_reduction::Bool=false)
  if !skip_reduction
    GB = interreduce_tropically(GB,val,w,pertubation=pertubation)
  end
  # println("============================== inside groebner_polyhedron")
  # display(GB)
  # display(w)
  # display(initial(GB,val,w,pertubation=pertubation))

  return groebner_polyhedron(GB,initial(GB,val,w,pertubation=pertubation),val)
end

function groebner_polyhedron(GB::Vector{<:MPolyElem}, inGB::Vector{<:MPolyElem}, val::TropicalSemiringMap) # GB entries can be MPolyElem and fmpq_mpoly
  eq_lhs = zeros(Int,0,nvars(parent(GB[1])))
  eq_rhs = zeros(Int,0)
  ineq_lhs = zeros(Int,0,nvars(parent(GB[1])))
  ineq_rhs = zeros(Int,0)

  for (f,inf) in zip(GB,inGB)
    ###
    # Step 0: collect the coefficients and exponent vectors of f
    ###
    coefficients_f = collect(coefficients(f))
    exponent_vectors_f = collect(exponent_vectors(f))

    ###
    # Step 1: construct weight equations enforcing that valued weighted degrees
    # of inf are the same
    ###
    inf_leadexpv,inf_tailexpvs = Iterators.peel(exponent_vectors(inf))
    i = findfirst(isequal(inf_leadexpv),exponent_vectors_f)
    if i===nothing
      println(GB)
      println(inGB)
      error("initial forms have monomials which original polynomials do not")
    end
    inf_leadval = Int(val(coefficients_f[i]))                    # +/- val depending on min/max-convention
    # println("============================== inside groebner_polyhedron")
    # println("coefficients_f[i]: ",coefficients_f[i]," Int(val(coefficients_f[i])): ",Int(val(coefficients_f[i])));

    for inf_tailexpv in inf_tailexpvs
      i = findfirst(isequal(inf_tailexpv),exponent_vectors_f)
      if i===nothing
        println(GB)
        println(inGB)
        error("initial forms have monomials which original polynomials do not")
      end
      inf_tailval = Int(val(coefficients_f[i]))                  # +/- val depending on min/max-convention
      # println("coefficients_f[i]: ",coefficients_f[i]," Int(val(coefficients_f[i])): ",Int(val(coefficients_f[i])));
      eq_lhs = vcat(eq_lhs,transpose(inf_leadexpv-inf_tailexpv)) # LHS: leadexpv - tailexpv
      push!(eq_rhs,inf_tailval-inf_leadval)                      # RHS: +/- tailval -/+ leadval
    end                                                          # LHS=RHS <=> leadexpv +/- leadval = tailexpv +/- tailval

    ###
    # Step 2: construct weight inequalities enforcing that valued weighted
    # degree of inf is greater equal f
    ###
    for (f_coeff,f_expv) in zip(coefficients(f),exponent_vectors(f))
      f_val = Int(val(f_coeff))                                # +/- val depending on min/max-convention
      # println("f_coeff: ",f_coeff," Int(val(f_coeff)): ",Int(val(f_coeff)))
      ineq_lhs = vcat(ineq_lhs,transpose(inf_leadexpv-f_expv)) # LHS: leadexpv - tailexpv
      push!(ineq_rhs,f_val-inf_leadval)                        # RHS: +/- tailval -/+ leadval
    end                                                        # LHS<RHS <=> leadexpv +/- leadval < tailexpv +/- tailval
  end

  if convention(val)==max # min-convention: leadexpv +/- leadval < tailexpv +/- tailval (as above)
    ineq_lhs *= -1        # max-convention: tailexpv +/- tailval > leadexpv +/- leadval (multiplied by -1)
    ineq_rhs *= -1
  end

  # println("============================== inside groebner_polyhedron")
  # display(GB)
  # display(inGB)
  # display(ineq_lhs)
  # display(ineq_rhs)
  # display(eq_lhs)
  # display(eq_rhs)
  return Polyhedron((ineq_lhs,ineq_rhs),(eq_lhs,eq_rhs))
end
export groebner_polyhedron
