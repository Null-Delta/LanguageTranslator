//
//  StaticLists.swift
//  LanguageTranslator
//
//  Created by Delta Null on 22.02.2023.
//

import Foundation

let serviceWords = [ "if", "else", "return", "for", "while", "static", "public", "using", "class", "void", "private", "protected", "new" ]

let operators = [ "+", "-", "=", "&", "|", "<", ">", "^", "!", "?", "*", "==", "++", "--", "+=", "-=", ">=", "<=", "!=", "/", "%" ]

let dividers = "[]{}(),.;:".map { String($0) }

public var identifiers: [String] = []
public var constaints: [String] = []

let specialDividers = ["\n", " ", "\t", ""]

let number = /[0-9]/

let symbol = /[a-zA-Z_]/

public func getLexem(for value: String) -> Lexem? {
    if let serviceWordIndex = serviceWords.firstIndex(of: value) {
        return Lexem(type: .serviceWord, index: serviceWordIndex)
    }
    
    if let operatorIndex = operators.firstIndex(of: value) {
        return Lexem(type: .operator, index: operatorIndex)
    }
    
    if let dividerIndex = dividers.firstIndex(of: value) {
        return Lexem(type: .divider, index: dividerIndex)
    }
    
    if let dividerIndex = dividers.firstIndex(of: value) {
        return Lexem(type: .divider, index: dividerIndex)
    }
    
    if let identifierIndex = identifiers.firstIndex(of: value) {
        return Lexem(type: .identifier, index: identifierIndex)
    }

    if let constantIndex = constaints.firstIndex(of: value) {
        return Lexem(type: .constaint, index: constantIndex)
    }

    return nil
}


public func getLexems(for values: [String]) -> [Lexem] {
    return values.compactMap { getLexem(for: $0) }
}

public func value(for lexem: Lexem) -> String {
    switch lexem.type {
    case .operator:
        return operators[lexem.index]
    case .divider:
        return dividers[lexem.index]
    case .serviceWord:
        return serviceWords[lexem.index]
    case .identifier:
        return identifiers[lexem.index]
    case .constaint:
        return constaints[lexem.index]
    }
}
