//
//  ContentView.swift
//  LanguageTranslator
//
//  Created by Delta Null on 22.02.2023.
//

import SwiftUI

struct ContentView: View {
    @State var identifiers: [String] = []
    @State var constants: [String] = []
    
    @State var sourceCode: String = ""
    @State var lexems: String = ""
    
    var analyzer = LexicalAnalyzer()
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("Ключевые слова:")
                    List {
                        ForEach(serviceWords.indices, id: \.self) { index in
                            HStack {
                                Text(serviceWords[index])
                                Spacer()
                                Divider()
                                Text("S_\(index)")
                                    .frame(width: 32)
                            }
                        }
                    }
                    .cornerRadius(12)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Операторы:")
                            List {
                                ForEach(operators.indices, id: \.self) { index in
                                    HStack {
                                        Text(operators[index])
                                        Spacer()
                                        Divider()
                                        Text("O_\(index)")
                                            .frame(width: 32)
                                    }
                                }
                            }
                            .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Разделители:")
                            List {
                                ForEach(dividers.indices, id: \.self) { index in
                                    HStack {
                                        Text(dividers[index])
                                        Spacer()
                                        Divider()
                                        Text("D_\(index)")
                                            .frame(width: 32)
                                    }
                                }
                            }
                            .cornerRadius(12)
                        }
                    }
                }
                .frame(width: 256)
                .frame(maxHeight: .infinity)

                
                VStack(alignment: .leading) {
                    Text("Идентификаторы:")
                    List {
                        ForEach(identifiers.indices, id: \.self) { index in
                            HStack {
                                Text(identifiers[index])
                                Spacer()
                                Divider()
                                Text("I_\(index)")
                                    .frame(width: 32)
                            }
                        }
                    }
                    .cornerRadius(12)
                    
                    Text("Константы:")
                    List {
                        ForEach(constants.indices, id: \.self) { index in
                            HStack {
                                Text(constants[index])
                                Spacer()
                                Divider()
                                Text("C_\(index)")
                                    .frame(width: 32)
                            }
                        }
                    }
                    .cornerRadius(12)
                }
                .frame(width: 220)
                
                VStack(alignment: .leading) {
                    Text("Исходный код на C#:")
                    TextEditor(text: $sourceCode)
                        .cornerRadius(6)
                        .font(.system(size: 12, design: .monospaced))
                    
                }
                
                VStack(alignment: .leading) {
                    Text("Лексемы:")
                    
                    TextEditor(text: $lexems)
                        .cornerRadius(6)
                        .font(.system(size: 12, design: .monospaced))
                }
                
            }
            .frame(maxHeight: .infinity)
            
            HStack {
                Button {
                    identifiers = []
                    constants = []
                } label: {
                    Text("Очистить таблицы")
                }
                
                Button {
                    lexems = ""
                    analyzer.process(symbols: sourceCode)
                } label: {
                    Text("Запуск")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .onAppear {
            analyzer.updateProcedures(procedures: [
                { specialSymbol in
                    lexems += specialSymbol
                },
                
                { buffer in
                    lexems += lexems.last != " " ? " " : ""
                    
                    if !identifiers.contains(buffer) { identifiers.append(buffer) }
                    let identifierIndex = identifiers.firstIndex(of: buffer)!
                    
                    lexems += "I_\(identifierIndex)"
                },
                
                { buffer in
                    lexems += lexems.last != " " ? " " : ""

                    if let serviceIndex = serviceWords.firstIndex(of: buffer) {
                        lexems += "S_\(serviceIndex)"
                    } else {
                        if !identifiers.contains(buffer) { identifiers.append(buffer) }
                        let identifierIndex = identifiers.firstIndex(of: buffer)!
                        
                        lexems += "I_\(identifierIndex)"
                    }
                },
                
                { buffer in
                    lexems += lexems.last != " " ? " " : ""

                    if !constants.contains(buffer) { constants.append(buffer) }
                    let constantIndex = constants.firstIndex(of: buffer)!
                    
                    lexems += "C_\(constantIndex)"
                },
                
                { _ in },
                
                { buffer in
                    lexems += lexems.last != " " ? " " : ""

                    if !constants.contains(buffer) { constants.append(buffer) }
                    let constantIndex = constants.firstIndex(of: buffer)!
                    
                    lexems += "C_\(constantIndex)"
                },
                
                { buffer in
                    lexems += lexems.last != " " ? " " : ""

                    if let dividerIndex = dividers.firstIndex(of: buffer) {
                        lexems += "D_\(dividerIndex)"
                    }
                },
                
                { buffer in
                    lexems += lexems.last != " " ? " " : ""

                    if let operatorIndex = operators.firstIndex(of: buffer) {
                        lexems += "O_\(operatorIndex)"
                    }
                }
            ])
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
