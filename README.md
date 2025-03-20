
<!-- README.md is generated from README.Rmd. Please edit that file -->

# excelDataGuide

<!-- badges: start -->
<!-- badges: end -->

**excelDataGuide** is an R package designed to streamline the process of
importing data from spreadsheet *data reporting templates* (DRTs) into
R.

A *data reporting template* is a standardized spreadsheet file (in
either xls or xlsx format) used for reporting and processing
experimental data. These templates significantly reduce the time
required for data analysis and encourage users to present their data in
a structured format, minimizing errors and misinterpretations.

The **excelDataGuide** package eliminates the need for users to write
and maintain complex code for reading data from intricate spreadsheet
DRTs. Additionally, it offers a robust framework for validating data,
ensuring the correct data types are utilized, and facilitating data
wrangling when necessary. This functionality supports *Interoperability*
for DRTs, a key aspect of the
[FAIR](https://www.go-fair.org/fair-principles/) principles.

The package features a user-friendly interface for extracting data from
Excel files and converting it into R objects. It accommodates three
types of data structures: key-value pairs, tabular data, and
microplate-formatted data. The locations of these structures within the
Excel template are specified by a **data guide**, which is a YAML file —
a structured format that is both human- and machine-readable.

## Installation

You can install the development version of excelDataGuide from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("SystemsBioinformatics/excelDataGuide")
```

## Example

The basic usage of the package requires only one command with two file
paths: the path to the Excel data file and the path to the data guide
file. Here is an example:

``` r
library(excelDataGuide)
datafile <- system.file("extdata", "example_data.xlsx", package = "excelDataGuide")
guidefile <- system.file("extdata", "example_guide.yml", package = "excelDataGuide")
data <- read_data(datafile, guidefile)
```

The output of the `read_data()` function is a list object the format of
which is determined for a large part by the design of the data guide.

## Future work

We want to provide guide and template structures for data types without
upper size limit, like time series with no pre-determined length.
