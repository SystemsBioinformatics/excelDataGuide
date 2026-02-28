test_that("Reading a spreadsheet map works", {
  expect_no_error(read_guide(test_path("fixtures/guide_competition_1_0.yml")))
})

test_that("Function check_dim works", {
  expect_no_error(check_dim("A1:B1", NA, 2))
  expect_no_error(check_dim("A1:C10", 10, 3))
  expect_error(check_dim("A1:C1", NA, 2))
  expect_error(check_dim("A1:C3", 1, NA))
  expect_error(check_dim("A1:C3", 2, 2))
  expect_error(check_dim("A1:C3", NA, NA))
})

#test_that("check_guide works for correct guides", {
  # expect_no_error(read_guide(test_path("fixtures/goodguides/guide_competition_9_3.yml")))
  # expect_no_error(read_guide(test_path("fixtures/goodguides/guide_without_platedata.yml")))
  # expect_no_error(read_guide(test_path("fixtures/goodguides/guide_with_two_plates.yml")))
  # expect_no_error(read_guide(test_path("fixtures/goodguides/guide_without_templatemetadata.yml")))
#})
