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


#' Coerce a character vector based on atomicclass
#' @param x A character vector
#' @param atomicclass A character string indicating the atomic class
#' @description
#' We assume that the date is stored as a signed integer in excel, being the
#' number of days passed since January 1 1970. When read by read_excel it seems
#' to be converted to the number of seconds passed since January 1 1970. This
#' is the same as the POSIXct class in R. Hence, we can convert this number `x`
#' to a date again by using `as.POSIXct(x)` and
#' `format(as.POSIXct(x, tz=""), format="%Y-%m-%d")` to get a string with format
#' YYYY-MM-DD.
#'
#  TODO: check the previous and following statements
#
# ACCORDING TO Copilot:
# ### **Analysis**:
# 1. **Excel Date Storage**:
#    - Excel does **not** store dates as the number of days since January 1, 1970. Instead:
#      - Excel stores dates as the number of days since **January 1, 1900** (for Windows systems)
#        or **January 1, 1904** (for macOS systems).
#      - Excel also incorrectly assumes that 1900 was a leap year, which introduces an offset of
#        1 day for dates before March 1, 1900.
#
# 2. **`read_excel` Behavior**:
#    - When using `readxl::read_excel`, Excel dates are typically read as numeric values representing
#      the number of days since Excel's epoch (e.g., 1900 or 1904). These values are **not
#      automatically converted to POSIXct** by `read_excel`. The user must manually convert them.
#
# 3. **POSIXct Conversion**:
#    - The description mentions converting the number to a date using `as.POSIXct(as.integer(x))`.
#      However:
#      - This assumes that the numeric value `x` is already in seconds since January 1, 1970, which
#        is not the case for Excel dates.
#      - To convert Excel dates to R's `POSIXct`, you need to account for Excel's epoch (e.g.,
#        subtract the appropriate offset for 1900 or 1904).
#
# 4. **Formatting**:
#    - The description correctly states that `format(as.POSIXct(x, tz=""), format="%Y-%m-%d")`
#      can be used to format a `POSIXct` object as a string in the `YYYY-MM-DD` format.
#
# ### **Corrected Description**:
# Here’s a revised and accurate version of the description:
#
# Excel stores dates as numeric values representing the number of days since
# January 1, 1900 (Windows) or January 1, 1904 (macOS). Note that Excel's 1900
# date system incorrectly assumes 1900 was a leap year, which introduces a
# 1-day offset for dates before March 1, 1900.
#
# When read using `readxl::read_excel`, Excel dates are imported as numeric
# values. To convert these to R's `POSIXct` class, you must account for Excel's
# epoch. For example, subtract 25569 days (the number of days between January 1,
# 1900, and January 1, 1970) and convert to seconds by multiplying by 86400.
#
# Example conversion:
# `as.POSIXct((x - 25569) * 86400, origin = "1970-01-01", tz = "")`
#
# To format the date as a string in `YYYY-MM-DD` format, use:
# `format(as.POSIXct(...), format = "%Y-%m-%d")`.
#
#' @return A vector of the specified atomic class
#' @noRd
coerce <- function(x, atomicclass) {
  switch(atomicclass,
         "character" = as.character(x),
         "numeric" = as.numeric(x),
         "integer" = as.integer(x),
         "logical" = as.logical(x),
         "date" = as.POSIXct(as.integer(x))
        )
}
