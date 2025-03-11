#' Read a value from a single cell
#' @param drfile Path to the data reporting file
#' @param sheet The sheet name
#' @param cell The addresses of the spreadsheet cell where the data is found
#' @param varname The key to be used for the value
#' @param atomicclass The name of the class to which the values should be coerced, if possible
#'
#' @return A named list
#' @noRd
#'
read_cells <- function(drfile, sheet, variables, translate = FALSE, translations = NULL, atomicclass = 'character') {
  result <- lapply(variables, function(v) {
    dims <- dim(cellranger::as.cell_limits(v$cell))
    if (any(dims > 1)) {
      rlang::abort(glue::glue("A cell address should point to a single cell."))
    }
    x <- suppressMessages(readxl::read_excel(drfile, sheet = sheet, range = v$cell, col_names = FALSE))
    if (nrow(x) == 0) {
      x <- NA
    } else {
      x <- x[[1]][1]
    }
  })
  result <- stats::setNames(result, sapply(variables, function(x) x$name))
  lapply(result, function(y) {
    switch(atomicclass,
           "character" = as.character(y),
           "numeric" = as.numeric(y),
           "integer" = as.integer(y),
           "logical" = as.logical(y))
  })
}

#' Read keyvalue pair formatted data from a spreadsheet
#' @param drfile Path to the data reporting file
#' @param sheet The sheet name
#' @param range The range of the data
#' @param translate Whether to translate long variable names to short variable names
#' @param translations A named vector with long variable names as names and short variable names as values
#' @param atomicclass The name of the class to which the values should be coerced, if possible
#' @return A named list. Values are coerced to character
#' @noRd
#'
read_keyvalue <- function(drfile, sheet, range, translate = FALSE, translations = NULL, atomicclass = "character", ...) {
  keyvalue <- readxl::read_excel(drfile, sheet = sheet, range = range, col_names = c("key", "value"))
  if (translate) {
    keyvalue$key <- long_to_shortnames(keyvalue$key, translations)
  }
  coerce <- function(x) {
    switch(atomicclass,
           "character" = as.character(x),
           "numeric" = as.numeric(x),
           "integer" = as.integer(x),
           "logical" = as.logical(x))
  }
  kvlist <- lapply(keyvalue$value, coerce)
  names(kvlist) <- keyvalue$key
  kvlist
}

#' Read table formatted data from a spreadsheet
#' @inherit read_keyvalue
#' @return A data frame in long format
#' @noRd
#'
read_table <- function(drfile, sheet, range, translate = FALSE, translations = NULL, atomicclass = "character", ...) {
  tbl <- readxl::read_excel(drfile, sheet = sheet, range = range)
  if (translate) {
    names(tbl) <- long_to_shortnames(names(tbl), translations)
  }
  tbl
}

#' Convert a data frame in plate-format to a long-format data frame
#' @param d A data frame in plate format
#' @return A data frame in long format
#' @noRd
#'
plate_to_df <- function(d) {
  var <- names(d)[1]
  newdf <- tibble::tibble(
    row = rep(LETTERS[1:8], 12),
    col = rep(1:12, each = 8),
    var = as.matrix(d[, -1]) |>
      as.vector()
  )
  names(newdf) <- c("row", "col", var)
  newdf
}

#' Read platedata formatted data from a spreadsheet
#' @inherit read_keyvalue
#' @return A data frame in long format
#' @noRd
read_key_plate <- function(drfile, sheet, range, translate = FALSE, translations = NULL, atomicclass = "character", ...) {
  plate <- readxl::read_excel(drfile, sheet = sheet, range = range)
  plate_to_df(plate)
}

#' Translate long variable names to short variable names
#' @param v A vector of long variable names
#' @param translations A named vector with long variable names as names and short variable names as values
#' @return A vector of short variable names
#' @noRd
long_to_shortnames <- function(v, translations) {
  positions <- match(v, translations$long)
  shortnames <- translations$short[positions]
  if (any (is.na(positions))) {
    rlang::warn("Missing translations. Using original long names.")
    shortnames[is.na(positions)] <- v[is.na(positions)]
  }
  shortnames
}

