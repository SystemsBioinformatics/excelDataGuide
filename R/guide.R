#' Read a spreadsheet data guide
#'
#' @param path The path to the guide file
#' @return A list object with the guide data
#' @description
#' A spreadsheet guide is a YAML file that contains directions to where data
#' can be found in a spreadsheet. For an extensive description of this file
#' type, as well as instructions how to create and test the validity, please
#' see the vignettes.
#'
#' @param verify_hash If \code{TRUE}, checks that the guide file contains a
#'   \code{cue.verified} field with a valid SHA256 hash, confirming it was
#'   signed by \code{validate_and_sign.sh} after successful CUE validation.
#'   Issues a warning when the field is absent; aborts when the field is
#'   present but malformed. Does not recompute the hash (use
#'   \code{verify_guide.sh} in \code{data-raw/} for full hash verification).
#'   Defaults to \code{FALSE}.
#' @export
#'
read_guide <- function(path, verify_hash = FALSE) {
  guide <- yaml::read_yaml(path)

  if (verify_hash) {
    check_cue_hash(path, guide)
  }

  check_guide(guide)

  if ("translations" %in% names(guide)) {
    guide$translations <- dplyr::bind_rows(guide$translations)

    # Ensure unique long and short names in translations
    validate_unique_names(guide$translations$long, "long")
    validate_unique_names(guide$translations$short, "short")

    # Ensure reserved 'File path' and '.sourcefile' mapping
    if (!(".sourcefile" %in% guide$translations$short)) {
      if ("File path" %in% guide$translations$long) {
        rlang::abort(
          "The 'long' variable name 'File path' is reserved for the 'short' name '.sourcefile' exclusively."
        )
      }
      guide$translations <- dplyr::bind_rows(
        guide$translations,
        list(long = "File path", short = ".sourcefile")
      )
    }
  }

  structure(guide, class = "guide")
}

#' Helper function to validate unique names in translations
#' @param names_vector A vector of names to check for uniqueness
#' @param name_type The type of names to check (e.g., "long" or "short")
#' @return An error message or nothing
#' @noRd
#'
validate_unique_names <- function(names_vector, name_type) {
  if (anyDuplicated(names_vector)) {
    duplicates <- unique(names_vector[duplicated(names_vector)])
    rlang::abort(glue::glue(
      "Duplicate keys in {name_type} names of the translations: {paste0(duplicates, collapse = ', ')}"
    ))
  }
}

#' Abort if the guide does not contain all required elements
#' @param guide A spreadsheet guide object
#' @return An error message or nothing
#' @noRd
#'
check_guide <- function(guide) {
  ## NOTE: Most of the validation of a guide should be performed using the schema validator before the guide is used

  # Ensure translations are optional
  if (!"translations" %in% names(guide)) {
    guide$translations <- NULL
  }

  # Validate plate.format if platedata is present
  if ("platedata" %in% unique(sapply(guide$locations, `[[`, "type"))) {
    validate_plate_format(guide)
  }

  # validate presence of .template variable in locations
  if (
    !any(sapply(guide$locations, function(loc) {
      isTRUE(loc$varname == ".template")
    }))
  ) {
    rlang::abort(
      "The spreadsheet guide must contain the '.template' element with the template version."
    )
  }

  # Validate each location in the guide
  lapply(guide$locations, validate_location, guide)
}

#' Helper function to validate plate.format
#' @param guide A spreadsheet guide object
#' @return An error message or nothing
#' @noRd
#'
validate_plate_format <- function(guide) {
  if (!"plate.format" %in% names(guide)) {
    rlang::abort(
      "The spreadsheet guide must contain the 'plate.format' element when 'platedata' is present in the locations."
    )
  }
  if (!(as.character(guide$plate.format) %in% names(.plateformats))) {
    rlang::abort(glue::glue(
      "The plate format in the spreadsheet guide is not valid. It must be one of '24', '48', '96', or '384'."
    ))
  }
}

#' Helper function to validate a single location
#' @param location A location object from the guide
#' @param guide A spreadsheet guide object
#' @return An error message or nothing
#' @noRd
#'
validate_location <- function(location, guide) {
  if (location$type == "platedata") {
    validate_platedata_ranges(location$ranges, guide$plate.format)
  } else if (location$type == "cells") {
    validate_cells(location$ranges)
  }
}

#' Helper function to validate platedata ranges
#' @param ranges A list of ranges for platedata
#' @param plate_format The plate format specified in the guide
#' @return An error message or nothing
#' @noRd
#'
validate_platedata_ranges <- function(ranges, plate_format) {
  for (range in ranges) {
    check_dim(
      range,
      required_rows = .plateformats[[as.character(plate_format)]]$rows + 1,
      required_cols = .plateformats[[as.character(plate_format)]]$cols + 1
    )
  }
}

#' Helper function to validate cell ranges
#' @param ranges A list of ranges for cells
#' @return An error message or nothing
#' @noRd
#'
validate_cells <- function(ranges) {
  dims <- dim(cellranger::as.cell_limits(ranges[1]))
  # TODO: add additional validation logic for cells if needed
}

#' Function to check the dimensions of a range
#' @param range A range object
#' @param required_rows The required number of rows
#' @param required_cols The required number of columns
#' @return An error message or nothing
#' @noRd
#'
check_dim <- function(range, required_rows = NA, required_cols = NA) {
  if (is.na(required_rows) && is.na(required_cols)) {
    rlang::abort(
      "You must specify at least one of 'required_rows' or 'required_cols'."
    )
  }

  dims <- dim(cellranger::as.cell_limits(range))

  # Validate both rows and columns if both are specified
  if (!is.na(required_rows) && !is.na(required_cols)) {
    if (!all(dims == c(required_rows, required_cols))) {
      rlang::abort(glue::glue(
        "The range {range} does not have the required dimensions. Expected: {required_rows} rows and {required_cols} columns."
      ))
    }
    return() # Exit early if both dimensions are validated
  }

  # Validate rows if specified
  if (!is.na(required_rows) && dims[1] != required_rows) {
    rlang::abort(glue::glue(
      "The range {range} does not have the required number of rows. Expected: {required_rows}."
    ))
  }

  # Validate columns if specified
  if (!is.na(required_cols) && dims[2] != required_cols) {
    rlang::abort(glue::glue(
      "The range {range} does not have the required number of columns. Expected: {required_cols}."
    ))
  }
}
