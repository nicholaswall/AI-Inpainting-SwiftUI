//
//  NetworkManager.swift
//  MagicEraser
//
//  Created by Nick Wall on 12/7/22.
//

import Foundation
import UIKit


class NetworkManager: NSObject {
    
    static let shared = NetworkManager()
    // MARK: CHANGE THIS VARIABLE TO RUN THE APPLICATION LOCALLY
    static let baseURL = "https://instructors-soldier-cars-quality.trycloudflare.com/"
    
    private let inpaintURL = baseURL + "inpaint/"
    
    func makeGenerationRequest(requestBody: ReplacementRequestBody, completed: @escaping (Result<ReplacementResponse, APIError>) -> Void) {
        let url = URL(string: inpaintURL)!
        var request = URLRequest(url: url)
        
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpMethod = "POST"
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
                
        let bodyData = try? encoder.encode(requestBody)
        request.httpBody = bodyData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           
            if let _ = error {
                completed(.failure(.unableToComplete))
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print(response ?? "Unknown Response")
                completed(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completed(.failure(.invalidData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let decodedResponse = try decoder.decode(ReplacementResponse.self, from: data)
                completed(.success(decodedResponse))
            } catch {
                completed(.failure(.invalidData))
            }
        }
        
        task.resume()
    }
}
