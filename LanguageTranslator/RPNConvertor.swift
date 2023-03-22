//
//  RPNConvertor.swift
//  LanguageTranslator
//
//  Created by Delta Null on 15.03.2023.
//

import Foundation

public enum RPNToken {
    case lexem(Lexem)
    case arrayOperator(Int)
    case callFunction(Int)
    case label(Int)
    case falseIfMove
    case justMove
    case block(Int)
    case objectInitialization(Int)
    case call
    
    // <var_type> <access_types> <[name | assignment]> count_of_access_types count_of_varriables VARDEF
    case variableDefinition(Int, Int)

    // <access_types> <func_type> <name> <[params]> <block> count_of_access_types (count_of_params + 3) FUNDEF

    public var value: String {
        switch self {
        case .lexem(let lexem):
            return LanguageTranslator.value(for: lexem)
            
        case .arrayOperator(let value):
            return "\(value) ARRIND"
            
        case .callFunction(let argCount):
            return "\(argCount) FUNCALL"
            
        case .label(let index):
            return "LBL\(index)"

        case .falseIfMove:
            return "IF"
            
        case .justMove:
            return "GOTO"
            
        case .block(let count):
            return "\(count) BLOCK"
            
        case .variableDefinition(let countOfAccessTypes, let countOfVarriables):
            return "\(countOfAccessTypes) \(countOfVarriables) VARDEF"
            
        case .objectInitialization(let count):
            return "\(count) OBJINIT"
            
        case .call:
            return "CALL"
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
                .block,
                .arrayOperator,
                .variableDefinition,
                .objectInitialization,
                .call,
                .callFunction:
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
        
        while !unprocessedLexems.isEmpty {
            
            let lexem = unprocessedLexems[0]

            print(value(for: lexem))
            print(stack.map { $0.value })
            print(result.map { $0.value })
            print()

            
            switch lexem.type {
            case .constaint:
                result.append(.lexem(lexem))

            case .identifier:
                if
                    case .lexem(let lex) = result.last,
                    lex.type == .identifier,
                    !stack.contains(where: { $0.value.contains("VARDEF") })
                {
                    if unprocessedLexems[1] == getLexem(for: "(") && (result.isEmpty) {
                        // function declaration
                    } else if processedLexems.last!.type == .identifier {
                        let accessCount = stack.count
                        
                        while !stack.isEmpty { result.append(stack.removeFirst()) }
                        result.append(.lexem(lexem))
                        stack.append(.variableDefinition(accessCount, 1))
                    } else {
                        result.append(.lexem(lexem))
                    }
                } else if case .arrayOperator(_) = result.last, stack.isEmpty {
                    let accessCount = stack.count
                    
                    while !stack.isEmpty { result.append(stack.removeFirst()) }
                    result.append(.lexem(lexem))
                    stack.append(.variableDefinition(accessCount, 1))

                } else {
                    result.append(.lexem(lexem))
                }
                

            case .serviceWord:
                switch lexem {
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
                                !stack.last!.value.contains("VARDEF")
                            )
                    {
                        result.append(stack.removeLast())
                    }
                    
                    if !stack.isEmpty {
                        if case .arrayOperator(let value) = stack[stack.count - 1] {
                            stack[stack.count - 1] = .arrayOperator(value + 1)
                        } else if case .callFunction(let value) = stack[stack.count - 1] {
                            stack[stack.count - 1] = .callFunction(value + 1)
                        } else if case .variableDefinition(let count, let size) = stack[stack.count - 1] {
                            stack[stack.count - 1] = .variableDefinition(count, size + 1)
                        }
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
                    stack.append(.arrayOperator(2))
                    
                case getLexem(for: "("):
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
                            stack.append(.objectInitialization(1))
                        } else {
                            stack.append(.callFunction(1))
                        }
                    } else {
                        stack.append(.lexem(lexem))
                    }
                    
                case getLexem(for: "]"):
                    if processedLexems.last == getLexem(for: "[") {
                        if case .arrayOperator(let count) = stack.last {
                            stack[stack.count - 1] = .arrayOperator(count - 1)
                            result.append(stack.removeLast())
                        }
                    } else {
                        result.append(stack.removeLast())
                    }
                    
                    if stack.contains(where: {
                            if case .lexem(let lex) = $0 {
                                return lex == getLexem(for: "new")
                            }
                            return false
                        }
                    ) {
                        stack.removeLast()
                        stack.append(.objectInitialization(1))
                    }
                    
                case getLexem(for: ")"):
                    while !stack.isEmpty && (
                        stack.last!.value != "(" &&
                        !stack.last!.value.contains("FUNCALL") &&
                        !stack.last!.value.contains("OBJINIT")
                    ) {
                        result.append(stack.removeLast())
                    }
                    
                    if !stack.isEmpty {
                        if case .callFunction(let value) = stack.last! {
                            if processedLexems.last != getLexem(for: "(") {
                                stack[stack.count - 1] = .callFunction(value + 1)
                            } else {
                                stack[stack.count - 1] = .callFunction(value)
                            }
                            result.append(stack.removeLast())
                        } else if case .objectInitialization(let value) = stack.last! {
                            if processedLexems.last != getLexem(for: "(") {
                                stack[stack.count - 1] = .objectInitialization(value + 1)
                            } else {
                                stack[stack.count - 1] = .objectInitialization(value)
                            }
                            result.append(stack.removeLast())
                        } else {
                            stack.removeLast()
                        }
                    }
                    
                case getLexem(for: "}"):
                    while !stack.isEmpty && !stack.last!.value.contains("BLOCK") {
                        result.append(stack.removeLast())
                    }
                    
                    result.append(stack.removeLast())
                    
                    if case .block(let count) = stack.last {
                        stack[stack.count - 1] = .block(count + 1)
                    }
                    
                    if !unclosedLabels.isEmpty && (unprocessedLexems.count == 1 || unprocessedLexems[1] != getLexem(for: "else")) {
                        result.append(.label(unclosedLabels.removeLast()))
                        result.append(.lexem(getLexem(for: ":")!))
                    }
                    
                case getLexem(for: ";"):
                    while !stack.isEmpty && !stack.last!.value.contains("BLOCK") {
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
