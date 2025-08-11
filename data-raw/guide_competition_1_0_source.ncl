let Version = std.contract.from_predicate (std.string.is_match "^\\d+\\.\\d+$")

in

let Nullable = fun Contract =>
  std.contract.custom
    (fun value =>
      if value == null then
        'Ok value
      else
        std.contract.check Contract value
    )

in

let Cell = std.contract.from_predicate (std.string.is_match "^[A-Z]\\d+$")

in

let Range = std.contract.from_predicate (std.string.is_match "^[A-Z]\\d+:[A-Z]\\d+$")

# in
# 
# let Range = std.contract.from_predicate (std.string.split ":")

in

let Variable = {
  cell | Cell,
  name | String
}

in

let Translation = {
  long  | String,
  short | String
}

in

let Atom = std.contract.from_predicate (fun value =>  
  std.array.elem value [ "character", "date", "numeric" ] 
)

in

let Location = {
  sheet       | String,
  varname     | String,
  type        | std.enum.TagOrString
              | [| 'cells, 'keyvalue, 'table, 'platedata |], 
  translate   | Bool
              | optional
              | default
              = false,
  variables   | Array Variable
              | optional,
  atomicclass | Array Atom
              | optional,
  ranges      | Array Range
              | optional
}

in

let Schema = {
  guide.version        | Version,
  locations            | Array Location,
  plate.format         | Number,
  template.max.version | Nullable (Version),
  template.min.version | Version,
  template.name        | String,
  translations         | Array Translation
}

in

{
  guide.version = "1.0",
  template.max.version = null,
  template.min.version = "9.3",
  template.name = "competition",
  plate.format = 96,
  locations = [
    {
      sheet = "description",
      translate = false,
      type = "cells",
      variables = [
        {
          cell = "B2",
          name = "version"
        }
      ],
      varname = ".template"
    },
    {
      atomicclass = [
        "character",
        "character",
        "character",
        "character",
        "character",
        "date",
        "character",
        "numeric",
        "character",
        "numeric",
        "character",
        "numeric",
        "character",
        "character"
      ],
      ranges = [
        "A10:B21",
        "A24:B25"
      ],
      sheet = "description",
      translate = true,
      type = "keyvalue",
      varname = "metadata"
    },
    {
      atomicclass = [
        "character",
        "numeric",
        "numeric",
        "numeric",
        "numeric",
        "numeric",
        "numeric",
        "character",
        "character",
        "character"
      ],
      ranges = [
        "A1:M9",
        "A11:M19",
        "A21:M29",
        "A31:M39",
        "A41:M49",
        "A51:M59",
        "A61:M69",
        "A71:M79",
        "A81:M89",
        "A91:M99"
      ],
      sheet = "_data",
      translate = false,
      type = "platedata",
      varname = "plate"
    },
    {
      ranges = [
        "A101:B111"
      ],
      sheet = "_data",
      translate = false,
      type = "table",
      varname = "rejections"
    },
    {
      atomicclass = [
        "numeric"
      ],
      ranges = [
        "A24:B24",
        "A27:B28",
        "A31:B32",
        "A35:B36"
      ],
      sheet = "_parameters",
      translate = false,
      type = "keyvalue",
      varname = "parameters"
    },
    {
      ranges = [
        "A39:B39"
      ],
      sheet = "_parameters",
      translate = false,
      type = "keyvalue",
      varname = "parameters"
    },
    {
      atomicclass = [
        "numeric"
      ],
      ranges = [
        "J3:M5"
      ],
      sheet = "concentration response",
      translate = false,
      type = "table",
      varname = "userresults"
    },
    {
      atomicclass = [
        "numeric"
      ],
      sheet = "BGfluo",
      translate = false,
      type = "cells",
      variables = [
        {
          cell = "G6",
          name = "spread.itm1"
        },
        {
          cell = "G33",
          name = "spread.itm2"
        }
      ],
      varname = "userchecks"
    },
    {
      sheet = "plate + experiment control",
      translate = false,
      type = "cells",
      variables = [
        {
          cell = "C27",
          name = "rfu.rc.ref"
        },
        {
          cell = "C28",
          name = "rfu.t4.ref"
        }
      ],
      varname = "userresults"
    }
  ],
  translations = [
    {
      "long" = "Version",
      "short" = "template.version"
    },
    {
      "long" = "Template Name",
      "short" = "template.name"
    },
    {
      "long" = "Study identifier",
      "short" = "studyID"
    },
    {
      "long" = "Experiment identifier",
      "short" = "exptID"
    },
    {
      "long" = "Plate identifier",
      "short" = "plateID"
    },
    {
      "long" = "Run identifier",
      "short" = "runID"
    },
    {
      "long" = "Instrument identifier",
      "short" = "instrID"
    },
    {
      "long" = "Experimenter name",
      "short" = "experimenter"
    },
    {
      "long" = "Date of experiment",
      "short" = "date"
    },
    {
      "long" = "Laboratory identifier",
      "short" = "labID"
    },
    {
      "long" = "Temperature (C)",
      "short" = "temp"
    },
    {
      "long" = "Item 1",
      "short" = "itm1ID"
    },
    {
      "long" = "Molar mass 1",
      "short" = "itm1Mw"
    },
    {
      "long" = "Run identifier 1",
      "short" = "run1ID"
    },
    {
      "long" = "Item 2",
      "short" = "itm2ID"
    },
    {
      "long" = "Molar mass 2",
      "short" = "itm2Mw"
    },
    {
      "long" = "Run identifier 2",
      "short" = "run2ID"
    }
  ]
} | Schema
