test_that("function normalize_wells", {
  wells1 <- c("A1", "B2", "c3", "0", "0")
  expect1 <- c("A1", "B2", "C3", NA, NA)
  expect_equal(normalize_wells(wells1, 96), expect1)
  wells2 <- c(0, 0)
  expect2 <- as.character(c(NA, NA))
  expect_equal(normalize_wells(wells2, 96), expect2)
  wells3 <- c("A01", " B02", "c03 ", " d0100", "E 50", "0", "A")
  expect3a <- c("A1", "B2", "C3", NA, NA, NA, NA)
  expect3b <- c("A1", "B2", "C3", "D100", "E50", NA, NA)
  expect_equal(normalize_wells(wells3, 96), expect3a)
  expect_equal(normalize_wells(wells3), expect3b)
})

test_that("Function check_wells works", {
  expect_error(check_wells("1A1", 96, returnerror = TRUE))
  expect_error(check_wells("A101", 384, returnerror = TRUE))
  expect_error(check_wells("A1", 1536, returnerror = TRUE))
  expect_error(check_wells(1, 384))
})

test_that("Function well_from_rowcol works", {
  expect_error(well_from_rowcol("A", 1:2))
  expect_error(well_from_rowcol(NA, 1))
  expect_error(well_from_rowcol("A", NA))
  expect_equal(well_from_rowcol("A", 1), "A01")
  expect_equal(well_from_rowcol("H", 12), "H12")
  expect_equal(well_from_rowcol(c("A","A","B"), c(10,1,4)), c("A10","A01","B04"))
})

test_that("Function rowcol_from_well works", {
  expect_error(rowcol_from_well("A16", 48))
  expect_no_error(rowcol_from_well("A16", 384))
  expect_equal(rowcol_from_well("A1", "24"), .plateformats[['24']]$map[1,c('row', 'col')])
  expect_equal(rowcol_from_well(c("A1", "B2", "C3"), "24"), .plateformats[['24']]$map[c(1,6,11), c('row', 'col')])
  expect_equal(rowcol_from_well(c("H12", "A1"), "96"), .plateformats[['96']]$map[c(96,1), c('row', 'col')])
  expect_error(rowcol_from_well("A1", c(96, 384)))
  expect_error(rowcol_from_well(c("A1", "B2"), 90))
})

test_that("Function rowcol_from_well yields no error when well is NA", {
  expect_no_error(rowcol_from_well(c("A1", NA), 96))
  expect_equal(rowcol_from_well(c("A1", NA), 96), .plateformats[['96']]$map[c(1,NA), c('row', 'col')])
})
