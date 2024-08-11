//
//  OpenAI.swift
//  Image Sandbox
//
//  Created by Parth Antala on 8/10/24.
//

import Foundation
import UIKit

class OpenAI {
    static let shared = OpenAI()
    private init() {}
    
    private let apiKey = "\(Keys().key)"
    private let url = URL(string: "https://api.openai.com/v1/images/variations")!
    func createImageVariation(image: UIImage, prompt: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let body = NSMutableData()
            
            // Image part
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
            body.appendString("Content-Type: image/jpeg\r\n\r\n")
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                body.append(imageData)
            }
            body.appendString("\r\n")
            
            // Prompt part
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n")
            body.appendString("\(prompt)\r\n")
            
            body.appendString("--\(boundary)--\r\n")
            request.httpBody = body as Data
            
            // Log request details for debugging
            print("Request URL: \(request.url?.absoluteString ?? "")")
            print("Request Headers: \(request.allHTTPHeaderFields ?? [:])")
            print("Request Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                    let responseString = String(data: data ?? Data(), encoding: .utf8) ?? "No data"
                    let errorDescription = "Invalid response with status code \(statusCode): \(responseString)"
                    completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                    return
                }
                
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let dataArr = json["data"] as? [[String: Any]],
                      let urlString = dataArr.first?["url"] as? String,
                      let url = URL(string: urlString) else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response data"])))
                    return
                }
                
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    guard let data = data, let image = UIImage(data: data) else {
                        completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid image data"])))
                        return
                    }
                    
                    completion(.success(image))
                }.resume()
            }
            
            task.resume()
        }
    }

    private extension NSMutableData {
        func appendString(_ string: String) {
            if let data = string.data(using: .utf8) {
                append(data)
            }
        }
    }
