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
read_cells <- function(
  drfile,
  sheet,
  variables,
  translate = FALSE,
  translations = NULL,
  atomicclass = 'character'
) {
  # Process each variable
  result <- lapply(variables, function(v) {
    # Ensure the cell address points to a single cell
    if (any(dim(cellranger::as.cell_limits(v$cell)) > 1)) {
      rlang::abort(glue::glue("A cell address should point to a single cell."))
    }

    # Read the cell value
    cell_data <- suppressMessages(
      readxl::read_excel(
        drfile,
        sheet = sheet,
        range = v$cell,
        col_names = FALSE
      )
    )

    # Handle empty cells
    if (nrow(cell_data) == 0) {
      NA
    } else {
      cell_data[[1]][1]
    }
  })

  # Assign names to the results
  result <- stats::setNames(result, sapply(variables, `[[`, "name"))

  # Coerce values to the specified atomic class
  lapply(result, coerce, atomicclass)
}

#' Read keyvalue pair formatted data from a spreadsheet
#' @param drfile Path to the data reporting file
#' @param sheet The sheet name
#' @param ranges A vector of ranges
#' @param translate Whether to translate long variable names to short variable names
#' @param translations A named vector with long variable names as names and short variable names as values
#' @param atomicclass The name of the class to which the values should be coerced, if possible
#' @description
#' The `atomicclass` argument can be a single class name or a vector of class names.
#' If it is a single class name, all values will be coerced to this class. If it
#' is a vector of class names, the length of the vector must be equal to the number
#' of rows in the keyvalue table or equal to the number of columns in a table type
#' range. In this case, each value will be coerced to the class specified in the
#' corresponding element of the vector or column of the table.
#' @return A named list. Values are coerced to character
#' @noRd
#'
read_keyvalue <- function(
  drfile,
  sheet,
  ranges,
  translate = FALSE,
  translations = NULL,
  atomicclass = "character",
  ...
) {
  # Read and combine key-value pairs from the specified ranges
  kvtable <- lapply(ranges, function(range) {
    readxl::read_excel(
      drfile,
      sheet = sheet,
      range = range,
      col_names = c("key", "value")
    )
  }) |>
    dplyr::bind_rows()

  # Translate keys if required
  if (translate) {
    kvtable$key <- long_to_shortnames(kvtable$key, translations)
  }

  # Convert values to a list
  kvlist <- as.list(kvtable$value)

  # Coerce values to the specified atomic class
  kvlist <- if (length(atomicclass) == 1) {
    lapply(kvlist, coerce, atomicclass)
  } else {
    if (length(atomicclass) != length(kvlist)) {
      rlang::abort(glue::glue(
        "The number of atomic classes ({length(atomicclass)}) must be 1 or equal to the number of elements ({length(kvlist)}) in the key-value table."
      ))
    }
    mapply(coerce, kvlist, atomicclass, SIMPLIFY = FALSE)
  }

  # Return a named list with keys and coerced values
  setNames(kvlist, kvtable$key)
}

