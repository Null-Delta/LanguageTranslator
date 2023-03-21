//
//  RPNTests.swift
//  RPNTests
//
//  Created by Delta Null on 16.03.2023.
//

import XCTest
import LanguageTranslator

final class RPNTests: XCTestCase {

    func convertTest(from: String, to: String) {
        let lexems = from
            .split(separator: " ")
            .compactMap { getLexem(for: String($0)) }
        
        let rpnLexems = RPNConvertor.convert(lexems: lexems)
        let result = rpnLexems.map { $0.value }.joined(separator: " ")

        print(result)
        print(to)
        
        XCTAssert(result == to)
    }
    
    func testNumbers() throws {
        LanguageTranslator.constaints = ["3","4","2","1","5"]
        LanguageTranslator.identifiers = []

        convertTest(
            from: "3 + 4 * 2 / ( 1 - 5 ) ^ 2 ;",
            to: "3 4 2 * 1 5 - 2 ^ / +"
        )
    }

    func testValues() throws {
        LanguageTranslator.constaints = ["5","2","1"]
        LanguageTranslator.identifiers = ["a","b","c","q"]

        convertTest(
            from: "a + b < - 5 & 2 - c == 1 + q ;",
            to: "a b + 5 - < 2 c - 1 q + == &"
        )
    }
    
    func testArrays() throws {
        LanguageTranslator.constaints = ["20"]
        LanguageTranslator.identifiers = ["a","b","c","d","i","j"]
        
        convertTest(
            from: "( a + b [ i + 20 , j ] ) * c + d ;",
            to: "a b i 20 + j 3 ARRIND + c * d +"
        )
    }
    
    func testFunctionCall() throws {
        LanguageTranslator.constaints = ["2"]
        LanguageTranslator.identifiers = ["x","y","z","f"]
        
        convertTest(
            from: "y - f ( x , z , y + 2 ) ;",
            to: "y f x z y 2 + 4 FCALL -"
        )
    }
    
    func testBlock() throws {
        LanguageTranslator.constaints = ["2", "3", "4", "5", "1", "8"]
        LanguageTranslator.identifiers = ["x"]
        
        convertTest(
            from: "{ 3 + 4 * 2 / ( 1 - 5 ) ^ 2 ; 2 + ( 8 - x ) ; { x - 1 ; } }",
            to: "3 4 2 * 1 5 - 2 ^ / + 2 8 x - + x 1 - 1 BLOCK 3 BLOCK"
        )
    }
}
