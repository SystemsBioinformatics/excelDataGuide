# excelDataGuide

**excelDataGuide** is an R package that streamlines reading data from
standardized Excel spreadsheet templates into R.

## The problem

Spreadsheet templates are widely used in laboratories to standardize
data recording and reduce errors. However, extracting data from these
templates into R typically requires writing custom, template-specific
code. This is tedious and error-prone.

## The solution

The **excelDataGuide** package eliminates this burden by:

1.  **Defining a data guide** — a simple YAML file that describes where
    data are located in your template and how they should be interpreted
2.  **Reading data with one command** — the
    [`read_data()`](https://systemsbioinformatics.github.io/excelDataGuide/reference/read_data.md)
    function uses the guide to extract data correctly and automatically

The data guide approach also supports the [FAIR
principles](https://www.go-fair.org/fair-principles/) by making your
data structure explicit and machine-readable.

## Installation

You can install the development version of excelDataGuide from GitHub
with:

``` r
# install.packages("pak")
pak::pak("SystemsBioinformatics/excelDataGuide")
```

## Quick start

Reading data from an Excel template requires just two files: the
template itself and a data guide.

``` r
library(excelDataGuide)

# Path to your Excel file
datafile <- system.file("extdata", "example_data.xlsx", package = "excelDataGuide")

# Path to the data guide (YAML file)
guidefile <- system.file("extdata", "example_guide.yml", package = "excelDataGuide")

# Read the data
data <- read_data(datafile, guidefile)
```

The output is a list containing the data organized according to your
guide.

## Next steps

For detailed guidance on using this package:

- **[Designing
  templates](https://systemsbioinformatics.github.io/excelDataGuide/articles/writing_templates.md)**
  — Best practices for structuring your Excel templates (version
  numbers, protected cells, parameter sheets, *etc.*).

- **[Writing data
  guides](https://systemsbioinformatics.github.io/excelDataGuide/articles/writing_data_guides.md)**
  — Step-by-step instructions for creating YAML guides, with examples of
  all four data types (keyvalue, cells, table, platedata) and a complete
  working example.

## Future work

- [Provide guide and template structures for unbounded data types (time
  series,
  *etc.*)](https://github.com/SystemsBioinformatics/excelDataGuide/issues/1)
  \`\`\`
