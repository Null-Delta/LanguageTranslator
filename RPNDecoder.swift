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
        case .lexem(let lexem) where value(for: lexem) == "return":
            return Command(commandToken: tokens.removeLast(), arguments: [constructCommand(tokens: &tokens)])

        case .lexem(let lexem) where value(for: lexem) == "if":
            return Command(commandToken: tokens.removeLast(), arguments: [
                constructCommand(tokens: &tokens),
                constructCommand(tokens: &tokens)
            ])

        case .lexem(let lexem) where value(for: lexem) == "else":
            return Command(commandToken: tokens.removeLast(), arguments: [
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
            return Command(commandToken: tokens.removeLast(), arguments: (0..<int + 2).map { _ in
                constructCommand(tokens: &tokens)
            })
        case .empty:
            return Command(commandToken: tokens.removeLast(), arguments: [])
            
        case .variableDefinition(let int):
            var subcommands: [Command] = []
            let main = tokens.removeLast()
            

            subcommands.append(constructCommand(tokens: &tokens))
            subcommands.append(Command(commandToken: tokens.removeLast(), arguments: []))

            if int > 0 {
                (0..<int - 1).forEach { _ in subcommands.append(constructCommand(tokens: &tokens)) }
            }
            
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

        result = """
        Console.WriteLine <- function(argument) {
          print(argument)
        }\n
        """ + result

        result += "Main()"
        
        return result
    }
    
    private static func toString(command: Command, tabs: Int = 0, needBuckets: Bool = true) -> String {
        var result = ""
        let tab = "  "
        
        switch command.commandToken {
        case .lexem(let lexem) where lexem.type == .operator && value(for: lexem) == "=":
            if needBuckets {
                result = "(" + toString(command: command.arguments[1]) + " <- " + toString(command: command.arguments[0]) + ")"
            } else {
                result = toString(command: command.arguments[1]) + " <- " + toString(command: command.arguments[0])
            }
            result = Array(repeating: tab, count: tabs).joined() + result

        case .lexem(let lexem) where lexem.type == .operator:
            if needBuckets {
                result = "(" + toString(command: command.arguments[1]) + " " + command.commandToken.value + " " + toString(command: command.arguments[0]) + ")"
            } else {
                result = toString(command: command.arguments[1]) + " " + command.commandToken.value + " " + toString(command: command.arguments[0])
            }
            result = Array(repeating: tab, count: tabs).joined() + result

        case .lexem(let lexem) where value(for: lexem) == "if":
            result = value(for: lexem)
            + "("
            + toString(command: command.arguments[1])
            + ") {\n"
            + toString(command: command.arguments[0], tabs: tabs)
            + Array(repeating: tab, count: tabs).joined() + "}"
            result = Array(repeating: tab, count: tabs).joined() + result

        case .lexem(let lexem) where value(for: lexem) == "else":
            result = value(for: lexem)
            + " {\n"
            + toString(command: command.arguments[0], tabs: tabs)
            + Array(repeating: tab, count: tabs).joined() + "}"
            result = Array(repeating: tab, count: tabs).joined() + result

        case .lexem(let lexem) where value(for: lexem) == "return":
            result = value(for: lexem) + "(" + toString(command: command.arguments[0]) + ")"
            result = Array(repeating: tab, count: tabs).joined() + result

        case .lexem(let lexem):
            result = value(for: lexem)

        case .arrayOperator:
            result = "[" + toString(command: command.arguments[0]) + "]"
            
        case .callFunction:
            result = toString(command: command.arguments[1], tabs: tabs) + "(" + toString(command: command.arguments[0]) + ")"
            result = Array(repeating: tab, count: tabs).joined() + result

        case .block:
            let values = command.arguments.reversed().map { toString(command: $0, tabs: tabs + 1, needBuckets: false) + "\n" }.joined()
            result = values
            
        case .objectInitialization:
            assertionFailure()
            
        case .call:
            result = toString(command: command.arguments[1]) + "." + toString(command: command.arguments[0])
            result = Array(repeating: tab, count: tabs).joined() + result
            
        case .whileLoop:
            result = "while ("
            + toString(command: command.arguments[1], needBuckets: false)
            + ") {\n"
            + toString(command: command.arguments[0], tabs: tabs)
            + Array(repeating: tab, count: tabs).joined() + "}"
            result = Array(repeating: tab, count: tabs).joined() + result
            
        case .forLoop:
            result = toString(command: command.arguments[3], needBuckets: false)
            + "\n"
            + Array(repeating: tab, count: tabs).joined()
            + "while (" + toString(command: command.arguments[2], needBuckets: false) + ") {\n"
            + toString(command: command.arguments[0], tabs: tabs, needBuckets: false)
            + toString(command: command.arguments[1], tabs: tabs + 1, needBuckets: false)
            + "\n"
            + Array(repeating: tab, count: tabs).joined() + "}"

            result = Array(repeating: tab, count: tabs).joined() + result
            break
            
        case .list:
            result = command.arguments.reversed().map { toString(command: $0) }.joined(separator: ", ")
            
        case .classDefinition(_):
            let result = toString(command: command.arguments[0], tabs: tabs - 1)
            return result

        case .empty:
            result = ""
            
        case .variableDefinition(_):
            result = toString(command: command.arguments[0], needBuckets: needBuckets)
            result = Array(repeating: tab, count: tabs).joined() + result

        case .functionDefinition(let count):
            result = toString(command: command.arguments[count + 2], tabs: tabs)
            + " <- function("
            + toString(command: command.arguments[1])
            + ") {\n"
            + toString(command: command.arguments[0], tabs: tabs)
            + Array(repeating: tab, count: tabs).joined()
            + "}"
            result = Array(repeating: tab, count: tabs).joined() + result
        }
        
        return result
    }
}
