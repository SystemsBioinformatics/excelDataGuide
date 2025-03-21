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
#' @export
#'
read_guide <- function(path) {
  guide <- yaml::read_yaml(path)
  check_guide(guide)

  if ('translations' %in% names(guide)) {

    guide$translations <- dplyr::bind_rows(guide$translations)

    # translation long and short names must be unique
    if (anyDuplicated(guide$translations$long)) {
      dup <- unique(guide$translations$long[duplicated(guide$translations$long)])
      rlang::abort("Duplicate keys in long names of the translations: {paste0(dup, collapse=', ')}")
    }

    if (anyDuplicated(guide$translations$short)) {
      dup <- unique(guide$translations$short[duplicated(guide$translations$short)])
      rlang::abort("Duplicate keys in short names of the translations: {paste0(dup, collapse=', ')}")
    }

    if (!(".sourcefile" %in% guide$translations$short)) {
      if ('File path' %in% guide$translations$long) {
        rlang::abort("The 'long' variable name 'File path' is reserved for the 'short' name '.sourcefile' exclusively.")
      }
      guide$translations <- dplyr::bind_rows(guide$translations, list(long='File path', short='.sourcefile'))
    }
  }

  structure(guide, class = "guide")
}

#' Abort if the guide does not contain all required elements
#' @param guide A spreadsheet guide object
#' @return An error message or nothing
#' @noRd
#'
check_guide <- function(guide) {
  ## NOTE: Most of the validation of a guide should be performed using the JSON schema

  # TODO: make translations optional

  # Conditionally required element plate.format in case we have platedata
  types <- unique(sapply(guide$locations, function(x) x$type))
  if ('platedata' %in% types) {
    if (!('plate.format' %in% names(guide))) {
      rlang::abort("The spreadsheet guide must contain the 'plate.format' element when 'platedata' is present in the locations.")
    }
    if (!(as.character(guide$plate.format) %in% names(.plateformats))) {
      rlang::abort(glue::glue("The plate format in the spreadsheet guide is not valid. It must be one of '24', '48', '96' or '384'."))
    }
  }

  # Check content of locations
  for (i in seq_along(guide$locations)) {
    if (guide$locations[[i]]$type == 'platedata') {
      for (range in guide$locations[[i]]$ranges) {
        check_dim(
          range,
          required_rows = .plateformats[[as.character(guide$plate.format)]]$rows + 1,
          required_cols = .plateformats[[as.character(guide$plate.format)]]$cols + 1
        )
      }
    } else {
      if (guide$locations[[i]]$type == 'cells') {
        dims <- dim(cellranger::as.cell_limits(guide$locations[[i]]$ranges[1]))
        # if (range.dim[range.dim > 1] != length(varnames)) {
        #   rlang::abort(glue::glue("The length of the range ({range.dim[range.dim > 1]}) differs from the number of variables given ({length(varnames)})."))
        # }
      }
    }
  }
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
    rlang::abort("You must specify at least one of 'required_rows' or 'required_cols'")
  }
  dims <- dim(cellranger::as.cell_limits(range))
  if (all(!is.na(c(required_rows, required_cols))) && any(dims != c(required_rows, required_cols))) {
    rlang::abort(glue::glue("The range {range} does not have the required dimensions. Expected: {required_rows} rows and {required_cols} columns"))
  }
  if (!is.na(required_rows) && dims[1] != required_rows) {
    rlang::abort(glue::glue("The range {range} does not have the required number of rows. Expected: {required_rows}"))
  }
  if (!is.na(required_cols) && dims[2] != required_cols) {
    rlang::abort(glue::glue("The range {range} does not have the required number of columns. Expected: {required_cols}"))
  }
}
