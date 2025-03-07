## Create various guides for testing purposes, starting from a source guide

sourcename <- "guide_competition_1_0_source.yml"
targetname <- "guide_competition_1_0.yml"

source <- yaml::read_yaml(file.path("data-raw", sourcename))

# write the source file to the testdata folder
yaml::write_yaml(source, file.path("tests/testthat/testdata", targetname), indent.mapping.sequence = TRUE)

get_element_index <- function(s,x) {
  indexnrs <- c()
  for (ind in x) {
    if (is.numeric(ind)) {
      indexnrs <- c(indexnrs, ind)
    } else {
      if (length(indexnrs) > 0) {
        indexnrs <- c(indexnrs, which(names(s[[indexnrs]]) == ind))
      } else {
        indexnrs <- c(indexnrs, which(names(s) == ind))
      }
    }
  }
  indexnrs
}

modifications <- list(
  list(
    # Missing minimal version number
    element = list("template.min.version"),
    value = NULL,
    file = "missing_version.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Non-null maximal version number
    element = list("template.max.version"),
    value = "10.1",
    file = "maximal_version.yml",
    checkby = "schema",
    valid = TRUE
  ),
  list(
    # Missing translations
    element = list("translations"),
    value = NULL,
    file = "missing_translations.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Invalid atomic class
    element = list("locations", 2, "atomicclass"),
    value = "factor",
    file = "invalid_atomicclass.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Missing plateformat
    element = list("plate.format"),
    value = NULL,
    file = "missing_plate_format.yml",
    checkby = "testhat",
    valid = FALSE
  ),
  list(
    # Missing locations
    element = list("locations"),
    value = NULL,
    file = "missing_locations.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Invalid plateformat
    element = list("plate.format"),
    value = 95,
    file = "invalid_plate_format.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Invalid template metadata cell specification
    element = list("template.metadata", 1, "cell"),
    value = "A2:B2",
    file = "invalid_templatemetadata_cell.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Invalid template metadata variable name
    element = list("template.metadata", 1, "varname"),
    value  = "invalidname",
    file = "invalid_templatemetadata_varname.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Invalid platedata range
    element = list("locations", 3, "ranges"),
    value = c("A1:M8", "A11:M19"),
    file = "invalid_platedata_range.yml",
    checkby = "testthat",
    valid = FALSE
  ),
  list(
    # Invalid type
    element = list("locations", 2, "type"),
    value = "invalidtype",
    file = "invalid_type.yml",
    checkby = "schema",
    valid = FALSE
  ),
  list(
    # Missing location element
    element = list("locations", 2, "varname"),
    value = NULL,
    file = "missing_location_element.yml",
    checkby = "schema",
    valid = FALSE
  )
)

script <- file("data-raw/testguides.sh", open = "wt")
lapply(modifications, function(x) {
  s <- source
  s[[get_element_index(s, x$element)]] <- x$value
  if (x$checkby == "schema") {
    if (x$valid) {validationresult <- " --valid"} else {validationresult <- " --invalid"}
    fp <- file.path("data-raw/schema_tests", x$file)
    writeLines(paste0("pajv test -s excelguide_schema.json -d ", file.path('schema_tests', x$file) ,validationresult), script)
  } else {
    validationresult <- " --valid"
    fp <- file.path("tests/testthat/testdata/erroneousguides", x$file)
    writeLines(paste0("pajv test -s excelguide_schema.json -d ", file.path('../tests/testthat/testdata/erroneousguides', x$file) ,validationresult), script)
  }
  yaml::write_yaml(s, fp, indent.mapping.sequence = TRUE,
                   handlers = list(logical = yaml::verbatim_logical))
  # Correct ranges singletons that were converted to string instead of array
  # There seems to be no other way since R does not distinguish singletons from
  # single values.
  txt <- readLines(fp)
  newtxt <- c()
  for (line in txt) {
    if (any(stringr::str_detect(line, "ranges: .+$"))) {
      space <- stringr::str_extract(line, "(\\s+)ranges:\\s+(.+)$", group=1)
      value <- stringr::str_extract(line, "(\\s+)ranges:\\s+(.+)$", group=2)
      newtxt <- c(newtxt, paste0(space,"ranges:"))
      newtxt <- c(newtxt, paste0(space, "  - ", value))
    } else {
      newtxt <- c(newtxt, line)
    }
  }
  writeLines(newtxt, fp)
})
close(script)

# Create guides with additional elements

