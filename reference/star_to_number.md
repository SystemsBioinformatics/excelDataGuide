# Using stars to indicate rejected values

If a template uses the convention of putting a star in front of or
behind numbers that should be rejected for further use then the function
`star_to_number()` can be used to convert the variable to a number. The
function `has_star()` checks whether a string has a star. It can be used
to generate a logical vector indicating accepted/rejected values.

## Usage

``` r
star_to_number(x)

has_star(x)
```

## Arguments

- x:

  A character vector

## Value

Function `star_to_number()` returns a numeric vector, `has_star()`
returns a logical vector.
