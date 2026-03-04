#' Normalize well names in a string that potentiallly contains wells
#'
#' @param v A vector with potentially sloppy well names
#'
#' @noRd
to_well_names <- function(v) {
  as.character(v) |>
    stringr::str_remove_all(" ") |>
    stringr::str_to_upper() |>
    stringr::str_replace("(?<=[A-Z])0+", "")
}


#' Normalize a vector with well names.
#'
#' @param v A vector with potentially sloppy well names
#' @param format A single element character or numeric vector with the format of the plate, or NULL
#' @description
#' Normalized well names are in the format `A1`, `B2`, `H12`, etc., i.e., an
#' uppercase letter followed by an integer without zero-padding and without
#' spaces. If the well name can not be converted to a normalized value an NA is
#' returned. If the plate format is given then the well names are checked to see
#' if they are present in the format, and are converted to NA if not.
#'
#' @return A vector with normalized well names
#' @export
#' @examples
#' normalize_wells(c("a01", "A 2", "0", " A 4 ", "A05", "H012", "K12"), 96)
#' normalize_wells(c("a01", "A 2", "0", " A 4 ", "A05", "H012", "K12"))
#'
normalize_wells <- function(v, format = NULL) {
  # Normalize well names
  v <- to_well_names(v)

  # Validate well names if format is provided
  if (!is.null(format)) {
    v <- check_wells(v, format, returnerror = FALSE)
  }

  # Mark invalid well names as NA
  v[!stringr::str_detect(v, "^[A-Z]+\\d+$")] <- NA
  v
}

#' Try to parse a string with a potential series of wells
#'
#' Users sometimes enter multiple well names in a single string. This function
#' attempts to parse such a string and returns a vector of well names.
#'
#' @param v A character vector of length 1 with a potential series of well names
#' @param format A well format string (e.g., "96", "384", "1536")
#' @return A vector with well names or `NA` values
#'
parse_well_series <- function(v, format) {
  # test length
  if (length(v) != 1) {
    rlang::abort(glue::glue(
      "The argument should be a vector of lenght 1, but the length equals {length(v)}."
    ))
  }

  # Normalize potential well names
  v <- to_well_names(v)

  # Detect the splitting character(s)
  #   - if comma then assume non-contiguous series
  #   - if dash or colon then assume contiguous series
  split_char <- stringr::str_extract(v, "[^A-Z\\d]+")
  if (!is.null(split_char)) {
    if (split_char == ",") {
      # Non-contiguous series
      v <- stringr::str_split(v, split_char)
      v <- unlist(v)
    } else if (split_char == "-" || split_char == ":") {
      # Contiguous series
      v <- stringr::str_split(v, split_char)
      start_rowcol <- rowcol_from_well(v[[1]])
      end_rowcol <- rowcol_from_well(v[[2]])
      v <- seq(from = start_rowcol, to = end_rowcol, by = 1)
    }
  }
  v
}

#' Check if a vector of well names is in the correct format.
#' If `returnerror` is `TRUE`, the function will throw an error if the well
#' names are not in the correct format. If `returnerror` is `FALSE`, the function
#' will return a vector with `NA` values in the positions where the well names
#' are not in the correct format.
#'
#' @param wells A vector with well names
#' @param format A single element character or numeric vector with the format of the plate
#' @param returnerror A logical value indicating if the function should throw an error
#' @return A vector with well names or `NA` values
#' @noRd
#'
check_wells <- function(wells, format, returnerror = TRUE) {
  format <- as.character(format)

  # Validate plate format
  if (!format %in% names(.plateformats)) {
    valid_formats <- paste(names(.plateformats), collapse = ", ")
    rlang::abort(glue::glue(
      "Invalid plate format '{format}'. Valid formats are: {valid_formats}."
    ))
  }

  # Ensure wells is a character vector
  if (!is.character(wells)) {
    rlang::abort(
      "Invalid 'wells' argument {wells}. The 'wells' argument must be a character vector."
    )
  }

  # Identify invalid wells
  invalid_wells <- !(wells %in% .plateformats[[format]]$wellnames)

  # Handle invalid wells
  if (any(invalid_wells)) {
    if (returnerror) {
      rlang::abort(glue::glue(
        "The following wells are invalid for the {format}-well format: {paste(wells[invalid_wells], collapse = ', ')}"
      ))
    } else {
      wells[invalid_wells] <- NA
    }
  }

  wells
}

#' Calculate well number from row and column
#'
#' @description This function can be used in the `raw_map()` function from
#' package `platetools`.
#'
#' @param row A character vector with the row names
#' @param col A numeric vector with the column names
#' @return A character vector with the well numbers
#' @export
#'
well_from_rowcol <- function(row, col) {
  # Validate inputs
  if (any(is.na(row)) || any(is.na(col))) {
    rlang::abort("Both 'row' and 'col' must not contain NA values.")
  }
  if (length(row) != length(col)) {
    rlang::abort("The lengths of 'row' and 'col' must be equal.")
  }

  # Generate well names
  paste0(row, sprintf("%01d", as.numeric(col)))
}

#' Calculate row and column from well name.
#'
#' @param well A character vector with the standard well names
#' @param format A single element character or numeric vector with the format of the plate
#' @return A list with two elements: row and col
#' @export
#' @examples
#' rowcol_from_well(c("A1", "B2", "C3", NA), 48)
#' # The order is preserved
#' rowcol_from_well(c("H12", "A1"), 96)
#'
rowcol_from_well <- function(well, format) {
  format <- as.character(format)

  # Validate plate format
  if (length(format) != 1) {
    rlang::abort("Plate format must be a single-element character vector.")
  }
  if (!format %in% names(.plateformats)) {
    valid_formats <- paste(names(.plateformats), collapse = ", ")
    rlang::abort(glue::glue(
      "Invalid plate format. Must be one of: {valid_formats}."
    ))
  }

  # Validate well names
  if (!is.character(well)) {
    rlang::abort("The 'well' parameter must be a character vector.")
  }
  invalid_wells <- well[
    !is.na(well) & !(well %in% .plateformats[[format]]$wellnames)
  ]
  if (length(invalid_wells) > 0) {
    rlang::abort(glue::glue(
      "The following wells are invalid for the {format}-well format: {paste(invalid_wells, collapse = ', ')}"
    ))
  }

  # Map wells to rows and columns
  indices <- match(well, .plateformats[[format]]$map$well)
  .plateformats[[format]]$map[indices, c("row", "col")]
}
