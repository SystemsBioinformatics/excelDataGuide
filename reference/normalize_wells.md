# Normalize a vector with well names.

Normalized well names are in the format `A1`, `B2`, `H12`, etc., i.e.,
an uppercase letter followed by an integer without zero-padding and
without spaces. If the well name can not be converted to a normalized
value an NA is returned. If the plate format is given then the well
names are checked to see if they are present in the format, and are
converted to NA if not.

## Usage

``` r
normalize_wells(v, format = NULL)
```

## Arguments

- v:

  A vector with potentially sloppy well names

- format:

  A single element character or numeric vector with the format of the
  plate, or NULL

## Value

A vector with normalized well names

## Examples

``` r
normalize_wells(c("a01", "A 2", "0", " A 4 ", "A05", "H012", "K12"), 96)
#> [1] "A1"  "A2"  NA    "A4"  "A5"  "H12" NA   
normalize_wells(c("a01", "A 2", "0", " A 4 ", "A05", "H012", "K12"))
#> [1] "A1"  "A2"  NA    "A4"  "A5"  "H12" "K12"
```
