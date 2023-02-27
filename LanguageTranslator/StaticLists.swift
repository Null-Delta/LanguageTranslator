//
//  StaticLists.swift
//  LanguageTranslator
//
//  Created by Delta Null on 22.02.2023.
//

import Foundation

let serviceWords = [ "if", "else", "return", "for", "while", "static", "public", "using", "class", "void", "private", "protected", "int", "float", "double", "new", "string" ]

let operators = [ "+", "-", "=", "&", "|", "<", ">", "^", "!", "?", "==", "++", "--", "+=", "-=", ">=", "<=", "!=" ]

let dividers = "[]{}(),.;".map { String($0) }

let specialDividers = ["\n", " ", "\t" ]

let number = /[0-9]/

let symbol = /[a-zA-Z_]/
