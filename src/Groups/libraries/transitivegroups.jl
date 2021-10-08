export
    all_transitive_groups,
    number_transitive_groups,
    transitive_groups_available,
    transitive_group,
    transitive_identification


"""
    transitive_groups_available(deg::Int)

Return whether the transitive groups groups of degree `deg` are available for use.
This function should be used to test for the scope of the library available.
"""
transitive_groups_available(deg::Int) = GAP.Globals.TransitiveGroupsAvailable(deg)::Bool


"""
    number_transitive_groups(deg::Int)

Return the number of transitive groups of degree `deg` stored in the library of transitive groups. The
function returns `missing` if `deg` is beyond the range of the library.
"""
function number_transitive_groups(deg::Int)
   res = GAP.Globals.NrTransitiveGroups(deg)
   res isa Int && return res
   return missing
end

"""
    transitive_group(deg::Int, i::Int)

Return the `i`-th group in the catalogue of transitive groups over the set
`{1, ..., deg}` in GAP's Transitive Groups Library.
The output is a group of type `PermGroup`.
"""
function transitive_group(deg::Int, n::Int)
   transitive_groups_available(deg) || error("Transitive groups of degree $(deg) are not available")
   N = number_transitive_groups(deg)
   @assert n <= N "There are only $N transitive groups of degree $deg, up to permutation isomorphism."

   return PermGroup(GAP.Globals.TransitiveGroup(deg,n), deg)
end

"""
    transitive_identification(G::PermGroup)

Return `m` such that `G` is permutation isomorphic with
`transitive_group(d, m)`, where `G` is transitive on `d` points,
with `d < 32`.

If `G` moves more than 31 points then `-1` is returned.
Otherwise, if `G` is not transitive on its moved points then `0` is returned,

# Examples
```jldoctest
julia> G = symmetric_group(7);  m = transitive_identification(G)
7

julia> order(transitive_group(7, m)) == order(G)
true

julia> S = sub(G, [gap_perm([1, 3, 4, 5, 2])])[1]
Group([ (2,3,4,5) ])

julia> istransitive(S)
false

julia> istransitive(S, moved_points(S))
true

julia> m = transitive_identification(S)
1

julia> order(transitive_group(4, m)) == order(S)
true

julia> transitive_identification(symmetric_group(32))
-1

julia> S = sub(G, [gap_perm([1,3,4,5,2,7,6])])[1];

julia> istransitive(S, moved_points(S))
false

julia> transitive_identification(S)
0
```
"""
function transitive_identification(G::PermGroup)
  deg = degree(G)
  moved = moved_points(G)
# TODO: fix docu
  istransitive(G, moved) || error("group is not transitive")
  transitive_groups_available(deg) || error("Transitive groups of degree $(deg) are not available")
  return GAP.Globals.TransitiveIdentification(G.X)::Int
end

"""
    all_transitive_groups(L...)

Return the list of all transitive groups (up to permutation isomorphism)
satisfying the conditions in `L`.
Here, `L` is a vector whose arguments are organized as `L` = [ `func1`,
`arg1`, `func2`, `arg2`, ... ], and the function returns all the groups `G`
satisfying the conditions `func1`(`G`) = `arg1`, `func2`(`G`) = `arg2`, etc.
An argument can be omitted if it corresponds to the boolean value `true`.

TODO: specify which predicates are supported
# TODO: allow specifying !isabelian?

# Examples
```jldoctest
julia> all_transitive_groups(degree, 4, isabelian)
2-element Vector{PermGroup}:
 C(4) = 4
 E(4) = 2[x]2
```
returns the list of all abelian transitive groups acting on a set of order 4.

The type of the groups is `PermGroup`.
"""
function all_transitive_groups(L...)
   gapargs = translate_group_library_args(L; permgroups=true)
   K = GAP.Globals.AllTransitiveGroups(gapargs...)
   return [PermGroup(x) for x in K]
end

