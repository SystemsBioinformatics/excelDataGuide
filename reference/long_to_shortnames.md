# Translation between long and short variable names

Translate between long and short variable names. If a translation is
missing the original variable long or short variable name from `v` is
returned.

## Usage

``` r
long_to_shortnames(v, translations)

short_to_longnames(v, translations)
```

## Arguments

- v:

  A vector of variable names

- translations:

  A table of translations with columns `long` and `short`

## Value

A vector of long or short variable names

A vector of long variable names
