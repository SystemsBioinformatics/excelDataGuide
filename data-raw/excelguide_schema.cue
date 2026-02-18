// usage: cue vet -c schema.cue file.yml

// Excel Data Guide Schema
// This schema validates Excel template guide files that describe how to extract
// data from Excel workbooks with specific template formats.

// Top-level required fields
"guide.version"!:        #Version
"template.name"!:        string
"template.min.version"!: #Version
"template.max.version"!: #Version | null
"plate.format"!:         #Plateformat
"locations"!: [...#Location]
"translations": [...#Translation]

// Version constraint: must be in major.minor format (e.g., "1.0", "2.3")
#Version: =~"^\\d+\\.\\d+$"

// Valid plate formats for laboratory experiments (must be one of: 24, 48, 96, or 384)
#Plateformat: 24 | 48 | 96 | 384

// Common fields shared by all location types
#AnyLocation: {
	// The Excel sheet name where this location is found
	"sheet"!: string

	// Variable name used to store the extracted data
	"varname"!: #VariableName

	// Whether to apply translations to extracted values (default: false)
	"translate"?: bool | *false

	// Optional atomic class specification for type coercion
	"atomicclass"?: #Atom | [...#Atom] | *"character"

	// Allow additional fields for specific location types
	...
}

// Cell-based location: extracts data from individual named cells
#CellLocation: #AnyLocation & {
	// Type must be "cells" for cell-based locations
	"type"!: "cells"

	// List of variables to extract, each with a name and cell reference
	"variables"!: [...#Variable]
}

// Range-based location: extracts data from rectangular ranges
#RangeLocation: #AnyLocation & {
	// Type specifies how to interpret the range data
	// - keyvalue: key-value pairs in two columns
	// - platedata: structured plate data with multiple wells
	// - table: tabular data with headers
	"type"!: "keyvalue" | "platedata" | "table"

	// List of cell ranges to extract (e.g., "A1:B10")
	"ranges"!: [...#Range]
}

// A location can be either cell-based or range-based
#Location: #CellLocation | #RangeLocation

// Variable definition for cell-based locations
#Variable: {
	// Variable name for storing the extracted value
	"name"!: #VariableName

	// Cell reference where the value is located (e.g., "A1", "B23")
	"cell"!: #Cell
}

// Translation mapping between short and long variable names
#Translation: {
	// Short name used in the data structure
	"short"!: string

	// Long, human-readable description
	"long"!: string
}

// Atomic data types for type coercion (must be one of: 'character', 'date', or 'numeric')
#Atom: "character" | "date" | "numeric"

// Valid spreadsheet range format (e.g., "A1:B10", "C5:Z20")
// Must be uppercase letters followed by numbers, colon, then uppercase letters followed by numbers
#Range: =~"^[A-Z]+\\d+:[A-Z]+\\d+$"

// Valid spreadsheet cell reference (e.g., "A1", "B23", "Z99")
// Must be uppercase letters followed by numbers
#Cell: =~"^[A-Z]+\\d+$"

// Variable names cannot contain whitespace characters
#VariableName: =~"[^\\s]"
