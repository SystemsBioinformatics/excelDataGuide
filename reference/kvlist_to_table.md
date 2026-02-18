# Create a table from a list of key-value pairs

This function facilitates the construction of a table from a list of
key-value pairs present in the data. This is a handy function if you
want to print metadata in an analysis report.

## Usage

``` r
kvlist_to_table(kvlist, guide, reverse.translate = TRUE)
```

## Arguments

- kvlist:

  A list of key-value pairs

- guide:

  A data guide

- reverse.translate:

  A logical indicating whether to reverse translate the keys

## Value

A data frame with columns 'key' and 'value'
