//
//  RPNDecoder.swift
//  LanguageTranslator
//
//  Created by Delta Null on 05.04.2023.
//

import Foundation

public class Command {
    var commandToken: RPNToken
    var arguments: [Command]
    
    init(commandToken: RPNToken, arguments: [Command]) {
        self.commandToken = commandToken
        self.arguments = arguments
    }
    
    func log(tabs: Int = 0) {
        print(Array.init(repeating: "  ", count: tabs).joined() + commandToken.value)
        arguments.forEach {
            $0.log(tabs: tabs + 1)
        }
    }
}

public class RPNDecoder {
    
    public static func constructCommand(tokens: inout [RPNToken]) -> Command {
        guard let token = tokens.last else {
            tokens = []
            return Command(commandToken: .empty, arguments: [])
            
        }
        
        switch token {
        case .lexem(let lexem) where lexem.type == .operator:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])

        case .lexem(let lexem) where value(for: lexem) == "if" || value(for: lexem) == "else":
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])

        case .arrayOperator:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens)
            ])

        case .callFunction:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])
            
        case .block(let int):
            return Command(commandToken: tokens.removeLast(), arguments: (0..<int).map { _ in
                constructCommand(tokens: &tokens)
            })

        case .objectInitialization:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])
            
        case .call:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])
        case .whileLoop:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])
            
        case .forLoop:
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])
            
        case .list(let int):
            return Command(commandToken: tokens.removeLast(), arguments: (0..<int).map { _ in
                constructCommand(tokens: &tokens)
            })
            
        case .classDefinition(let int):
            return Command(commandToken: tokens.removeLast(), arguments: (0..<int).map { _ in
                constructCommand(tokens: &tokens)
            })
        case .empty:
            return Command(commandToken: tokens.removeLast(), arguments: [])
            
        case .variableDefinition(let int):
            var subcommands: [Command] = []
            let main = tokens.removeLast()
            
            subcommands.append(constructCommand(tokens: &tokens))
            subcommands.append(constructCommand(tokens: &tokens))
            (0..<int).forEach { _ in subcommands.append(constructCommand(tokens: &tokens)) }
            
            return Command(commandToken: main, arguments: subcommands)
            
        case .functionDefinition(let int):
            var subcommands: [Command] = []
            let main = tokens.removeLast()
            
            subcommands.append(constructCommand(tokens: &tokens))
            subcommands.append(constructCommand(tokens: &tokens))
            subcommands.append(constructCommand(tokens: &tokens))
            subcommands.append(constructCommand(tokens: &tokens))
            (0..<int).forEach { _ in subcommands.append(constructCommand(tokens: &tokens)) }
            
            return Command(commandToken: main, arguments: subcommands)

        default:
            return Command(commandToken: tokens.removeLast(), arguments: [])
        }
    }
    public static func decode(tokens: [RPNToken]) -> String {
        var localTokens = tokens
        
        var result = ""
        while !localTokens.isEmpty {
            let command = constructCommand(tokens: &localTokens)
            command.log()
            result = toString(command: command) + "\n" + result
        }
        
        return result
    }
    
    private static func toString(command: Command, tabs: Int = 0) -> String {
        var result = ""
        
        switch command.commandToken {
                        
        case .lexem(let lexem) where lexem.type == .operator:
            result = "(" + toString(command: command.arguments[1]) + " " + command.commandToken.value + " " + toString(command: command.arguments[0]) + ")"
            
        case .lexem(let lexem):
            result = value(for: lexem)

        case .arrayOperator:
            result = "[" + toString(command: command.arguments[0]) + "]"
            
        case .callFunction:
            result = toString(command: command.arguments[1], tabs: tabs + 1) + "(" + toString(command: command.arguments[0]) + ")"
            
        case .block:
            let values = command.arguments.reversed().map { toString(command: $0, tabs: tabs + 1) }.joined(separator: "\n")
            result = "{\n" + values + "\n" + Array(repeating: "  ", count: tabs).joined() + "}"
            
        case .objectInitialization:
            assertionFailure()
            
        case .call:
            result = toString(command: command.arguments[0]) + "." + toString(command: command.arguments[1])
            
        case .whileLoop:
            result = "while (" + toString(command: command.arguments[1]) + ") " + toString(command: command.arguments[0])
            
        case .forLoop:
            break
            
        case .list:
            result = command.arguments.reversed().map { toString(command: $0) }.joined(separator: ", ")
            
        case .classDefinition(_):
            assertionFailure()
            
        case .empty:
            result = ""
            
        case .variableDefinition(_):
            result = toString(command: command.arguments[0])
            
        case .functionDefinition(let count):
            result = toString(command: command.arguments[count + 2], tabs: tabs + 1) + " <- function(" + toString(command: command.arguments[1]) + ")" + toString(command: command.arguments[0], tabs: tabs + 1)
        }
        
        return Array(repeating: "  ", count: tabs).joined() + result
    }
}
