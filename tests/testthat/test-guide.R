test_that("Reading a valid guide with platedata works", {
  expect_no_error(read_guide(test_path("fixtures/guide_competition_1_0.yml")))
})

test_that("Reading a valid guide without platedata works", {
  expect_no_error(read_guide(test_path(
    "fixtures/goodguides/guide_without_platedata.yml"
  )))
})

test_that("Function check_dim works", {
  expect_no_error(check_dim("A1:B1", NA, 2))
  expect_no_error(check_dim("A1:C10", 10, 3))
  expect_error(check_dim("A1:C1", NA, 2))
  expect_error(check_dim("A1:C3", 1, NA))
  expect_error(check_dim("A1:C3", 2, 2))
  expect_error(check_dim("A1:C3", NA, NA))
})

test_that("check_guide: missing plate.format when platedata is present yields an error", {
  expect_error(
    read_guide(test_path("fixtures/erroneousguides/missing_plate_format.yml")),
    regexp = "plate.format"
  )
})

test_that("check_guide: invalid plate.format value yields an error", {
  expect_error(
    read_guide(test_path("fixtures/erroneousguides/invalid_plate_format.yml")),
    regexp = "plate format"
  )
})

test_that("check_guide: wrong platedata range dimensions yield an error", {
  expect_error(
    read_guide(test_path(
      "fixtures/erroneousguides/invalid_platedata_range.yml"
    )),
    regexp = "required dimensions"
  )
})

test_that("check_guide: guide without a .template location yields an error", {
  expect_error(
    read_guide(test_path(
      "fixtures/erroneousguides/missing_template_location.yml"
    )),
    regexp = "\\.template"
  )
})

test_that("read_guide: duplicate long names in translations yield an error", {
  expect_error(
    read_guide(test_path(
      "fixtures/erroneousguides/duplicate_long_translations.yml"
    )),
    regexp = "Duplicate keys in long"
  )
})

test_that("read_guide: duplicate short names in translations yield an error", {
  expect_error(
    read_guide(test_path(
      "fixtures/erroneousguides/duplicate_short_translations.yml"
    )),
    regexp = "Duplicate keys in short"
  )
})

test_that("read_guide: reserved 'File path' long name mapped to non-.sourcefile short name yields an error", {
  expect_error(
    read_guide(test_path(
      "fixtures/erroneousguides/reserved_filepath_translation.yml"
    )),
    regexp = "File path"
  )
})
