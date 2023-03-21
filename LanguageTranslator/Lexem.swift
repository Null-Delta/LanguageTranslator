//
//  Lexem.swift
//  LanguageTranslator
//
//  Created by Delta Null on 15.03.2023.
//

import Foundation

public enum LexemType {
    case serviceWord, identifier, constaint, divider, `operator`
}

public struct Lexem {
    public var type: LexemType
    public var index: Int
    
    public init(type: LexemType, index: Int) {
        self.type = type
        self.index = index
    }
}

extension Lexem: Equatable {
    
}
