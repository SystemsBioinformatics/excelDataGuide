# Once only

source <- yaml::read_yaml("data-raw/guide_competition_9_3_source.yml")

jsonlite::write_json(source,
                     path="data-raw/guide_competition_9_3_source.json",
                     pretty = TRUE,
                     auto_unbox = TRUE)
