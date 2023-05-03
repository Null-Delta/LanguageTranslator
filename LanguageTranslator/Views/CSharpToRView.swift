//
//  CSharpToRView.swift
//  LanguageTranslator
//
//  Created by Rustam Khakhuk on 22.04.2023.
//

import SwiftUI

struct CSharpToRView: View {
    @State var sourceCode: String = ""
    @State var resultCode: String = ""

    @State var lexems: [Lexem] = []
    private var analyzer = LexicalAnalyzer()
    private var convertor = RPNDecoder()

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("Исходный код на C#:")
                        .frame(height: 32)
                    Spacer()
                    Button("Трансляция") {
                        lexems = []
                        resultCode = ""
                        analyzer.process(symbols: sourceCode)
                        let tokens = RPNConvertor.convert(lexems: lexems)
                        resultCode = RPNDecoder.decode(tokens: tokens)
                    }
                }

                EditorControllerView(text: $sourceCode, selection: .init(get: { nil }, set: { _ in }))
                    .cornerRadius(6)
                    .font(.system(size: 12, design: .monospaced))

            }

            VStack(alignment: .leading) {
                Text("Исходный код на R:")
                    .frame(height: 32)

                EditorControllerView(text: $resultCode, selection: .init(get: { nil }, set: { _ in }))
                    .cornerRadius(6)
                    .font(.system(size: 12, design: .monospaced))

            }
        }
        .onAppear {
            analyzer.updateProcedures(procedures: [
                { specialSymbol in },

                { buffer in
                    if !identifiers.contains(buffer) { identifiers.append(buffer) }
                    let identifierIndex = identifiers.firstIndex(of: buffer)!

                    lexems.append(.init(type: .identifier, index: identifierIndex))
                },

                { buffer in
                    if let serviceIndex = serviceWords.firstIndex(of: buffer) {
                        lexems.append(.init(type: .serviceWord, index: serviceIndex))
                    } else {
                        if !identifiers.contains(buffer) { identifiers.append(buffer) }
                        let identifierIndex = identifiers.firstIndex(of: buffer)!

                        lexems.append(.init(type: .identifier, index: identifierIndex))
                    }
                },

                { buffer in
                    if !constaints.contains(buffer) { constaints.append(buffer) }
                    let constantIndex = constaints.firstIndex(of: buffer)!

                    lexems.append(.init(type: .constaint, index: constantIndex))
                },

                { _ in },

                { buffer in

                    if !constaints.contains(buffer) { constaints.append(buffer) }
                    let constantIndex = constaints.firstIndex(of: buffer)!

                    lexems.append(Lexem(type: .constaint, index: constantIndex))
                },

                { buffer in
                    if let dividerIndex = dividers.firstIndex(of: buffer) {
                        lexems.append(.init(type: .divider, index: dividerIndex))
                    }
                },

                { buffer in
                    if let operatorIndex = operators.firstIndex(of: buffer) {
                        lexems.append(.init(type: .operator, index: operatorIndex))
                    }
                }
            ])
        }

        .padding(12)
    }
}

struct CSharpToRView_Previews: PreviewProvider {
    static var previews: some View {
        CSharpToRView()
    }
}