#' Read table formatted data from a spreadsheet
#' @inherit read_keyvalue
#' @return A data frame in long format
#' @noRd
#'
read_table <- function(
  drfile,
  sheet,
  ranges,
  translate = FALSE,
  translations = NULL,
  atomicclass = "character",
  ...
) {
  # Read and combine data from the specified ranges
  tbl <- lapply(ranges, function(range) {
    readxl::read_excel(drfile, sheet = sheet, range = range)
  }) |>
    dplyr::bind_rows()

  # Coerce columns to the specified atomic class
  if (length(atomicclass) == 1) {
    tbl[] <- lapply(tbl, coerce, atomicclass)
  } else {
    if (length(atomicclass) != ncol(tbl)) {
      rlang::abort(
        "The number of atomic classes must be 1 or equal to the number of columns in the table."
      )
    }
    tbl[] <- Map(coerce, tbl, atomicclass)
  }

  # Translate column names if required
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
  # TODO: handle plate formats generically
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
#'
#' @inherit read_keyvalue
#' @return A data frame in long format
#' @noRd
read_key_plate <- function(
  drfile,
  sheet,
  ranges,
  translate = FALSE,
  translations = NULL,
  atomicclass = "character",
  ...
) {
  # Read and convert each range to a long-format data frame
  chunks <- lapply(ranges, function(range) {
    plate <- readxl::read_excel(drfile, sheet = sheet, range = range) |>
      plate_to_df()
    plate
  })

  # Combine all chunks into a single data frame
  combined <- suppressMessages(Reduce(dplyr::full_join, chunks))

  # Handle vectors of atomicclass
  if (length(atomicclass) == 1) {
    combined[] <- lapply(combined, coerce, atomicclass)
  } else {
    # The first two columns are "row" and "col", added by the function plate_to_df
    atomicclass <- c("character", "integer", atomicclass)

    if (length(atomicclass) != ncol(combined)) {
      rlang::abort(glue::glue(
        "The number of atomic classes ({length(atomicclass) - 2}) must be 1 or equal to the number of columns ({ncol(combined) - 2}) in the combined data frame."
      ))
    }
    combined[] <- Map(coerce, combined, atomicclass)
  }

  # Translate column names if required
  if (translate) {
    names(combined) <- long_to_shortnames(names(combined), translations)
  }

  combined
}

#' Translation function generator
#' This function generates either the function `long_to_shortnames` or `short_to_longnames`
#' @noRd
gentranslator <- function(type = 'long-short') {
  stopifnot(type %in% c('long-short', 'short-long'))
  if (type == 'long-short') {
    col_from = 'long'
    col_to = 'short'
  } else {
    col_from = 'short'
    col_to = 'long'
  }
  function(v, translations) {
    matchdf <- data.frame(v)
    names(matchdf) <- col_from
    matches <- dplyr::left_join(matchdf, translations, by = {{ col_from }})
    if (any(is.na(matches[[col_to]]))) {
      missing_translations <- paste0(
        "'",
        matches[[col_from]][is.na(matches[[col_to]])],
        "'",
        collapse = ", "
      )
      rlang::warn(
        c(
          glue::glue("Missing translations for: {missing_translations}."),
          "i" = glue::glue("Will use original {col_from} names.")
        ),
        use_cli_format = TRUE
      )
      matches[[col_to]][is.na(matches[[col_to]])] <- matches[[
        col_from
      ]][is.na(matches[[col_to]])]
    }
    return(matches[[col_to]])
  }
}

#' Translation between long and short variable names
#'
#' @description
#' Translate between long and short variable names. If a translation is missing the original
#' variable long or short variable name from `v` is returned.
#' @param v A vector of variable names
#' @param translations A table of translations with columns `long` and `short`
#' @return A vector of long or short variable names
#' @export
long_to_shortnames <- gentranslator('long-short')

#' @return A vector of long variable names
#' @rdname long_to_shortnames
#' @export
short_to_longnames <- gentranslator('short-long')


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
#' @details
#' The date atomicclass is a POSIXct object in R. Hence, we can convert this
#' object to a date string with format YYYY-MM-DD by using
#' `format(as.POSIXct(x, tz=""), format="%Y-%m-%d")`.
#' @return A list with up to three elements
#' @export
#'
read_data <- function(drfile, guide, checkname = FALSE) {
  # Load the guide if it's a file path
  if (inherits(guide, "character")) {
    guide <- read_guide(guide)
  } else if (!inherits(guide, "guide")) {
    rlang::abort(glue::glue(
      "The guide must be a path (character) to a guide file or a reporting template guide object (guide object), not an object of class {class(guide)}."
    ))
  }

  result <- list()

  # Process each location in the guide
  for (location in guide$locations) {
    read_function <- switch(
      location$type,
      "keyvalue" = read_keyvalue,
      "table" = read_table,
      "platedata" = read_key_plate,
      "cells" = read_cells,
      rlang::abort(glue::glue("Unsupported location type: {location$type}"))
    )

    # The default atomic class is "character"
    atomicclass <- if (!is.null(location$atomicclass)) {
      location$atomicclass
    } else {
      "character"
    }

    # Read data using the appropriate function
    chunk <- if (location$type == "cells") {
      read_function(
        drfile = drfile,
        sheet = location$sheet,
        variables = location$variables,
        translate = location$translate,
        translations = guide$translations,
        atomicclass = atomicclass
      )
    } else {
      read_function(
        drfile = drfile,
        sheet = location$sheet,
        ranges = location$ranges,
        translate = location$translate,
        translations = guide$translations,
        atomicclass = atomicclass
      )
    }

    # Combine results
    result[[location$type]][[location$varname]] <- combine_results(
      result[[location$type]][[location$varname]],
      chunk,
      location$type
    )
  }

  # Validate template version
  if (exists("cells", where = result)) {
    if (exists(".template", where = result$cells)) {
      if (exists("version", where = result$cells$.template)) {
        validate_template_version(result$cells$.template$version, guide)
      }
    }
  } else {
    if (exists("keyvalue", where = result)) {
      if (exists(".template", where = result$keyvalue)) {
        if (exists("version", where = result$keyvalue$.template)) {
          validate_template_version(result$keyvalue$.template$version, guide)
        }
      }
    } else {
      rlang::abort(
        "Variable '.template$version' not found under cells or keyvalue variables"
      )
    }
  }

  # Check template name if required
  if (
    checkname && guide$template.name != result$template.metadata$template.name
  ) {
    rlang::abort(glue::glue(
      "The name of the guide ({guide$template.name}) does not match the name of the excel template ({result$template.metadata$template.name})."
    ))
  }

  result$.sourcefile <- drfile
  result$.guide <- guide
  result
}

#' Helper function to combine results based on location type
#' @param existing The existing data
#' @param chunk The new data
#' @param type The location type
#' @noRd
combine_results <- function(existing, chunk, type) {
  if (is.null(existing)) {
    return(chunk)
  }

  switch(
    type,
    "keyvalue" = c(existing, chunk),
    "table" = dplyr::bind_rows(existing, chunk),
    "platedata" = suppressMessages(dplyr::full_join(existing, chunk)),
    "cells" = c(existing, chunk),
    rlang::abort(glue::glue(
      "Unsupported location type for combining results: {type}"
    ))
  )
}

#' Helper function to validate template
#' @param template_version The version of the template
#' @param guide The guide object
#' @noRd
validate_template_version <- function(template_version, guide) {
  if (grepl("^\\d+$", template_version)) {
    template_version_curr <- template_version
    template_version <- paste0(template_version, ".0")
    rlang::warn(glue::glue(
      "Incorrectly formatted template version number '{template_version_curr}'. Version numbers must have a minor number. Interpreting as '{template_version}'."
    ))
  }

  num_template_version <- package_version(template_version)
  num_min_version <- package_version(guide$template.min.version)

  if (num_template_version < num_min_version) {
    rlang::abort(glue::glue(
      "The guide is incompatible with the template. The template version should be at least {guide$template.min.version}, but it is {template_version}."
    ))
  }

  if (!is.null(guide$template.max.version)) {
    num_max_version <- package_version(guide$template.max.version)
    if (num_template_version > num_max_version) {
      rlang::abort(glue::glue(
        "The guide is incompatible with the template. The template version should be at most {guide$template.max.version}, but it is {template_version}."
      ))
    }
  }
}
