//
//  ReplacementRequestBody.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import Foundation

struct ReplacementRequestBody: Codable {
    var image: String
    var maskPrompt: String
    var replacementPrompt: String
    var maskGenerationMethod: String
    var xPoints: [Double]
    var yPoints: [Double]
    var brushSize: Int
    var imageWidth: Int
    var imageHeight: Int
    var frameWidth: Int
    var frameHeight: Int
}
