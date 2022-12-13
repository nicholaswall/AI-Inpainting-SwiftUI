//
//  ReplaceWithPromptViewModel.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import Foundation
import CoreGraphics
import UIKit
import SwiftUI

final class ReplaceWithPromptViewModel: ObservableObject {
    
    @Published var isLoading = false
    @Published var alertItem: AlertItem?
    @Published var modifiedImage: Image?
    
    func makeGenerationRequest(image: CGImage,
                               maskGenerationPrompt: String,
                               maskGenerationMethod: MaskGenerationType,
                               replacementGenerationPrompt: String,
                               drawings: [Drawing],
                               geometryFrameSize: CGSize?
    ) {
        
        let img = CIImage(cgImage: image)
        
        let cspace = CGColorSpace(name: CGColorSpace.sRGB)
        let context = CIContext()
        
        let pngImage = context.jpegRepresentation(of: img, colorSpace: cspace!)
        let b64Image = pngImage?.base64EncodedString()
        
        var xValues:[Double] = []
        var yValues:[Double] = []
        
        for drawing in drawings {
            let points = drawing.points
            
            for point in points {
                xValues.append(point.x)
                yValues.append(point.y)
            }
        }
        
        let imageHeight = image.height
        let imageWidth = image.width
        
        var frameWidth = imageWidth
        var frameHeight = imageHeight
        
        // TODO: unpack frame size and serialize
        if let geometryFrameSize = geometryFrameSize {
            frameWidth = Int(geometryFrameSize.width)
            frameHeight = Int(geometryFrameSize.height)
        }
        
        let body = ReplacementRequestBody(image: b64Image!,
                                          maskPrompt: maskGenerationPrompt,
                                          replacementPrompt: replacementGenerationPrompt,
                                          maskGenerationMethod: maskGenerationMethod.rawValue,
                                          xPoints: xValues,
                                          yPoints: yValues,
                                          brushSize: 18,
                                          imageWidth: imageWidth,
                                          imageHeight: imageHeight,
                                          frameWidth: frameWidth,
                                          frameHeight: frameHeight
        )
        
        isLoading = true
        
        NetworkManager.shared.makeGenerationRequest(requestBody: body) { [self] result in
            DispatchQueue.main.async {
                self.isLoading = false
                
                switch result {
                case .success(let response):
                    let img = Image(uiImage: UIImage(data: Data(base64Encoded: response.image)!)!)
                    
                    self.modifiedImage = img
                    
                case .failure(let error):
                    switch error {
                    case .invalidData:
                        self.alertItem = AlertContext.invalidData
                    case .invalidURL:
                        self.alertItem = AlertContext.invalidURL
                    case .invalidResponse:
                        self.alertItem = AlertContext.invalidResponse
                    case .unableToComplete:
                        self.alertItem = AlertContext.unableToComplete
                    }
                }

            }
            
        }
    }
}
