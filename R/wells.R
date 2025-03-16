#' Standardize a vector with well names.
#'
#' @param v A vector with potentially sloppy well names
#' @param format A single element character or numeric vector with the format of the plate
#' @return A vector with standardized well names
#' @export
#' @examples
#' format_wells(c("a01", "A 2", "0", " A 4 ", "A05", "H012"), 96)
#'
#'
format_wells <- function(v, format) {
  v <- as.character(v) |>
    stringr::str_remove_all(" ") |>
    stringr::str_to_upper() |>
    stringr::str_replace("(?<=[A-Z])0+", "")
  check_wells(v , format, returnerror = FALSE)
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
#'
#' @noRd
check_wells <- function(wells, format, returnerror = TRUE) {
  format <- as.character(format)
  if (!format %in% names(.plateformats)) {
    rlang::abort("format must be one of '24', '48', '96', or '384'")
  }
  if (!is.character(wells)) {
    rlang::abort("wells must be a character vector")
  }
  wrongwells <- !(wells %in% .plateformats[[format]]$wellnames)
  if (any(wrongwells)) {
    if (returnerror) {
      rlang::abort(glue::glue("wells not present in {format}-wells format"))
    } else {
      wells[wrongwells] <- NA
    }
  }
  wells
}

#' Calculate well number from row and column. Function used in `raw_map` function
#' from package `platetools`.
#'
#' @param row A character vector with the row names
#' @param col A numeric vector with the column names
#' @return A character vector with the well numbers
#' @export
#'
well_from_rowcol <- function(row, col) {
  if (any(is.na(row)) || any(is.na(col))) {
    rlang::abort("row and col must not contain NA values")
  }
  if (length(row) != length(col)) {
    rlang::abort("The length of row and col must be the same")
  }
  paste0(row, sprintf("%02.f", as.numeric(col)))
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
rowcol_from_well <- function(well, format) {
  format <- as.character(format)
  if (!length(format) == 1) {
    rlang::abort("Plate format must be a single element character vector")
  }
  plfs <- names(.plateformats)
  if (!as.character(format) %in% plfs) {
    rlang::abort(glue::glue("Plate format must be one of ", paste0("'", plfs, "'", collapse = ", "), "."))
  }
  if (!is.character(well)) {
    rlang::abort("Well must be a character vector")
  }
  if (any(!well[!is.na(well)] %in% .plateformats[[format]]$wellnames)) {
    rlang::abort(glue::glue("Wells not present in {format}-wells format"))
  }
  indices <- match(well, .plateformats[[format]]$map$well)
  .plateformats[[format]]$map[indices, c('row', 'col')]
}
