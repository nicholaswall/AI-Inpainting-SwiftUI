//
//  CameraView.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/6/22.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var cameraViewModel: CameraViewModel = CameraViewModel()
    @State private var isShowingEditView: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                CameraFramePreviewView(image: self.cameraViewModel.frame)
                    .ignoresSafeArea(.all, edges: .all)
                VStack {
                    Spacer()
                    HStack {
                        // Take Snapshot Button
                        if !cameraViewModel.photoHasBeenTaken {
                            Button(action: self.cameraViewModel.saveCurrentFrameFromVideoFeed, label: {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 65, height: 65)
                                    
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                        .frame(width: 75, height: 75)
                                }
                            })
                        } else {
                            HStack {
                                Spacer()
                                Button(action: self.cameraViewModel.disardCurrentFrameAndReenableCapture, label: {
                                    Image(systemName: "arrow.triangle.2.circlepath.camera")
                                        .foregroundColor(.black)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }).padding(.trailing, 10)
                                    Button(action: {
                                        isShowingEditView.toggle()
                                        print("Pressed nav button: \(isShowingEditView)")
                                    }, label: {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.black)
                                            .padding()
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }).padding(.leading, 10)
                                Spacer()
                            }
                        }
                    }
                }
            }.navigationDestination(isPresented: $isShowingEditView) {
                EditorView(image: $cameraViewModel.frame)
            }
        }
    }
}

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView()
    }
}
