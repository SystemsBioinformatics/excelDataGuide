# function to download information from a url, or if it is already in cache to
# use the cache. Note that cacheEnv is initiated in the file aaa.R
# download <- function(url) {
#   if (exists(url, envir = .cacheEnv)) {
#     return(get(url, envir = .cacheEnv))
#   }
#   file <- httr2::request(url) |>
#     httr2::req_perform() |>
#     httr2::resp_body_string()
#   assign(url, file, envir = .cacheEnv)
#   file
# }

#' Create a table from a list of key-value pairs
#' @param kvlist A list of key-value pairs
#' @param guide A data guide
#' @param reverse.translate A logical indicating whether to reverse translate the keys
#' @return A data frame with columns 'key' and 'value'
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

#' Convert a string with a star to a number
#' @param x A character vector
#' @return A numeric vector
#' @noRd
star_to_number <- function(x) {
  as.numeric(stringr::str_remove_all(x, "[*x?]"))
}
