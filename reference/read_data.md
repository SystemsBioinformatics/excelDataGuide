# Read all data from a spreadsheet

Read all data from a spreadsheet according to a reporting template
guide. The data will be returned as a list with the optional elements
keyvalue, table and platedata if defined in the guide. The minimal and
maximal template versions of the guide must be compatible with that of
the template in which the data were recorded. Furthermore, the name of
the template must match the template name in the guide when when
`checkname` is `TRUE`.

## Usage

``` r
read_data(drfile, guide, checkname = FALSE)
```

## Arguments

- drfile:

  Path to the data reporting file

- guide:

  A reporting template guide object or a path to a guide file

- checkname:

  Whether to check the name of the guide against that of the template

## Value

A list with up to three elements

## Details

The date atomicclass is a POSIXct object in R. Hence, we can convert
this object to a date string with format YYYY-MM-DD by using
`format(as.POSIXct(x, tz=""), format="%Y-%m-%d")`.
