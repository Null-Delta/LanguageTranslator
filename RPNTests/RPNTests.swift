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
    
    func testAssignment() throws {
        LanguageTranslator.constaints = ["1", "2"]
        LanguageTranslator.identifiers = ["x", "y"]

        convertTest(
            from: "x = x + 1 ;",
            to: "x x 1 + ="
        )
        
        convertTest(
            from: "x = ( y - x ) / 2 ;",
            to: "x y x - 2 / ="
        )
        
        convertTest(
            from: "x = x < y ;",
            to: "x x y < ="
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
        
        convertTest(
            from: "a + b [ i + 20 , j ] * c ;",
            to: "a b i 20 + j 3 ARRIND c * +"
        )

        convertTest(
            from: "a + b [ i + 20 , j ] ;",
            to: "a b i 20 + j 3 ARRIND +"
        )
    }
    
    func testFunctionCall() throws {
        LanguageTranslator.constaints = ["2"]
        LanguageTranslator.identifiers = ["x","y","z","f"]
        
        convertTest(
            from: "y - f ( x , z , y + 2 ) ;",
            to: "y f x z y 2 + 4 FUNCALL -"
        )
        
        convertTest(
            from: "y - f ( ) ;",
            to: "y f 1 FUNCALL -"
        )
    }
    
    func testBlock() throws {
        LanguageTranslator.constaints = ["2", "3", "4", "5", "1", "8"]
        LanguageTranslator.identifiers = ["x"]
        
        convertTest(
            from: "{ 3 + 4 * 2 / ( 1 - 5 ) ^ 2 ; 2 + ( 8 - x ) ; { x - 1 ; } }",
            to: "3 4 2 * 1 5 - 2 ^ / + 2 8 x - + x 1 - 1 BLOCK 3 BLOCK"
        )
        
        convertTest(
            from: "{ { { x + 2 ; } { x + 3 ; } } }",
            to: "x 2 + 1 BLOCK x 3 + 1 BLOCK 2 BLOCK 1 BLOCK"
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
    
    func testVariableDeffinition() throws {
        LanguageTranslator.constaints = ["5", "\"Hello\"", "228", "\"Oleg\""]
        LanguageTranslator.identifiers = ["a", "b", "float", "c", "string", "abobus", "int", "array", "Student", "student"]
        
        convertTest(
            from: "float a ;",
            to: "float a 0 1 VARDEF"
        )
        
        convertTest(
            from: "public static float a ;",
            to: "float public static a 2 1 VARDEF"
        )
        
        convertTest(
            from: "private float a = 5 ;",
            to: "float private a 5 = 1 1 VARDEF"
        )
        
        convertTest(
            from: "public float a , b ;",
            to: "float public a b 1 2 VARDEF"
        )
        
        convertTest(
            from: "float a , b = 5 ;",
            to: "float a b 5 = 0 2 VARDEF"
        )
        
        convertTest(
            from: "public static float a = 5 , b = 5 ;",
            to: "float public static a 5 = b 5 = 2 2 VARDEF"
        )
        
        convertTest(
            from: """
            float a , b = 5 ;
            string c = "Hello" ;
            private int abobus = 228 ;
            """,
            to: "float a b 5 = 0 2 VARDEF string c \"Hello\" = 0 1 VARDEF int private abobus 228 = 1 1 VARDEF"
        )
        
        convertTest(
            from: "float a = new float ( ) ;",
            to: "float a float 1 OBJINIT = 0 1 VARDEF"
        )
        
        convertTest(
            from: "Student student = new Student ( \"Oleg\" ) ;",
            to: "Student student Student \"Oleg\" 2 OBJINIT = 0 1 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a ;",
            to: "float 1 ARRIND a 0 1 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a = new float [ 5 ] ;",
            to: "float 1 ARRIND a float 5 2 ARRIND 1 OBJINIT = 0 1 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a = new float [ 5 ] , b = new float [ 228 ] ;",
            to: "float 1 ARRIND a float 5 2 ARRIND 1 OBJINIT = b float 228 2 ARRIND 1 OBJINIT = 0 2 VARDEF"
        )
    }
    
    func testObjectCall() {
        LanguageTranslator.constaints = ["\"Hello\"", "5"]
        LanguageTranslator.identifiers = ["Console", "WriteLine", "color", "red"]

        convertTest(
            from: "Console . WriteLine ( \"Hello\" ) ;",
            to: "Console WriteLine \"Hello\" 2 FUNCALL CALL"
        )
        
        convertTest(
            from: "Console . color . red ;",
            to: "Console color CALL red CALL"
        )
        
        convertTest(
            from: "Console . color ( 5 ) . red ;",
            to: "Console color 5 2 FUNCALL CALL red CALL"
        )
        
        convertTest(
            from: "Console . color . red ( 5 ) ;",
            to: "Console color CALL red 5 2 FUNCALL CALL"
        )
        
        convertTest(
            from: "Console . color ( 5 ) . red ( 5 ) ;",
            to: "Console color 5 2 FUNCALL CALL red 5 2 FUNCALL CALL"
        )
    }
}
