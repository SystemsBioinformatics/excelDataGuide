// usage: cue vet -c schema.cue file.yml

"guide.version"!        : #Version
"template.name"!        : string
"template.min.version"! : #Version
"template.max.version"! : #Version | null
"plate.format"!         : #Plateformat
"locations"!            : [...#Location]
"translations"          : [...#Translation]

#Version: =~ "^\\d+\\.\\d+$" // Only version numbers in major.minor format allowed

#Plateformat: 24 | 48 | 96 | 384

//#AnyLocation: {
//    "sheet"!       : string
//    "varname"!     : #VariableName
//    "translate"?   : bool | *false
//    "atomicclass"? : #Atom | [...#Atom] | *"character"
//}

//#CellLocation: {
//     "type"!     : "cells"
//   "variables"! : [...#Variable]
//    ...
//}

//#RangeLocation: {
//    "type"!   : "keyvalue" | "platedata" | "table"
//    "ranges"! : [...#Range]
//    ...
//}

// This does not work:
// #Location: #AnyLocation & {#CellLocation | #RangeLocation}

#Location: {
   "sheet"!        : string
    "varname"!     : #VariableName
    "translate"?   : bool | *false
    "type"!        : "cells"
    "variables"!   : [...#Variable]
    "atomicclass"? : #Atom | [...#Atom] | *"character"
} | {
    "sheet"!       : string
    "varname"!     : #VariableName
    "translate"?   : bool | *false
    "type"!        : "keyvalue" | "platedata" | "table"
    "ranges"!      : [...#Range]
    "atomicclass"? : #Atom | [...#Atom] | *"character"
}

#Variable: {
    "name"! : #VariableName
    "cell"! : #Cell
}

#Translation: {
    "short"! : string
    "long"!  : string
}

#Atom : "character" | "date" | "numeric"

#Range : =~ "^[A-Z]\\d+:[A-Z]\\d+$" // Valid spreadsheed range value required

#Cell : =~ "^[A-Z]\\d+$" // Valid spreadsheed cell value required

#VariableName : =~ "[^\\s]" // variable names are not allowed to contain space-like characters
