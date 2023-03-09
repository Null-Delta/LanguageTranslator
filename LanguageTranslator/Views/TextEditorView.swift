//
//  TextEditorView.swift
//  LanguageTranslator
//
//  Created by Delta Null on 09.03.2023.
//

import Foundation
import AppKit
import SwiftUI

class EditorController: NSViewController {
    var textView = NSTextView()
    
    override func loadView() {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        
        textView.autoresizingMask = [.width]
        textView.allowsUndo = true
        textView.font = .systemFont(ofSize: 16)
        scrollView.documentView = textView
        
        self.view = scrollView
    }
    
    override func viewDidAppear() {
        self.view.window?.makeFirstResponder(self.view)
    }
}

struct EditorControllerView: NSViewControllerRepresentable {
    @Binding var text: String
    @Binding var selection: Range<Int>?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextStorageDelegate, NSTextViewDelegate {
        private var parent: EditorControllerView
        var shouldUpdateText = true
        
        init(_ parent: EditorControllerView) {
            self.parent = parent
        }
        
        func textStorage(_ textStorage: NSTextStorage, didProcessEditing editedMask: NSTextStorageEditActions, range editedRange: NSRange, changeInLength delta: Int) {
            guard shouldUpdateText else {
                return
            }
            let edited = textStorage.attributedSubstring(from: editedRange).string
            self.parent.text = edited
        }
        
        func textDidChange(_ notification: Notification) {
            guard shouldUpdateText else { return }
            guard let textView = notification.object as? NSTextView else { return }

            self.parent.text = textView.string
        }
        
        func textViewDidChangeSelection(_ notification: Notification) {
            guard shouldUpdateText else { return }
            guard let textView = notification.object as? NSTextView else { return }

            textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
            self.parent.text = textView.string
            //self.parent.selection = Range(textView.selectedRange())
        }
    }

    func makeNSViewController(context: Context) -> EditorController {
        let vc = EditorController()
        vc.textView.textStorage?.delegate = context.coordinator
        vc.textView.delegate = context.coordinator

        vc.textView.textContainer?.lineFragmentPadding = 8
        vc.textView.textContainerInset = NSSize(width: 0, height: 8)
        vc.textView.isRichText = false
        vc.textView.importsGraphics = false
        vc.textView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        return vc
    }
    
    func updateNSViewController(_ nsViewController: EditorController, context: Context) {
        if text != nsViewController.textView.string {
            context.coordinator.shouldUpdateText = false
            nsViewController.textView.textStorage?.setAttributedString(.init(string: text, attributes: [
                .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            ]))
                    
            context.coordinator.shouldUpdateText = true
        }
        
        if selection != Range(nsViewController.textView.selectedRange()) {
            if selection != nil {
                context.coordinator.shouldUpdateText = false
                nsViewController.textView.setSelectedRange(NSRange(location: selection!.lowerBound, length: selection!.count))
                context.coordinator.shouldUpdateText = true
            }
        }
    }
}
