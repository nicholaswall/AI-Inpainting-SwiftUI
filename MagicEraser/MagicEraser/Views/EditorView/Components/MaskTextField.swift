//
//  MaskTextField.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/8/22.
//

import Foundation
import SwiftUI

struct PromptMaskEditorView: View {
    
    @Binding var maskGenerationPrompt: String
    
    var body: some View {
        TextField("What should be replaced", text: $maskGenerationPrompt)
            .padding()
    }
}
