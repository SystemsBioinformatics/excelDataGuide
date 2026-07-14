# Try to parse a string with a potential series of wells

Users sometimes enter multiple well names in a single string. This
function attempts to parse such a string and returns a vector of well
names.

## Usage

``` r
parse_well_series(v, format)
```

## Arguments

- v:

  A character vector of length 1 with a potential series of well names

- format:

  A well format string (e.g., "96", "384", "1536")

## Value

A vector with well names or `NA` values
