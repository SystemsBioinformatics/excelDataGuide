## code to prepare `.plateformats`

## Note that this must match the allowed formats in the CUE schema file
## excelguide_schema.cue, field #Plateformat

cue_lines <- readLines("data-raw/excelguide_schema.cue")
plateformat_line <- cue_lines[grep("^#Plateformat:", cue_lines)]
schema.plateformats <- trimws(strsplit(
  sub("^#Plateformat:\\s*", "", plateformat_line),
  "\\|"
)[[1]])

.plateformats <- list(
  "24" = list(
    "rows" = 4,
    "cols" = 6
  ),
  "48" = list(
    "rows" = 6,
    "cols" = 8
  ),
  "96" = list(
    "rows" = 8,
    "cols" = 12
  ),
  "384" = list(
    "rows" = 16,
    "cols" = 24
  )
)

stopifnot(
  all(names(.plateformats) %in% schema.plateformats) &&
    all(schema.plateformats %in% names(.plateformats))
)

generate_wellnames <- function(format) {
  row <- LETTERS[1:.plateformats[[format]]$rows]
  col <- 1:.plateformats[[format]]$cols
  rowcols <- expand.grid(row = row, col = col)
  rowcols$well <- paste0(rowcols$row, rowcols$col)
  tibble::as_tibble(rowcols)
}

for (format in names(.plateformats)) {
  .plateformats[[format]]$map <- generate_wellnames(format)
  .plateformats[[format]]$wellnames <- .plateformats[[format]]$map$well
}

usethis::use_data(.plateformats, overwrite = TRUE, internal = TRUE)
