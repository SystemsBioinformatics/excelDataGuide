# test_that("Function zerotrunc works as expected", {
#   expect_equal(zero_trunc(c(0, 1, 2)), c(0.001, 1, 2))
#   expect_equal(zero_trunc(c(0, 0, 0)), c(1, 1, 1))
#   expect_equal(zero_trunc(c(NA, 0, 0)), c(NA, 1, 1))
# })

# test_that("Function download works as expected", {
#   expect_false(exists("https://few.vu.nl/~molenaar/PEPPER/data/approved_ids.yml", envir = .cacheEnv))
#   expect_no_error(download("https://few.vu.nl/~molenaar/PEPPER/data/approved_ids.yml"))
#   expect_true(exists("https://few.vu.nl/~molenaar/PEPPER/data/approved_ids.yml", envir = .cacheEnv))
# })

test_that("function star_to_number works", {
  expect_equal(star_to_number(NA), as.numeric(NA))
  expect_equal(star_to_number("1*"), 1)
  expect_equal(star_to_number("10*"), 10)
  expect_equal(star_to_number("0*"), 0)
  expect_equal(star_to_number("1.15*"), 1.15)
  expect_equal(star_to_number(c("1.15","0*")), c(1.15, 0))
  expect_equal(star_to_number(c("*1.15","*0")), c(1.15, 0))
})

test_that("function has_star works", {
  expect_equal(has_star(NA), NA)
  expect_equal(has_star("1*"), TRUE)
  expect_equal(has_star("10*"), TRUE)
  expect_equal(has_star("0*"), TRUE)
  expect_equal(has_star("1.15*"), TRUE)
  expect_equal(has_star(c("1.15","0*")), c(FALSE, TRUE))
})

test_that("function kvlist_to_table works", {
  guide <- list(translations = tibble::tibble(long=c("AAA", "BBB"), short = c("A", "B")))
  kvlist <- list(A = c(1, 2), B = c(3, 4))
  expect_no_error(kvlist_to_table(kvlist, guide, reverse.translate = TRUE))
  expect_equal(kvlist_to_table(kvlist, guide, reverse.translate = TRUE), tibble::tibble(key = c("AAA", "BBB"), value = c("1, 2", "3, 4")))
  expect_equal(kvlist_to_table(kvlist, guide, reverse.translate = FALSE), tibble::tibble(key = c("A", "B"), value = c("1, 2", "3, 4")))
  guide <- list(otherstuff = list("a" = "A", "b" = "B"))
  expect_error(kvlist_to_table(kvlist, guide, reverse.translate = TRUE))
})

test_that("function coerce works", {
  expect_equal(as.character(coerce(45748L, "date")), "2025-04-01")
  expect_equal(as.character(coerce(as.Date("2025-04-01"), "date")), "2025-04-01")
  expect_equal(coerce("45748", "integer"), 45748L)
  expect_equal(coerce("45748", "numeric"), 45748)
  expect_equal(coerce(45748L, "character"), "45748")
  expect_equal(coerce("true", "logical"), TRUE)
})

test_that("Reading dates from an excel file yield correct dates", {
  excel_file <- test_path("testdata/dates_linux.xlsx")
  date1 <- readxl::read_excel(excel_file, sheet=1, range="A1:A2")
  date2 <- readxl::read_excel(excel_file, sheet=1, range="B1:B2")
  date3 <- readxl::read_excel(excel_file, sheet=1, range="C1:C2")
  expect_equal(coerce(date1 |> dplyr::pull(1), "date"), as.Date("1962-10-27"))
  expect_equal(coerce(date2 |> dplyr::pull(1), "date"), as.Date("1962-10-27"))
  expect_equal(coerce(date3 |> dplyr::pull(1), "date"), as.Date("1962-10-27"))
  date4 <- readxl::read_excel(excel_file, sheet=1, range="D1:D2")
  date5 <- readxl::read_excel(excel_file, sheet=1, range="E1:E2")
  date6 <- readxl::read_excel(excel_file, sheet=1, range="F1:F2")
  expect_equal(coerce(date4 |> dplyr::pull(1), "date"), as.Date("2025-04-01"))
  expect_equal(coerce(date5 |> dplyr::pull(1), "date"), as.Date("2025-04-01"))
  expect_equal(coerce(date6 |> dplyr::pull(1), "date"), as.Date("2025-04-01"))
})
