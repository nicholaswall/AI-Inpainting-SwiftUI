//
//  ReplaceWithPromptView.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import SwiftUI

struct ReplaceWithPromptView: View {
    @Binding var image: CGImage?
    @Binding var maskGenerationPompt: String
    @Binding var drawings: [Drawing]
    @Binding var maskingMethod: MaskGenerationType
    @Binding var geometryFrameSize: CGSize?
    
    @StateObject var viewModel: ReplaceWithPromptViewModel = ReplaceWithPromptViewModel()
    @State var replacementGenerationPrompt: String = ""
    
    var body: some View {
        if viewModel.isLoading {
            ZStack {
                Color(.systemBackground).edgesIgnoringSafeArea(.all)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                    .scaleEffect(2)
            }
        } else {
            VStack {
                if let img = viewModel.modifiedImage {
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                TextField("What do you want to replace the mask with?", text: $replacementGenerationPrompt)
                    .padding()
                Button("Generate Image") {
                    print("Sending request to server... ETA: 30s...")
                    self.viewModel.makeGenerationRequest(image: image!,
                                                         maskGenerationPrompt: maskGenerationPompt,
                                                         maskGenerationMethod: maskingMethod,
                                                         replacementGenerationPrompt:
                                                            replacementGenerationPrompt,
                                                         drawings:
                                                            drawings,
                                                         geometryFrameSize: geometryFrameSize
                    )
                }.padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor.cornerRadius(8))
                    
                
            }.alert(item: $viewModel.alertItem) { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            }
        }
    }
}

struct ReplaceWithPromptView_PreviewsContainer: View {
    @State var frame: CGImage? = (UIImage(named: "dog-dummy-image")?.cgImage)
    @State var maskGenerationPrompt: String = ""
    @State var drawings: [Drawing] = [Drawing]()
    @State var maskingMethod: MaskGenerationType = .prompt
    @State var base64MaskEncoding: String = ""
    @State var geometryFrameSize: CGSize?
    
    var body: some View {
        NavigationStack {
            ReplaceWithPromptView(image: $frame,
                                  maskGenerationPompt: $maskGenerationPrompt,
                                  drawings: $drawings,
                                  maskingMethod: $maskingMethod,
                                  geometryFrameSize: $geometryFrameSize
            )
        }
    }
}

struct ReplaceWithPromptView_Previews: PreviewProvider {
    static var previews: some View {
        ReplaceWithPromptView_PreviewsContainer()
    }
}
