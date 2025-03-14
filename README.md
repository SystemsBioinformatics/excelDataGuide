
<!-- README.md is generated from README.Rmd. Please edit that file -->

# excelDataGuide

<!-- badges: start -->
<!-- badges: end -->

**excelDataGuide** simplifies reading data from Excel data reporting
templates (DRT’s) into R.

A data reporting template is an Excel file for standardized reporting
and processing of experimental data. The template encourages or forces
users to provide data in a structured manner that minimizes errors and
misinterpretation.

The package provides a simple interface to read data from Excel files
and convert them into R objects. We assume that data is organized in
three types of data structures; key-value pairs, tabular data and
microplateplate-formatted data. The locations of these data structures
in the Excel template are provided by a **data guide**. A data guide is
a YAML file designed for a specific data reporting template.

## Installation

You can install the development version of excelDataGuide from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("SystemsBioinformatics/excelDataGuide")
```

## Example

The basic usage of the package only requires one command with two file
paths: the path to the Excel data file and the path to the data guide
file. Here is an example:

``` r
library(excelDataGuide)
datafile <- system.file("extdata", "example_data.xlsx", package = "excelDataGuide")
guidefile <- system.file("extdata", "example_guide.yml", package = "excelDataGuide")
data <- read_data(datafile, guidefile)
```

The output of the `read_data()` function is a list object containing the
data in a structured manner. The structure is determined for a large
part by the design of the data guide.

## Future work

Provide guide and template structures for data types without upper size
limit, like time series with no pre-determined length.
