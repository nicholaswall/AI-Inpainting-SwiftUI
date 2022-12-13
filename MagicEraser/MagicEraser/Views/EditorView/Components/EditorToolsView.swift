//
//  EditorToolsView.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/8/22.
//

import Foundation
import SwiftUI
import CoreGraphics

struct DrawMaskEditorToolsView: View {
    
    @Binding var drawings: [Drawing]
    @Binding var lineWidth: CGFloat
    
    var body: some View {
        VStack {
            HStack {
                // Clear drawing
                Button(action: {
                    self.drawings = [Drawing]()
                }, label: {
                    Image(systemName: "eraser.fill")
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }).padding(.leading, 10)
                
                // Undo changes
                Button(action: {
                    if self.drawings.count > 0 {
                        self.drawings.removeLast()
                    }
                }, label: {
                    Image(systemName: "arrow.uturn.backward")
                        .foregroundColor(Color.white)
                        .padding()
                        .background(Color.accentColor)
                        .clipShape(Circle())
                }).padding(.leading, 10)
                
                // Change Pencil Size
                HStack {
                    Text("Pencil width")
                        .padding()
                    Slider(value: $lineWidth, in: 8.0...25.0, step: 1.0)
                        .padding()
                }
            }
        }
    }
}
