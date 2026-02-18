# Calculate row and column from well name.

Calculate row and column from well name.

## Usage

``` r
rowcol_from_well(well, format)
```

## Arguments

- well:

  A character vector with the standard well names

- format:

  A single element character or numeric vector with the format of the
  plate

## Value

A list with two elements: row and col

## Examples

``` r
rowcol_from_well(c("A1", "B2", "C3", NA), 48)
#> # A tibble: 4 × 2
#>   row     col
#>   <fct> <int>
#> 1 A         1
#> 2 B         2
#> 3 C         3
#> 4 NA       NA
# The order is preserved
rowcol_from_well(c("H12", "A1"), 96)
#> # A tibble: 2 × 2
#>   row     col
#>   <fct> <int>
#> 1 H        12
#> 2 A         1
```
