# Read a spreadsheet data guide

A spreadsheet guide is a YAML file that contains directions to where
data can be found in a spreadsheet. For an extensive description of this
file type, as well as instructions how to create and test the validity,
please see the vignettes.

## Usage

``` r
read_guide(path, verify_hash = FALSE)
```

## Arguments

- path:

  The path to the guide file

- verify_hash:

  If `TRUE`, checks that the guide file contains a `cue.verified` field
  with a valid SHA256 hash, confirming it was signed by
  `validate_and_sign.sh` after successful CUE validation. Issues a
  warning when the field is absent; aborts when the field is present but
  malformed. Does not recompute the hash (use `verify_guide.sh` in
  `data-raw/` for full hash verification). Defaults to `FALSE`.

## Value

A list object with the guide data
