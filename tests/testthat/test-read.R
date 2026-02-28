
test_that("Translation from long to short names works", {
  guide <- read_guide(test_path("fixtures/guide_competition_1_0.yml"))
  expect_equal(long_to_shortnames("Version", guide$translations), "template.version")
})

test_that("Function long_to_short yields correct result for missing translations", {
  expect_equal(suppressWarnings(long_to_shortnames("Version", tibble::tibble(long=c("Longname1"), short=c("ln2")))), "Version")
  expect_warning(long_to_shortnames("Version", tibble::tibble(long=c("Longname1"), short=c("ln2"))))
})

test_that("Function short_to_longnames works", {
  guide <- read_guide(test_path("fixtures/guide_competition_1_0.yml"))
  expect_equal(short_to_longnames("template.version", guide$translations), "Version")
})

test_that("Function short_to_long yields correct result for missing translations", {
  expect_equal(suppressWarnings(short_to_longnames("template.version", tibble::tibble(long="long 1", short="short1"))), "template.version")
  expect_warning(short_to_longnames("template.version", tibble::tibble(long="long 1", short="short1")))
})

test_that("reading a single key-value pair works", {
  expect_no_error(read_keyvalue(drfile = test_path('fixtures/test1.xlsx'), sheet = 'description', range = "A2:B2"))
  expected_result <- list('template.version' = '9.3')
  guide <- read_guide(test_path("fixtures/guide_competition_1_0.yml"))
  expect_equal(read_keyvalue(drfile = test_path('fixtures/test1.xlsx'), sheet = 'description', range = "A2:B2", translate = TRUE,
                             translations = guide$translations), expected_result)
})

test_that("reading and coercing key-value pairs works", {
  expected_result_single <- list('max.spread' = 0.2)
  guide <- read_guide(test_path("fixtures/guide_competition_1_0.yml"))
  expect_equal(read_keyvalue(drfile = test_path('fixtures/test1.xlsx'), sheet = '_parameters', range = "A24:B24",
                             translate = FALSE, translations = guide$translations, atomicclass = "numeric"), expected_result_single)
  expected_result_multiple <- list('ic0.min' = 65, ic0.max=135)
  expect_equal(read_keyvalue(drfile = test_path('fixtures/test1.xlsx'), sheet = '_parameters', range = "A27:B28",
                             translate = FALSE, translations = guide$translations, atomicclass = "numeric"), expected_result_multiple)
})

test_that("reading multiple key-value pairs works", {
  expected_result <- list('studyID' = 'MyProject', 'exptID' = 'TTRfitc-020', 'plateID' = '1', 'instrID' = 'Instr1')
  expect_no_error(read_keyvalue(drfile = test_path('fixtures/test1.xlsx'), sheet = 'description', range = "A10:B13"))
  guide <- read_guide(test_path("fixtures/guide_competition_1_0.yml"))
  expect_equal(read_keyvalue(drfile = test_path('fixtures/test1.xlsx'), sheet = 'description', range = "A10:B13", translate = TRUE,
                             translations = guide$translations), expected_result)
})

test_that("Reading cells works", {
  variables <- list(list(name = "spread.itm1", cell = "G6"),
                    list(name = "spread.itm2", cell = "G33"))
  result <- list(spread.itm1 = "0.0463713477851084", spread.itm2 = "0.0154571159283695")
  expect_no_error(read_cells(drfile = test_path('fixtures/test1.xlsx'), sheet = 'BGfluo', variables = variables))
  expect_equal(read_cells(drfile = test_path('fixtures/test1.xlsx'), sheet = 'BGfluo', variables = variables), result)
})

test_that("reading a table works", {
  expect_no_error(read_table(drfile = test_path('fixtures/test1.xlsx'), sheet = '_data', range = "A101:B111"))
})

test_that("Function read_data works", {
  guide <- read_guide(test_path("fixtures/guide_competition_1_0.yml"))
  expect_no_error(read_data(drfile = test_path('fixtures/test1.xlsx'), guide = guide))
  expect_no_error(read_data(drfile = test_path('fixtures/test1.xlsx'), guide = test_path("fixtures/guide_competition_1_0.yml")))
})


# test_that("Function read_data using guide with two plates returns two plates", {
#   guide <- read_guide(test_path("fixtures/goodguides/guide_with_two_plates.yaml"))
#   result <- read_data(drfile = test_path('fixtures/test1.xlsx'), guide = guide)
#   expect_equal(length(result$platedata), 2)
# })

# test_that("Function read_data using guide split table returns single table", {
#   # guide <- read_guide(test_path("fixtures/goodguides/guide_with_split_table.yml"))
#   # result <- read_data(drfile = test_path('fixtures/test2.xlsx'), guide = guide)
#   # expect_equal(length(result$table), 1)
# })

test_that("Version incompatibilities yield an error.", {
  guide <- read_guide(test_path("fixtures/erroneousguides/conflicting_min_version.yml"))
  expect_error(read_data(drfile = test_path('fixtures/test1.xlsx'), guide = guide))
  guide <- read_guide(test_path("fixtures/erroneousguides/conflicting_max_version.yml"))
  expect_error(read_data(drfile = test_path('fixtures/test1.xlsx'), guide = guide))
})

# testing reading of dates
test_that("Reading key-value pairs with different atomic classes yields correct results", {
  excel_file <- test_path("fixtures/test0.xlsx")
  sheet <- "kvpairs"
  expect_no_error(
    result <- read_keyvalue(
      drfile = excel_file, sheet = sheet, range = "A2:B4",
      translate = FALSE, atomicclass = c("character","character","numeric")
    )
  )
  expect_equal(result, list(char1 = "9.3", char2 = "test", num1 = 1.2))
  expect_no_error(
    result <- read_keyvalue(
      drfile = excel_file, sheet = sheet, range = "A7:B7",
      translate = FALSE, atomicclass = c("character")
    )
  )
  expect_equal(
    result, list(char1 = "9.3")
  )
})
