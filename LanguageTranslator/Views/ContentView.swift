//
//  ContentView.swift
//  LanguageTranslator
//
//  Created by Delta Null on 22.02.2023.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationSplitView(sidebar: {
            List {
                NavigationLink("Лексический анализатор", destination: LexicalAnalyzerView())
            }
        }, detail: {
            Text("Выберите вкладку")
        })
        .navigationSplitViewColumnWidth(256)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
