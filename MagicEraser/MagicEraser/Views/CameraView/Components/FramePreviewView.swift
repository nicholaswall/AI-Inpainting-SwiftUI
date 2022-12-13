//
//  FramePreviewView.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/8/22.
//

import Foundation
import SwiftUI

struct CameraFramePreviewView: View {
    var image: CGImage?
    private let label = Text("Captured Frame from the Rear Camera")
    
    var body: some View {
        if let image = image {
            Image(image, scale: 1.0, orientation: .up, label: label)
                .resizable()
        } else {
            Color.gray
        }
    }
}
