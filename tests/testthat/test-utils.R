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
