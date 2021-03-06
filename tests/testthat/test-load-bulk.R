context("bulk load multiple raw files")

test_that("ACE data loads properly", {
  expect_is(load_ace_bulk(aceR_sample_data_path(), pattern = "ace", verbose = F), "data.frame")
})

test_that("SEA data loads properly", {
  expect_is(load_sea_bulk(aceR_sample_data_path(), pattern = "sea", verbose = F), "data.frame")
})
