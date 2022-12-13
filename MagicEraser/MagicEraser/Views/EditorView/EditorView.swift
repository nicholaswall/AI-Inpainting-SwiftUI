//
//  EditorView.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import SwiftUI
import CoreGraphics

struct EditorView: View {
    @Binding var image: CGImage?
    
    @State private var currentDrawing: Drawing = Drawing()
    @State private var drawings: [Drawing] = [Drawing]()
    @State private var color: Color = Color.black
    @State private var lineWidth: CGFloat = 18.0
    @State private var maskGenerationPrompt: String = ""
    @State var selectedSide: MaskGenerationType = .draw
    @State var showReplaceWithPromptView: Bool = false
    @State var geometryFrameSize: CGSize?
    
    
    var drawingPadView: some View {
        DrawingPad(currentDrawing: $currentDrawing,
                   drawings: $drawings,
                   color: $color,
                   lineWidth: $lineWidth,
                   image: $image,
                   geometryFrameSize: $geometryFrameSize
        )
    }
    
    var body: some View {
        VStack {
            Picker("Create a mask", selection: $selectedSide) {
                ForEach(MaskGenerationType.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }.pickerStyle(SegmentedPickerStyle())
                .padding()
            ZStack {
                Color.gray
                if image != nil {
                    Image(image!, scale: 1.0, label: Text("Testing"))
                        .resizable()
                        .scaledToFit()
                    if selectedSide == .draw {
                        drawingPadView
                    }
                }
            }
            
            if selectedSide == .draw {
                DrawMaskEditorToolsView(drawings: $drawings, lineWidth: $lineWidth)
            } else {
                PromptMaskEditorView(maskGenerationPrompt: $maskGenerationPrompt)
            }

        }.navigationTitle(Text("Edit Your Photo"))
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button("Save") {
                        print("Save Pressed")
                        showReplaceWithPromptView.toggle()
                    }
                }
            }
            .navigationDestination(isPresented: $showReplaceWithPromptView) {
                ReplaceWithPromptView(image: $image,
                                      maskGenerationPompt: $maskGenerationPrompt,
                                      drawings: $drawings,
                                      maskingMethod: $selectedSide,
                                      geometryFrameSize: $geometryFrameSize
                )
            }
            .animation(.default, value: selectedSide)
    }
}

struct EditorView_PreviewsContainer: View {
    @State var frame: CGImage? = (UIImage(named: "dog-dummy-image")?.cgImage)
    
    var body: some View {
        NavigationStack {
          EditorView(image: $frame)
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView_PreviewsContainer()
    }
}
