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
#Version: string
#Version: =~"^\\d+\\.\\d+$" | _|_("Version must be in major.minor format (e.g., '1.0' or '2.3')")

// Valid plate formats for laboratory experiments
#Plateformat: 24 | 48 | 96 | 384 | _|_("Plate format must be one of: 24, 48, 96, or 384")

// Common fields shared by all location types
#AnyLocation: {
	// The Excel sheet name where this location is found
	"sheet"!: string

	// Variable name used to store the extracted data
	"varname"!: #VariableName

	// Whether to apply translations to extracted values (default: false)
	"translate"?: bool | *false

	// Allow additional fields for specific location types
	...
}

// Cell-based location: extracts data from individual named cells
#CellLocation: #AnyLocation & {
	// Type must be "cells" for cell-based locations
	"type"!: "cells"

	// List of variables to extract, each with a name and cell reference
	"variables"!: [...#Variable]

	// Optional atomic class specification for type coercion
	"atomicclass"?: #Atom | [...#Atom] | *"character"
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

	// Optional atomic class specification for type coercion
	"atomicclass"?: #Atom | [...#Atom] | *"character"
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

// Atomic data types for type coercion
#Atom: "character" | "date" | "numeric" | _|_("Atomic class must be one of: 'character', 'date', or 'numeric'")

// Valid spreadsheet range format (e.g., "A1:B10", "C5:Z20")
#Range: string
#Range: =~"^[A-Z]+\\d+:[A-Z]+\\d+$" | _|_("Range must be in format 'A1:B10' (uppercase letters followed by numbers)")

// Valid spreadsheet cell reference (e.g., "A1", "B23", "Z99")
#Cell: string
#Cell: =~"^[A-Z]+\\d+$" | _|_("Cell reference must be in format 'A1' (uppercase letters followed by numbers)")

// Variable names cannot contain whitespace characters
#VariableName: string
#VariableName: =~"[^\\s]" | _|_("Variable names cannot contain whitespace characters")
