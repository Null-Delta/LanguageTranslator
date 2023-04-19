//
//  DecoderTests.swift
//  DecoderTests
//
//  Created by Delta Null on 05.04.2023.
//

import XCTest
import LanguageTranslator

final class DecoderTests: XCTestCase {

    func convertTest(from: String, to: String) -> [RPNToken] {
        let lexems = from
            .replacing("\n", with: " ")
            .replacing("\t", with: "")
            .split(separator: " ")
            .compactMap { getLexem(for: String($0)) }
        
        return RPNConvertor.convert(lexems: lexems)
    }

    
    func testExample() throws {
        LanguageTranslator.constaints = ["0", "1", "100"]
        LanguageTranslator.identifiers = ["int", "from", "to", "sum", "result", "iterator"]

        let tokens = convertTest(
            from: """
            int sum ( int from , int to ) {
                int result = 0 ;
                int iterator = from ;
                while ( iterator <= to ) {
                    result += iterator ;
                    iterator += 1 ;
                } ;
                return result ;
            }
            
            sum ( 1 , 100 ) ;
            """,
            to: "3 4 2 * 1 5 - 2 ^ / +"
        )
        
        print(LanguageTranslator.RPNDecoder.decode(tokens: tokens))
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