#' Reverse translate short variable names to long variable names
#' @inherit long_to_shortnames
#' @return A vector of long variable names
#' @noRd
short_to_longnames <- function(v, translations) {
  positions <- match(v, translations$short)
  longnames <- translations$long[positions]
  if (any(is.na(positions))) {
    rlang::warn("Missing reverse translations. Using short names.")
    longnames[is.na(positions)] <- v[is.na(positions)]
  }
  longnames
}

#' Read all data from a spreadsheet
#'
#' @param drfile Path to the data reporting file
#' @param guide A reporting template guide object or a path to a guide file
#' @param checkname Whether to check the name of the guide against that of the template
#' @description
#' Read all data from a spreadsheet according to a reporting template guide. The
#' data will be returned as a list with the optional elements keyvalue, table and
#' platedata if defined in the guide. The minimal and maximal template versions
#' of the guide mustbe compatible with that of the template in which the data
#' were recorded. Furthermore, the name of the template must match the template
#' name in the guide when when `checkname` is `TRUE`.
#' @return A list with up to three elements
#' @export
#'
read_data <- function(drfile, guide, checkname = FALSE) {

  if (inherits(guide, "character")) {
    # If 'guide' is a file path then read the guide
    guide <- read_guide(guide)
  } else {
    if (! inherits(guide, "guide")) {
      cl <- class(guide)
      rlang::abort(glue::glue("The guide must be a path (character) to a guide file or a reporting template guide object (guide object), not an object of class {cl}."))
    }
  }

  result <- list()

  for (location in guide$locations) {
    read_function <- switch(
      location$type,
      "keyvalue" = read_keyvalue,
      "table" = read_table,
      "platedata" = read_key_plate
    )

    atomicclass <- if ("atomicclass" %in% names(location)) location$atomicclass else "character"

    if (!location$type == "cells") {
      chunks <- lapply(location$ranges, function(range) {
        read_function(drfile = drfile, sheet = location$sheet, range = range, translate = location$translate,
                           translations = guide$translations, atomicclass = atomicclass)
      })
    } else {
      chunks <- read_cells(drfile = drfile, sheet = location$sheet, variables = location$variables, translate = location$translate,
                      translations = guide$translations, atomicclass = atomicclass)
    }

    chunk <- switch(
      location$type,
      "keyvalue" = do.call(c, chunks),
      "table" = dplyr::bind_rows(chunks),
      "platedata" = suppressMessages(Reduce(dplyr::full_join, chunks)),
      "cells" = chunks
    )

    if (!(location$varname %in% names(result[[location$type]]))) {
      result[[location$type]][[location$varname]] <- chunk
    } else {
      result[[location$type]][[location$varname]] <- switch(
        location$type,
        "keyvalue" = c(result[[location$type]][[location$varname]], chunk),
        "table" = dplyr::bind_rows(result[[location$type]][[location$varname]], chunk),
        "platedata" = suppressMessages(dplyr::full_join(result[[location$type]][[location$varname]], chunk)),
        "cells" = c(result[[location$type]][[location$varname]], chunk),
      )
    }
  }

  template.version <- result$cells$.template$version
  if (grepl("^\\d+$", template.version)) {
    template.version <- paste0(template.version, ".0")
    rlang::warn(glue::glue("The version number ({result$cells$.template$version}) is not correctly formatted. Interpreting as '{template.version}'"))
  }
  num.template.version <- package_version(template.version)
  num.min.version <- package_version(guide$template.min.version)
  if (num.template.version < num.min.version) {
     rlang::abort(glue::glue("The guide is incompatible with the template.
                             The template version should be minimally {guide$template.min.version}, whereas it is {result$template.metadata$template.version}."))
  }
  if (!is.null(guide$template.max.version)) {
    num.max.version <- package_version(guide$template.max.version)
    if (num.max.version < num.template.version) {
      rlang::abort(glue::glue("The guide is incompatible with the template.
                              The template version should be maximally {guide$template.max.version}, whereas it is {result$template.metadata$template.version}."))
    }
  }

  if (checkname) {
    if (guide$template.name != result$template.metadata$template.name) {
      rlang::abort(glue::glue("The name of the guide ({guide$template.name}) does not match the name of the excel template ({result$template.metadata$template.name})."))
    }
  }

  result$.sourcefile <- drfile
  result$.guide <- guide
  result
}
