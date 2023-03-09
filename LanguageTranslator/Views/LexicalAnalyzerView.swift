//
//  LexemAnalyzerView.swift
//  LanguageTranslator
//
//  Created by Delta Null on 09.03.2023.
//

import SwiftUI

struct LexicalAnalyzerView: View {
    @State var identifiers: [String] = []
    @State var constants: [String] = []
    
    @State var sourceCode: String = ""
    @State var sourceSelection: Range<Int>? = nil
    
    var analyzer = LexicalAnalyzer()
    
    @State var processLexems: String = ""
    
    @State var wasStepStart: Bool = false

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Исходный код на C#:")
                    .frame(height: 32)

                EditorControllerView(text: $sourceCode, selection: $sourceSelection)
                    .cornerRadius(6)
                    .font(.system(size: 12, design: .monospaced))
                
            }
            
            VStack(alignment: .leading) {
                Text("Лексемы:")
                    .frame(height: 32)
                
                EditorControllerView(text: $processLexems, selection: .constant(nil))
                    .cornerRadius(6)
                    .font(.system(size: 12, design: .monospaced))
            }
            
            VStack(alignment: .leading) {
                Text("Идентификаторы:")
                    .frame(height: 32)
                
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
                .cornerRadius(6)
                
                Text("Константы:")
                    .frame(height: 32)

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
                .cornerRadius(6)
            }
            .frame(width: 220)
        }
        .padding(12)
        .navigationTitle("Лексический анализатор")
        .toolbar {
            Button(wasStepStart ? "Stop" : "Convert") {
                if wasStepStart {
                    processLexems = ""
                    identifiers = []
                    constants = []
                    wasStepStart = false
                    sourceSelection = 0..<0
                } else {
                    processLexems = ""
                    identifiers = []
                    constants = []
                    sourceSelection = 0..<0
                    analyzer.process(symbols: sourceCode)
                }
            }

            Button("Convert by steps") {
                if !wasStepStart {
                    identifiers = []
                    constants = []
                    processLexems = ""
                    analyzer.setupSumbols(symbols: sourceCode)
                    sourceSelection = 0..<0
                    wasStepStart = true
                }
            }
        }
        .onReceive(timer) { _ in
            if wasStepStart {
                sourceSelection = sourceSelection!.lowerBound..<sourceSelection!.upperBound + 1
                let isInProcess = analyzer.processStep()
                
                if !isInProcess {
                    wasStepStart = false
                }
            }
        }
        .onAppear {
            analyzer.updateProcedures(procedures: [
                { specialSymbol in
                    processLexems += specialSymbol
                    sourceSelection = sourceSelection!.upperBound..<sourceSelection!.upperBound
                },
                
                { buffer in
                    processLexems += processLexems.last != " " ? " " : ""
                    
                    if !identifiers.contains(buffer) { identifiers.append(buffer) }
                    let identifierIndex = identifiers.firstIndex(of: buffer)!
                    
                    processLexems += "I_\(identifierIndex)"
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                },
                
                { buffer in
                    processLexems += processLexems.last != " " ? " " : ""

                    if let serviceIndex = serviceWords.firstIndex(of: buffer) {
                        processLexems += "S_\(serviceIndex)"
                    } else {
                        if !identifiers.contains(buffer) { identifiers.append(buffer) }
                        let identifierIndex = identifiers.firstIndex(of: buffer)!
                        
                        processLexems += "I_\(identifierIndex)"
                    }
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                },
                
                { buffer in
                    processLexems += processLexems.last != " " ? " " : ""

                    if !constants.contains(buffer) { constants.append(buffer) }
                    let constantIndex = constants.firstIndex(of: buffer)!
                    
                    processLexems += "C_\(constantIndex)"
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                },
                
                { _ in
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                },
                
                { buffer in
                    processLexems += processLexems.last != " " ? " " : ""

                    if !constants.contains(buffer) { constants.append(buffer) }
                    let constantIndex = constants.firstIndex(of: buffer)!
                    
                    processLexems += "C_\(constantIndex)"
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                },
                
                { buffer in
                    processLexems += processLexems.last != " " ? " " : ""

                    if let dividerIndex = dividers.firstIndex(of: buffer) {
                        processLexems += "D_\(dividerIndex)"
                    }
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                },
                
                { buffer in
                    processLexems += processLexems.last != " " ? " " : ""

                    if let operatorIndex = operators.firstIndex(of: buffer) {
                        processLexems += "O_\(operatorIndex)"
                    }
                    sourceSelection = sourceSelection!.upperBound - 1..<sourceSelection!.upperBound - 1
                }
            ])
        }
    }
}

struct LexicalAnalyzerView_Previews: PreviewProvider {
    static var previews: some View {
        LexicalAnalyzerView()
    }
}
