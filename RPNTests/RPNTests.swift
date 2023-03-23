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

        print("from: \(from)")
        print("to: \(to)")
        print("result: \(result)")
        print()
        
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
            from: "a + b [ i + 20 , j ] * c ;",
            to: "a b i 20 + j 2 LIST ARRIND c * +"
        )
        
        convertTest(
            from: "( a + b [ j ] ) * c + d ;",
            to: "a b j ARRIND + c * d +"
        )

        convertTest(
            from: "( a + b [ i + 20 , j ] ) * c + d ;",
            to: "a b i 20 + j 2 LIST ARRIND + c * d +"
        )

        convertTest(
            from: "a + b [ i + 20 , j ] ;",
            to: "a b i 20 + j 2 LIST ARRIND +"
        )
    }
    
    func testFunctionCall() throws {
        LanguageTranslator.constaints = ["2"]
        LanguageTranslator.identifiers = ["x","y","z","f"]
        
        convertTest(
            from: "y - f ( x , z , y + 2 ) ;",
            to: "y f x z y 2 + 3 LIST FUNCALL -"
        )
        
        convertTest(
            from: "y - f ( ) ;",
            to: "y f EMPTY FUNCALL -"
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
            to: "float a 0 VARDEF"
        )
        
        convertTest(
            from: "public static float a ;",
            to: "float static public a 2 VARDEF"
        )
        
        convertTest(
            from: "private float a = 5 ;",
            to: "float private a 5 = 1 VARDEF"
        )
        
        convertTest(
            from: "public float a , b ;",
            to: "float public a b 2 LIST 1 VARDEF"
        )
        
        convertTest(
            from: "float a , b = 5 ;",
            to: "float a b 5 = 2 LIST 0 VARDEF"
        )
        
        convertTest(
            from: "public static float a = 5 , b = 5 ;",
            to: "float static public a 5 = b 5 = 2 LIST 2 VARDEF"
        )
        
        convertTest(
            from: """
            float a , b = 5 ;
            string c = "Hello" ;
            private int abobus = 228 ;
            """,
            to: "float a b 5 = 2 LIST 0 VARDEF string c \"Hello\" = 0 VARDEF int private abobus 228 = 1 VARDEF"
        )
        
        convertTest(
            from: "float a = new float ( ) ;",
            to: "float a float EMPTY OBJINIT = 0 VARDEF"
        )
        
        convertTest(
            from: "Student student = new Student ( \"Oleg\" ) ;",
            to: "Student student Student \"Oleg\" OBJINIT = 0 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a ;",
            to: "float EMPTY ARRIND a 0 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a = new float [ 5 ] ;",
            to: "float EMPTY ARRIND a float 5 ARRIND EMPTY OBJINIT = 0 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a = new float [ 5 ] , b = new float [ 228 ] ;",
            to: "float EMPTY ARRIND a float 5 ARRIND EMPTY OBJINIT = b float 228 ARRIND EMPTY OBJINIT = 2 LIST 0 VARDEF"
        )
        
        convertTest(
            from: "float [ ] a = { 5 , 5 , 5 , 5 , 5 } ;",
            to: "float EMPTY ARRIND a 5 5 5 5 5 5 LIST 1 BLOCK = 0 VARDEF"
        )
    }
    
    func testObjectCall() {
        LanguageTranslator.constaints = ["\"Hello\"", "5"]
        LanguageTranslator.identifiers = ["Console", "WriteLine", "color", "red"]

        convertTest(
            from: "Console . WriteLine ( \"Hello\" ) ;",
            to: "Console WriteLine \"Hello\" FUNCALL CALL"
        )
        
        convertTest(
            from: "Console . color . red ;",
            to: "Console color CALL red CALL"
        )
        
        convertTest(
            from: "Console . color ( 5 ) . red ;",
            to: "Console color 5 FUNCALL CALL red CALL"
        )
        
        convertTest(
            from: "Console . color . red ( 5 ) ;",
            to: "Console color CALL red 5 FUNCALL CALL"
        )
        
        convertTest(
            from: "Console . color ( 5 ) . red ( 5 ) ;",
            to: "Console color 5 FUNCALL CALL red 5 FUNCALL CALL"
        )
    }
    
    func testFunctionDefinition() {
        LanguageTranslator.constaints = ["5"]
        LanguageTranslator.identifiers = ["a", "b", "void", "main", "string", "int"]

        convertTest(
            from: "public static void main ( int a , string b ) { a = 5 ; }",
            to: "void main static public int a 0 VARDEF string b 0 VARDEF 2 LIST a 5 = 1 BLOCK 2 FUNCDEF"
        )

        convertTest(
            from: "public static void main ( int a = 5 , string b ) { a = 5 ; }",
            to: "void main static public int a 5 = 0 VARDEF string b 0 VARDEF 2 LIST a 5 = 1 BLOCK 2 FUNCDEF"
        )

        convertTest(
            from: "public static void main ( int a = 5 ) { a = 5 ; }",
            to: "void main static public int a 5 = 0 VARDEF a 5 = 1 BLOCK 2 FUNCDEF"
        )
        
        convertTest(
            from: "public static void main ( ) { a = 5 ; }",
            to: "void main static public EMPTY a 5 = 1 BLOCK 2 FUNCDEF"
        )
        
        convertTest(
            from: "public static void main ( int [ ] a ) { a = 5 ; }",
            to: "void main static public int EMPTY ARRIND a 1 VARDEF a 5 = 1 BLOCK 2 FUNCDEF"
        )

    }
    
    func testWhileLoop() {
        LanguageTranslator.constaints = ["1"]
        LanguageTranslator.identifiers = ["a", "b", "true"]

        convertTest(
            from: "while ( a > b ) { a = a + 1 ; } ;",
            to: "a b > a a 1 + = 1 BLOCK WHILE"
        )
        
        convertTest(
            from: "while ( true ) { } ;",
            to: "true 0 BLOCK WHILE"
        )
    }
    
    func testForLoop() {
        LanguageTranslator.constaints = ["0", "10", "1"]
        LanguageTranslator.identifiers = ["i", "Console", "WriteLine", "int", "x", "y"]

        convertTest(
            from: "for ( int i = 0 ; i < 10 ; i = i + 1 ) { Console . WriteLine ( i ) ; }",
            to: "int i 0 = 0 VARDEF i 10 < i i 1 + = Console WriteLine i FUNCALL CALL 1 BLOCK FOR"
        )
        
        convertTest(
            from: "for ( ; ; ) { Console . WriteLine ( i ) ; }",
            to: "EMPTY EMPTY EMPTY Console WriteLine i FUNCALL CALL 1 BLOCK FOR"
        )

        convertTest(
            from: """
            for ( int x = 0 ; x < 10 ; x = x + 1 ) {
                for ( int y = 0 ; y < 10 ; y = y + 1 ) {
                    Console . WriteLine ( x + y ) ;
                }
            }
            """,
            to: "int x 0 = 0 VARDEF x 10 < x x 1 + = int y 0 = 0 VARDEF y 10 < y y 1 + = Console WriteLine x y + FUNCALL CALL 1 BLOCK FOR 1 BLOCK FOR"
        )
    }
    
    func testClassDefinition() {
        LanguageTranslator.constaints = ["5", "123"]
        LanguageTranslator.identifiers = ["Main", "a", "main", "void", "Console", "WriteLine", "int"]

        convertTest(
            from: """
            class Main {
                int a = 5 ;
            
                public static void main ( ) {
                    Console . WriteLine ( 123 ) ;
                }
            }
            """,
            to: "Main int a 5 = 0 VARDEF void main static public EMPTY Console WriteLine 123 FUNCALL CALL 1 BLOCK 2 FUNCDEF 2 BLOCK 0 CLASS"
        )
    }
    
    func testListDefinition() {
        LanguageTranslator.constaints = ["5", "3", "10"]
        LanguageTranslator.identifiers = ["a", "b", "c", "int"]

        convertTest(
            from: "a , b , c ;",
            to: "a b c 3 LIST"
        )
        
        convertTest(
            from: "( a , b , c ) ;",
            to: "a b c 3 LIST"
        )
        
        convertTest(
            from: "{ a , b , c } ;",
            to: "a b c 3 LIST 1 BLOCK"
        )

        convertTest(
            from: "int a , b = 5 , c = 10 ;",
            to: "int a b 5 = c 10 = 3 LIST 0 VARDEF"
        )
        
        convertTest(
            from: "( int a , int b = 5 , int c ) ;",
            to: "int a 0 VARDEF int b 5 = 0 VARDEF int c 0 VARDEF 3 LIST"
        )
    }
    
    func testComplex() {
        let sourceCode = """
        class Program
        {
            int a = 5;
        
            static void Main()
            {
                write();
            }
        
            public void write()
            {
                Console.WriteLine(a);
                Console.ReadKey();
            }
        }
        """
        
        var lexems: [Lexem] = []
        
        let analyzer = LexicalAnalyzer()
        analyzer.updateProcedures(procedures: [
            { _ in },
            
            { buffer in
                if !identifiers.contains(buffer) { identifiers.append(buffer) }
                let identifierIndex = identifiers.firstIndex(of: buffer)!
                
                lexems.append(Lexem(type: .identifier, index: identifierIndex))
            },
            
            { buffer in
                if let serviceIndex = serviceWords.firstIndex(of: buffer) {
                    lexems.append(Lexem(type: .serviceWord, index: serviceIndex))
                } else {
                    if !identifiers.contains(buffer) { identifiers.append(buffer) }
                    let identifierIndex = identifiers.firstIndex(of: buffer)!
                    
                    lexems.append(Lexem(type: .identifier, index: identifierIndex))
                }
            },
            
            { buffer in
                if !constaints.contains(buffer) { constaints.append(buffer) }
                let constantIndex = constaints.firstIndex(of: buffer)!
                
                lexems.append(Lexem(type: .constaint, index: constantIndex))
            },
            
            { _ in },
            
            { buffer in
                if !constaints.contains(buffer) { constaints.append(buffer) }
                let constantIndex = constaints.firstIndex(of: buffer)!
                
                lexems.append(Lexem(type: .constaint, index: constantIndex))
            },
            
            { buffer in
                if let dividerIndex = dividers.firstIndex(of: buffer) {
                    lexems.append(Lexem(type: .divider, index: dividerIndex))
                }
            },
            
            { buffer in
                if let operatorIndex = operators.firstIndex(of: buffer) {
                    lexems.append(Lexem(type: .operator, index: operatorIndex))
                }
            }
        ])
        
        analyzer.process(symbols: sourceCode)
        
        print(identifiers)
        print(constaints)
        
        print(lexems.map { LanguageTranslator.value(for: $0) })
        
        print(RPNConvertor.convert(lexems: lexems).map { $0.value }.joined(separator: " "))
    }
}
