//
//  LexicalAnalyzer.swift
//  LanguageTranslator
//
//  Created by Delta Null on 22.02.2023.
//

import Foundation

import Foundation

class LexicalAnalyzer: ObservableObject {
    
    typealias State = (String) -> (Int, Int?)
    
    // Номер состояния ->  (Новое состояние, семантическая процедура)
    private var states: [Int: State] = [:]
    
    // Лексические процедуры
    private var lexicalProcedures: [(String) -> Void] = []
    
    // Буффер
    private var buffer: String = ""
    
    private var processingSymbols: String = ""
    
    // Индекс текущего состояния
    private var currentStateIndex: Int = 0
        
    private var currentState: (String) -> (Int, Int?) {
        return states[currentStateIndex]!
    }
    
    init() {
        self.currentStateIndex = 0
        self.states = generateStates()
    }
    
    func process(symbols: String) {
        processingSymbols = symbols
        currentStateIndex = 0
        buffer = ""
        
        while processStep() { }
    }
    
    func setupSumbols(symbols: String) {
        processingSymbols = symbols
    }
    
    func processStep() -> Bool {
        guard processingSymbols.count != 0 else {
            let (nextState, functionIndex) = currentState("")
            currentStateIndex = nextState
            lexicalProcedures[functionIndex!](buffer)
            buffer = ""
            return false
        }
        
        let char = String(processingSymbols.first!)
        
        let (nextState, functionIndex) = currentState(char)
        
        currentStateIndex = nextState
        
        if let functionIndex {
            if functionIndex == 0 {
                lexicalProcedures[functionIndex](char)
                buffer = ""
                processingSymbols = String(processingSymbols.dropFirst())
            } else {
                lexicalProcedures[functionIndex](buffer)
                buffer = ""
            }
        } else {
            buffer += char
            processingSymbols = String(processingSymbols.dropFirst())
        }
        
        return true
    }
    
    func updateProcedures(procedures: [(String) -> Void]) {
        lexicalProcedures = procedures
    }
}


func ~=(regex: Regex<Substring>, str: String) -> Bool {
    (try? regex.wholeMatch(in: str)) != nil
}

func ~=(array: [String], str: String) -> Bool {
    array.contains(str)
}

func ~=(not: Not<[String]>, str: String) -> Bool {
    !not.value.contains(str)
}

func ~=(not: Not<Regex<Substring>>, str: String) -> Bool {
    (try? not.value.wholeMatch(in: str)) == nil
}

func ~=(not: Not<String>, str: String) -> Bool {
    not.value != str
}

class Not<A> {
    var value: A
    init(_ value: A) {
        self.value = value
    }
}

extension LexicalAnalyzer {
    private func generateStates() -> [Int: State] {
        return [
            0: { char in
                switch char {
                    
                case specialDividers: return (0, 0)
                case symbol: return (1, nil)
                case number: return (3, nil)
                case ".": return (4, nil)
                case "/": return (7, nil)
                case "\"": return (12, nil)
                case dividers: return (14, nil)
                case operators: return (15, nil)
                    
                default:
                    fatalError()
                }
            },
            
            1: { char in
                switch char {
                case symbol: return (1, nil)
                case number: return (2, nil)
                case Not(symbol), Not(number): return (0, 2)
                default: fatalError()
                }
            },
            
            2: { char in
                switch char {
                case number, symbol: return (2, nil)
                default: return (0, 1)
                }
            },
            
            3: { char in
                switch char {
                case number: return (3, nil)
                case ".": return (4, nil)
                case "e", "E": return (5, nil)
                case Not(number), Not("e"), Not("E"): return (0, 3)
                default: fatalError()
                }
            },
            
            4: { char in
                switch char {
                case number: return (6, nil)
                case "e", "E": return (5, nil)
                case symbol, dividers, operators, specialDividers: return (0, 6)
                case Not("e"), Not("E"): return (0, 3)
                default: fatalError()
                }
            },
            
            5: { char in
                switch char {
                case "+", "-", number: return (6, nil)
                default: fatalError()
                }
            },
            
            6: { char in
                switch char {
                case number: return (6, nil)
                default: return (0, 3)
                }
            },
            
            7: { char in
                switch char {
                case "/": return (10, nil)
                case "*": return (8, nil)
                default: fatalError()
                }
            },
            
            8: { char in
                switch char {
                case "*": return (9, nil)
                default: return (8, nil)
                }
            },
            
            9: { char in
                switch char {
                case "/": return (11, nil)
                default: return (8, nil)
                }
            },
            
            10: { char in
                switch char {
                case "\n": return (11, nil)
                default: return (10, nil)
                }
            },
            
            11: { _ in return (0, 4) },
            
            12: { char in
                switch char {
                case "\"": return (13, nil)
                default: return (12, nil)
                }
            },
            
            13: { _ in return (0, 5) },
            
            14: { char in
                return (0, 6)
            },
            
            15: { char in
                switch char {
                case operators: return (15, nil)
                default: return (0, 7)
                }
            }
        ]
    }
}
