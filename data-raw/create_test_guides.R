## Create various guides for testing purposes, starting from a source guide

sourcename <- "guide_competition_1_0_source.yml"
targetname <- "guide_competition_1_0.yml"
examplename <- "example_guide.yml"

source <- yaml::read_yaml(file.path("data-raw", sourcename))

# Modified yaml write function
write_yaml_mod <- function(x, file) {
  yaml::write_yaml(x, file, indent.mapping.sequence = TRUE, handlers = list(logical = yaml::verbatim_logical))
  # Correct ranges or cells singletons that were converted to string instead of
  # array. There is no other way since R does not distinguish singletons from
  # single values.
  txt <- readLines(file)
  newtxt <- c()
  for (line in txt) {
    if (any(stringr::str_detect(line, "(ranges|cells): .+$"))) {
      space <- stringr::str_extract(line, "(\\s+)(ranges:|cells:)\\s+(.+)$", group=1)
      label <- stringr::str_extract(line, "(\\s+)(ranges:|cells:)\\s+(.+)$", group=2)
      value <- stringr::str_extract(line, "(\\s+)(ranges:|cells:)\\s+(.+)$", group=3)
      newtxt <- c(newtxt, paste0(space, label))
      newtxt <- c(newtxt, paste0(space, "  - ", value))
    } else {
      newtxt <- c(newtxt, line)
    }
  }
  writeLines(newtxt, file)
}

# write the source file to the testdata folder
write_yaml_mod(source, file.path("tests/testthat/testdata", targetname))
write_yaml_mod(source, file.path("inst/extdata", examplename))

# Take a list s and a list of index numbers and/or names x and return
# a vector of index numbers in list s correspond to the index names and or
# numbers. The vector of index numbers can be used in the expression
# "s[[indexnrs]]" to descend into s.
get_element_index <- function(s, x) {
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
    # Incompatible version
    element = list("template.min.version"),
    value = "9.4",
    file = "conflicting_min_version.yml",
    checkby = "testthat",
    valid = TRUE
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
    # Incompatible version, Note, min. version will be larger than max.version,
    # but that fact does not yield an error, currently.
    element = list("template.max.version"),
    value = "9.2",
    file = "conflicting_max_version.yml",
    checkby = "testthat",
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
  write_yaml_mod(s, fp)
})
close(script)

# Create guides with additional elements

