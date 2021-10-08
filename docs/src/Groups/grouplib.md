```@meta
CurrentModule = Oscar
DocTestSetup = quote
  using Oscar
end
```

```@setup oscar
using Oscar
```

```@contents
Pages = ["grouplib.md"]
```

# Group libraries

## Transitive permutation groups of small degree

TODO: explain about the scope of this.

TODO: give proper attribution to the transgrp package (in particular, cite it)

The arrangement and the names of the groups of degree up to 15 is the same as given in
[CHM98](@cite). With the exception of the symmetric and alternating group (which are represented
as `SymmetricGroup` and `AlternatingGroup`) the generators for these groups also conform to this paper with
the only difference that 0 (which is not permitted in GAP for permutations to act on) is always replaced by
the degree.

The arrangement for all degrees is intended to be equal to the arangement within the systems GAP and Magma, thus it
should be safe to refer to particular (classes of) groups by their index numbers.


```@docs
transitive_groups_available
number_transitive_groups
transitive_group
transitive_identification
all_transitive_groups
```

## Primitive permutation groups of small degree

TODO: explain about the scope of this.

TODO: give proper attribution to the primitive groups library (in particular, cite it)

```@docs
number_primitive_groups
primitive_group
all_primitive_groups
```

## Perfect groups of small order

TODO: explain about the scope of this.

TODO: give proper attribution to the perfect groups library in GAP and its recent extensions (in particular, cite it)

```@docs
number_perfect_groups
perfect_group
perfect_identification
```

## Groups of small order

TODO: explain about the scope of this.

TODO: give proper attribution to the smallgrp package and other things used (in particular, cite it)

```@docs
number_small_groups
small_group
small_group_identification
all_small_groups
```
