//
//  RPNConvertor.swift
//  LanguageTranslator
//
//  Created by Delta Null on 15.03.2023.
//

import Foundation

public enum RPNToken {
    case lexem(Lexem)
    case arrayOperator
    case callFunction
    case label(Int)
    case falseIfMove
    case justMove
    case block(Int)
    case objectInitialization
    case call
    case whileLoop
    case forLoop
    case list(Int)
    case classDefinition(Int)
    case empty
    case variableDefinition(Int)
    case functionDefinition(Int)

    public var value: String {
        switch self {
        case .lexem(let lexem):
            return LanguageTranslator.value(for: lexem)
            
        case .arrayOperator:
            return "ARRIND"
            
        case .callFunction:
            return "FUNCALL"
            
        case .label(let index):
            return "LBL\(index)"

        case .falseIfMove:
            return "IF"
            
        case .justMove:
            return "GOTO"
            
        case .block(let count):
            return "\(count) BLOCK"
            
        case .variableDefinition(let countOfAccessTypes):
            return "\(countOfAccessTypes) VARDEF"

        case .functionDefinition(let countOfAccessTypes):
            return "\(countOfAccessTypes) FUNCDEF"

        case .objectInitialization:
            return "OBJINIT"
            
        case .call:
            return "CALL"
            
        case .whileLoop:
            return "WHILE"
            
        case .forLoop:
            return "FOR"
            
        case .list(let count):
            return "\(count) LIST"
            
        case .empty:
            return "EMPTY"
            
        case .classDefinition(let count):
            return "\(count) CLASS"
        }
    }
    
    public var priority: Int {
        switch self {
        case
                .lexem(getLexem(for: "(")),
                .lexem(getLexem(for: "[")),
                .lexem(getLexem(for: "{")),
                .lexem(getLexem(for: "if")),
                .lexem(getLexem(for: "else")),
                .variableDefinition,
                .functionDefinition,
                .objectInitialization,
                .classDefinition,
                .arrayOperator,
                .callFunction,
                .whileLoop,
                .forLoop,
                .empty,
                .block,
                .call,
                .list:
            return 0
            
        case
                .lexem(getLexem(for: ")")),
                .lexem(getLexem(for: ";")),
                .lexem(getLexem(for: "}")),
                .lexem(getLexem(for: "]")),
                .lexem(getLexem(for: ",")):
            return 1
            
        case .lexem(getLexem(for: "=")):
            return 2
            
        case .lexem(getLexem(for: "|")):
            return 3
            
        case .lexem(getLexem(for: "&")):
            return 4
            
        case .lexem(getLexem(for: "!")):
            return 5
            
        case
            .lexem(getLexem(for: "<")),
            .lexem(getLexem(for: ">")),
            .lexem(getLexem(for: "==")),
            .lexem(getLexem(for: "!=")),
            .lexem(getLexem(for: "<=")),
            .lexem(getLexem(for: ">=")):
            return 6

        case .lexem(getLexem(for: "+")), .lexem(getLexem(for: "-")):
            return 7

        case .lexem(getLexem(for: "*")), .lexem(getLexem(for: "/")):
            return 8
            
        case .lexem(getLexem(for: "^")):
            return 9
            
        default:
            return 100
        }
    }
}



public class RPNConvertor {
    private init() { }
    
