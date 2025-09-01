
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

The **excelDataGuide** package eliminates the need for data analysts to
write and maintain complex code for reading data from various complex
spreadsheet DRTs. Additionally, it offers a robust framework for
validating data, ensuring that the correct data types are utilized, and
facilitating data wrangling when necessary. This functionality supports
*Interoperability* for DRTs, a key aspect of the
[FAIR](https://www.go-fair.org/fair-principles/) principles.

The package features a user-friendly interface for extracting data from
Excel files and converting it into R objects. It accommodates three
types of data structures: key-value pairs, tabular data, and
microplate-formatted data. The locations of these structures within the
Excel template are specified by a **data guide**, which is a YAML file —
a structured format that is both human- and machine-readable.

## Installation

You can install the development version of excelDataGuide in a recent
version of R from GitHub with:

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

## Details

### How it works

When you design a template Excel file for data reporting and analysis
you also create a *data guide* file that specifies the structure and
location of the data in the template. If you design the template
carefully you can use the same data guide for several versions of the
template. That is, as long as the location of the indexed data does not
change, you can use the same data guide for different versions of the
template. You can specify the compatible version of the templates in the
*data guide*. The package will check compatibility. Clearly, you should
use versioned data templates, and hence, a required field in a template
is its version number. An example of a template with data is provided in
the package
(`system.file("extdata", "example_data.xlsx", package = "excelDataGuide")`).

Once you have entered the data and metadata in a template you can use
the package to extract the data into R. The package will check and
coerce the data types to the required formats.

### Data guide

The *data guide* is a human readable and editable file in
[YAML](https://yaml.org/spec/1.2.2/) format that specifies the structure
and location of the data in the Excel file. It contains a list of data
types, each of which is defined by a name and a set of parameters. As
the name suggests, the *data guide* is used by the **excelDataGuide**
package as a guide to extract all indexed data from the Excel file and
convert it into proper R objects. Part of the *data guide* from the
example in the package, *i.e.*
`system.file("extdata", "example_guide.yml", package = "excelDataGuide")`
is shown below:

``` yaml
guide.version: '1.0'
template.name: competition
template.min.version: '9.3'
template.max.version: ~
plate.format: 96
locations:
  - sheet: description
    type: cells
    varname: .template
    translate: false
    variables:
      - name: version
        cell: B2
  - sheet: description
    type: keyvalue
    translate: true
    atomicclass:
      - character
      - character
      - character
      - character
      - character
      - date
      - character
      - numeric
      - character
      - numeric
      - character
      - numeric
      - character
      - character
    varname: metadata
    ranges:
      - A10:B21
      - A24:B25
```

We provide a cue schema for the data guide, allowing you to check the
validity of guides that you wrote. The schema is available in the
package as
`system.file("extdata", "excelguide_schema.cue", package = "excelDataGuide")`.
To check its validity against the schema you can use the
[CUE](https://cuelang.org/docs/) validator. More details can be found in
the vignette (to be done, see below).

## Future work

- Complete the vignette
  ([issue](https://github.com/SystemsBioinformatics/excelDataGuide/issues/2))
- Provide guide and template structures for data types without upper
  size limit, typically time series with no pre-determined length
  ([issue](https://github.com/SystemsBioinformatics/excelDataGuide/issues/1)).
