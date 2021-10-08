include("perfectgroups.jl")
include("primitivegroups.jl")
include("smallgroups.jl")
include("transitivegroups.jl")

#############################################################################

# useful methods for all functions of type all_"property"_groups

#############################################################################

const _group_props = Dict{Any,GapObj}()
const _group_props_neg = Dict{Any,GapObj}()

function __init_group_libraries()
    props = [
        isabelian => GAP.Globals.IsAbelian,
        isalmostsimple => GAP.Globals.IsAlmostSimpleGroup,
        iscyclic => GAP.Globals.IsCyclic,
        isnilpotent => GAP.Globals.IsNilpotentGroup,
        isperfect => GAP.Globals.IsPerfectGroup,
        issimple => GAP.Globals.IsSimpleGroup,
        issolvable => GAP.Globals.IsSolvableGroup,
        issupersolvable => GAP.Globals.IsSupersolvableGroup,
    ]

    empty!(_group_props)
    push!(_group_props, props...)

    empty!(_group_props_neg)
    for (k, v) in props
        _group_props_neg[!k] = v
    end
end

# return the output of the function f and the corresponding GAP function
# TODO: use @nospecialize???
function find_index_function(f, permgroups::Bool)

   haskey(_group_props, f) && return Bool, _group_props[f], true
   haskey(_group_props_neg, f) && return Bool, _group_props_neg[f], false

   f == order && return Union{Int, AbstractVector{Int}}, GAP.Globals.Size, nothing

   if permgroups
      if f == istransitive return Bool, GAP.Globals.IsTransitive, true
      elseif f == !istransitive return Bool, GAP.Globals.IsTransitive, false
      elseif f == isprimitive return Bool, GAP.Globals.IsPrimitive, true
      elseif f == !isprimitive return Bool, GAP.Globals.IsPrimitive, false
      elseif (f == number_moved_points || f == degree)
         return Union{Int, AbstractVector{Int}}, GAP.Globals.NrMovedPoints, nothing
      elseif f == transitivity
         return Union{Int, AbstractVector{Int}}, GAP.Globals.Transitivity, nothing
      end
   end
   throw(ArgumentError("Function not supported"))
end

# check whether the input of all_small_group is valid (see below)
function translate_group_library_args(args::Tuple; permgroups::Bool=false)
   gapargs = []
   i = 1
   while i <= length(args)
      arg = args[i]
      if arg isa Pair
         # handle e.g. `isabelian => false`
         func = arg[1]
         data = arg[2]
         i += 1
         expected_type, gapfunc, _ = find_index_function(func, permgroups)
         if data isa expected_type
            push!(gapargs, gapfunc, GAP.Obj(data))
         else
            throw(ArgumentError("bad argument $(arg[2]) for function $(func)"))
         end
      elseif arg isa Function
         # handle e.g. `isabelian` or `isabelian, false`
         func = arg
         expected_type, gapfunc, default = find_index_function(func, permgroups)
         i += 1
         if i <= length(args) && args[i] isa expected_type
            push!(gapargs, gapfunc, GAP.Obj(args[i]))
            i += 1
         elseif default !== nothing
            # no argument given: default to `true`
            push!(gapargs, gapfunc, default)
         else
            if i <= length(args)
               throw(ArgumentError("bad argument $(args[i]) for function $(func)"))
            else
               throw(ArgumentError("missing argument for function $(func)"))
            end
         end
      else
         throw(ArgumentError("expected a function or a pair, got $arg"))
      end
   end
   
   return gapargs
end