    public static func convert(lexems: [Lexem]) -> [RPNToken] {
        var unprocessedLexems = lexems
        var processedLexems: [Lexem] = []
                
        var stack: [RPNToken] = []
        var result: [RPNToken] = []
        
        var unclosedLabels: [Int] = []
        var labelCounter: Int = 0
        
        var unclosedBacketsCount = 0
        
        while !unprocessedLexems.isEmpty {
            
            let lexem = unprocessedLexems[0]

//            print(value(for: lexem))
//            print(stack.map { $0.value })
//            print(result.map { $0.value })
//            print(processedLexems.map { value(for: $0) })
//            print()

            
            switch lexem.type {
            case .constaint:
                result.append(.lexem(lexem))

            case .identifier:
                if
                    case .lexem(let lex) = result.last,
                    lex.type == .identifier,
                    !stack.contains(where: { $0.value.contains("VARDEF") })
                {
                    let operatorsCount = stack.filter {
                        if case .lexem(let lex) = $0 {
                            return lex.type == .operator
                        } else if case .call = $0 {
                            return true
                        } else {
                            return false
                        }
                    }.count
                    
                    if unprocessedLexems[1] == getLexem(for: "(") && operatorsCount == 0  {
                        let accessCount = stack.filter {
                            if case .lexem(let lex) = $0 {
                                return lex.type == .serviceWord
                            } else {
                                return false
                            }
                        }.count
                        result.append(.lexem(lexem))

                        while !stack.isEmpty && stack.last!.priority > 0 { result.append(stack.removeLast()) }

                        stack.append(.functionDefinition(accessCount))
                    } else if processedLexems.last!.type == .identifier {
                        let accessCount = stack.filter {
                            if case .lexem(let lex) = $0 {
                                return lex.type == .serviceWord
                            } else {
                                return false
                            }
                        }.count
                        
                        while !stack.isEmpty && stack.last!.priority > 0 { result.append(stack.removeLast()) }
                        result.append(.lexem(lexem))
                        stack.append(.variableDefinition(accessCount))
                    } else {
                        result.append(.lexem(lexem))
                    }
                } else if case .arrayOperator = result.last, processedLexems[processedLexems.count - 2] == getLexem(for: "[") {
                    let accessCount = stack.count
                    
                    while !stack.isEmpty && stack.last!.priority > 0 { result.append(stack.removeFirst()) }
                    result.append(.lexem(lexem))
                    stack.append(.variableDefinition(accessCount))

                } else {
                    result.append(.lexem(lexem))
                }
                

            case .serviceWord:
                switch lexem {
                case getLexem(for: "for"):
                    stack.append(.forLoop)
                    
                case getLexem(for: "class"):
                    let accessCount = stack.filter {
                        if case .lexem(let lex) = $0 {
                            return lex.type == .serviceWord
                        } else {
                            return false
                        }
                    }.count
                    
                    while !stack.isEmpty && stack.last!.priority > 0 { result.append(stack.removeLast()) }

                    stack.append(.classDefinition(accessCount))

                case getLexem(for: "while"):
                    stack.append(.whileLoop)
                    
                case getLexem(for: "new"):
                    stack.append(.lexem(lexem))
                    
                case getLexem(for: "if"):
                    stack.append(.falseIfMove)
                    
                case getLexem(for: "else"):
                    if case .block(let count) = stack.last {
                        stack[stack.count - 1] = .block(count - 1)
                    }
                    
                    result.append(.label(labelCounter))
                    result.append(.justMove)
                    result.append(.label(unclosedLabels.last!))
                    result.append(.lexem(getLexem(for: ":")!))
                    
                    unclosedLabels.removeLast()
                    unclosedLabels.append(labelCounter)
                    labelCounter += 1

                default:
                    stack.append(.lexem(lexem))
                }
                
            case .operator:
                if stack.isEmpty {
                    stack.append(.lexem(lexem))
                } else if stack.last!.priority < RPNToken.lexem(lexem).priority {
                    stack.append(.lexem(lexem))
                } else if stack.last!.priority >= RPNToken.lexem(lexem).priority {
                    while !stack.isEmpty && stack.last!.priority >= RPNToken.lexem(lexem).priority {
                        result.append(stack.removeLast())
                    }
                    stack.append(.lexem(lexem))
                }
                
            case .divider:
                switch lexem {
                case getLexem(for: "."):
                    if case .call = stack.last {
                        result.append(stack.removeLast())
                    }
                    stack.append(.call)
                    
                case getLexem(for: ","):
                    while !stack.isEmpty &&
                            (
                                !stack.last!.value.contains("ARRIND") &&
                                !stack.last!.value.contains("FUNCALL") &&
                                !stack.last!.value.contains("BLOCK") &&
                                !stack.last!.value.contains("VARDEF") &&
                                !stack.last!.value.contains("LIST") &&
                                !stack.last!.value.contains("(")
                            )
                    {
                        result.append(stack.removeLast())
                    }
                    
                    if case .variableDefinition = stack.last, unclosedBacketsCount != 0 {
                        result.append(stack.removeLast())
                    }

                    if case .list(let count) = stack.last {
                        stack[stack.count - 1] = .list(count + 1)
                    } else {
                        stack.append(.list(2))

                    }
                    
                case getLexem(for: "{"):
                    if case .falseIfMove = stack.last {
                        result.append(.label(labelCounter))
                        unclosedLabels.append(labelCounter)
                        labelCounter += 1
                        result.append(stack.removeLast())
                    }
                    stack.append(.block(0));
                    
                case getLexem(for: "["):
                    stack.append(.arrayOperator)
                    
                case getLexem(for: "("):
                    unclosedBacketsCount += 1
                    
                    if
                        !result.isEmpty,
                        let lex = processedLexems.last,
                        lex.type == .identifier
                    {
                        if stack.contains(where: {
                                if case .lexem(let lex) = $0 {
                                    return lex == getLexem(for: "new")
                                }
                                return false
                            }
                        ) {
                            stack.removeLast()
                            stack.append(.objectInitialization)
                        } else if case .functionDefinition = stack.last { } else {
                            stack.append(.callFunction)
                        }
                    } else {
                        stack.append(.lexem(lexem))
                    }
                    
                case getLexem(for: "]"):
                    if processedLexems.last == getLexem(for: "[") {
                        result.append(.empty)
                        if case .arrayOperator = stack.last {
                            result.append(stack.removeLast())
                        }
                    } else {
                        if case .list = stack.last {
                            result.append(stack.removeLast())
                            if case .arrayOperator = stack.last {
                                result.append(stack.removeLast())
                            }
                        } else {
                            result.append(stack.removeLast())
                        }
                    }
                    
                    if stack.contains(where: {
                            if case .lexem(let lex) = $0 {
                                return lex == getLexem(for: "new")
                            }
                            return false
                        }
                    ) {
                        stack.removeLast()
                        stack.append(.objectInitialization)
                    }
                    
                    if case .objectInitialization = stack.last {
                        stack.append(.empty)
                    }
                    
                case getLexem(for: ")"):
                    unclosedBacketsCount -= 1
                    
                    if processedLexems.last == getLexem(for: "(") || processedLexems.last == getLexem(for: ";")  {
                        stack.append(.empty)
                    }

                    while !stack.isEmpty && (
                        stack.last!.value != "(" &&
                        !stack.last!.value.contains("FUNCALL") &&
                        !stack.last!.value.contains("OBJINIT") &&
                        !stack.last!.value.contains("FUNCDEF")
                    ) {
                        result.append(stack.removeLast())
                    }
                    
                    if !stack.isEmpty {
                        if case .callFunction = stack.last! {
                            result.append(stack.removeLast())
                        } else if case .objectInitialization = stack.last! {
                            result.append(stack.removeLast())
                        } else if case .functionDefinition = stack.last {
                            
                        } else {
                            stack.removeLast()
                        }
                    }
                    
                case getLexem(for: "}"):
                    while !stack.isEmpty && !stack.last!.value.contains("BLOCK") {
                        result.append(stack.removeLast())
                    }
                    
                    if case .block(let count) = stack.last {
                        if case .list = result.last {
                            stack[stack.count - 1] = .block(count + 1)
                        } else if case .forLoop = result.last {
                            stack[stack.count - 1] = .block(count + 1)
                        }
                    }
                    
                    result.append(stack.removeLast())

                    if case .block(let count) = stack.last {
                        stack[stack.count - 1] = .block(count + 1)
                    } else if case .whileLoop = stack.last {
                        result.append(stack.removeLast())
                    } else if case .forLoop = stack.last {
                        result.append(stack.removeLast())
                    } else if case .functionDefinition = stack.last {
                        let lastBlockIndex = stack.lastIndex(where: {
                            if case .block = $0 {
                                return true
                            }
                            return false
                        })
                        
                        if let index = lastBlockIndex, case .block(let count) = stack[index] {
                            stack[index] = .block(count + 1)
                        }
                        
                        result.append(stack.removeLast())
                    }
                    
                    if !unclosedLabels.isEmpty && (unprocessedLexems.count == 1 || unprocessedLexems[1] != getLexem(for: "else")) {
                        result.append(.label(unclosedLabels.removeLast()))
                        result.append(.lexem(getLexem(for: ":")!))
                    }
                    
                case getLexem(for: ";"):
                    if processedLexems.last == getLexem(for: "(") || processedLexems.last == getLexem(for: ";") {
                        stack.append(.empty)
                    }
                    
                    while !stack.isEmpty && (
                        !stack.last!.value.contains("BLOCK") &&
                        !stack.last!.value.contains("(")
                    ) {
                        result.append(stack.removeLast())
                    }
                    
                    if case .block(let count) = stack.last {
                        stack[stack.count - 1] = .block(count + 1)
                    }
                    
                default:
                    break
                }
            }
                        
            processedLexems.append(unprocessedLexems.removeFirst())
        }
        
        while !stack.isEmpty {
            result.append(stack.removeLast())
        }
        
        return result
    }
}
