export
    all_primitive_groups,
    number_primitive_groups,
    primitive_group


# TODO: use PrimitiveGroupsAvailable

###################################################################
# Primitive groups, block system
###################################################################
"""
    number_primitive_groups(n::Int)

Return the number of primitive permutation groups of degree `n`,
up to permutation isomorphism.
"""
number_primitive_groups(n::Int) = GAP.Globals.NrPrimitiveGroups(n)::GapInt

"""
    primitive_group(deg::Int, i::Int)

Return the `i`-th group in the catalogue of primitive groups over the set
{`1`,...,`deg`} in the GAP Small Groups Library. The output is a group of type
``PermGroup``.
"""
function primitive_group(deg::Int, n::Int)
   N = number_primitive_groups(deg)
   @assert n <= N "There are only $N primitive groups of degree $deg."
   return PermGroup(GAP.Globals.PrimitiveGroup(deg,n), deg)
end

"""
    all_primitive_groups(L...)

Return the list of all primitive groups (up to permutation isomorphism)
satisfying the conditions in `L`.
Here, `L` is a vector whose arguments are organized as
`L` = [ `func1`, `arg1`, `func2`, `arg2`, ... ],
and the function returns all the groups `G` satisfying the conditions
`func1(G) == arg1`, `func2(G) == arg2`, etc.
An argument can be omitted if it corresponds to the boolean value `true`.

# Examples
```jldoctest
julia> all_primitive_groups(degree, 4, isabelian)
PermGroup[]
```
returns the list of all abelian primitive groups acting on a set of order 4.

The type of the groups is `PermGroup`.
"""
function all_primitive_groups(L...)
   !isempty(L) || throw(ArgumentError("must specify at least one filter"))
   gapargs = translate_group_library_args(L; permgroups=true)
   K = GAP.Globals.AllPrimitiveGroups(gapargs...)
   return [PermGroup(x) for x in K]
end
