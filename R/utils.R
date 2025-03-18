#' Create a table from a list of key-value pairs
#' @param kvlist A list of key-value pairs
#' @param guide A data guide
#' @param reverse.translate A logical indicating whether to reverse translate the keys
#' @return A data frame with columns 'key' and 'value'
#' @description
#' This function facilitates the construction of a table from a list of key-value
#' pairs present in the data. This is a handy function if you want to print
#' metadata in an analysis report.
#' @importFrom rlang .data
#' @export
kvlist_to_table <- function(kvlist, guide, reverse.translate = TRUE) {
  if (reverse.translate && !("translations" %in% names(guide))) {
    rlang::abort("There are no translations in the guide. If reverse.translate is TRUE, translations must be provided")
  }
  tbl <- tibble::tibble(key = names(kvlist), value = as.vector(unlist(lapply(kvlist, paste0, collapse=", "))))
  if (reverse.translate) {
    tbl <- tbl |>
      dplyr::mutate (key = short_to_longnames(.data$key, guide$translations))
  }
  tbl
}

#' @title Using stars to indicate rejected values
#' @param x A character vector
#' @description
#' If a template uses the convention of putting a star in front of or behind
#' numbers that should be rejected for further use then the function
#' `star_to_number()` can be used to convert the variable to a number. The
#' function `has_star()` checks whether a string has a star. It can be used to
#' generate a logical vector indicating accepted/rejected values.
#' @return Function `star_to_number()` returns a numeric vector, `has_star()`
#' returns a logical vector.
#' @export
star_to_number <- function(x) {
  as.numeric(stringr::str_remove_all(x, "[*x?]"))
}

#' Check if a string has a star
#' @export
#' @rdname star_to_number
#'
has_star <- function(x) {
  stringr::str_detect(x, "[*x?]")
}
