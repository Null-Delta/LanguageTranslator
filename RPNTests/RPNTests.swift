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
            .replacing("\n", with: " ")
            .replacing("\t", with: "")
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
     
    func testIf() throws {
        LanguageTranslator.constaints = ["2", "3", "4", "5", "1", "8"]
        LanguageTranslator.identifiers = ["a", "b", "c", "d"]
        
        convertTest(
            from: """
            if ( a + b > 5 ) {
                a + 5 ;
            }
            """,
            to: "a b + 5 > LBL0 IF a 5 + 1 BLOCK LBL0 :"
        )
        
        convertTest(
            from: """
            if ( a + b > 5 ) {
                a + 5 ;
            } else {
                b + 5 ;
            }
            """,
            to: "a b + 5 > LBL0 IF a 5 + 1 BLOCK LBL1 GOTO LBL0 : b 5 + 1 BLOCK LBL1 :"
        )
        
        convertTest(
            from: """
            if ( a + b > 5 ) {
                a + 5 ;
            }
            """,
            to: "a b + 5 > LBL0 IF a 5 + 1 BLOCK LBL0 :"
        )
        
        convertTest(
            from: """
            if ( a > b ) {
                if ( c > d ) {
                    a + c ;
                }
            } else {
                if ( c > d ) {
                    b + c ;
                }
            }
            """,
            to: "a b > LBL0 IF c d > LBL1 IF a c + 1 BLOCK LBL1 : 1 BLOCK LBL2 GOTO LBL0 : c d > LBL3 IF b c + 1 BLOCK LBL3 : 1 BLOCK LBL2 :"
        )
        
        convertTest(
            from: """
            if ( a > b ) {
                if ( c > d ) {
                    a + c ;
                }
            } else {
                if ( c > d ) {
                    b + c ;
                } else {
                    b + d ;
                }
            }
            """,
            to: "a b > LBL0 IF c d > LBL1 IF a c + 1 BLOCK LBL1 : 1 BLOCK LBL2 GOTO LBL0 : c d > LBL3 IF b c + 1 BLOCK LBL4 GOTO LBL3 : b d + 1 BLOCK LBL4 : 1 BLOCK LBL2 :"
        )
        
        convertTest(
            from: """
            if ( a > b ) {
                if ( c > d ) {
                    a + c ;
                } else {
                    a + d ;
                }
            } else {
                if ( c > d ) {
                    b + c ;
                }
            }
            """,
            to: "a b > LBL0 IF c d > LBL1 IF a c + 1 BLOCK LBL2 GOTO LBL1 : a d + 1 BLOCK LBL2 : 1 BLOCK LBL3 GOTO LBL0 : c d > LBL4 IF b c + 1 BLOCK LBL4 : 1 BLOCK LBL3 :"
        )
        
        convertTest(
            from: """
            if ( a > b ) {
                if ( c > d ) {
                    a + c ;
                } else {
                    a + d ;
                }
            } else {
                if ( c > d ) {
                    b + c ;
                } else {
                    b + d ;
                }
            }
            """,
            to: "a b > LBL0 IF c d > LBL1 IF a c + 1 BLOCK LBL2 GOTO LBL1 : a d + 1 BLOCK LBL2 : 1 BLOCK LBL3 GOTO LBL0 : c d > LBL4 IF b c + 1 BLOCK LBL5 GOTO LBL4 : b d + 1 BLOCK LBL5 : 1 BLOCK LBL3 :"
        )
    }
}
