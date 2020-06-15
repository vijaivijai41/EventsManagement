//
//  OEServiceResource.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation


protocol ErrorReturn {
    var errorString: String { get }
}

enum ErrorHandler: Error, ErrorReturn {
    case nodata
    case networkError
    case serviceError
    
    var errorString: String {
        switch self {
        case .networkError:
            return "Network failure"
        case .nodata:
            return "No data found"
        case .serviceError:
            return "Service unavailable"
        }
    }
}



enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
}

protocol OEServiceResource {
    var baseURL: URL { get }
    var urlRequest: URLRequest? { get }
    var method: String { get }
    var params: [String: String] { get }
    var httpMethod: HttpMethod { get }
}

extension OEServiceResource {
    // url request formation based on values
    var urlRequest: URLRequest? {
        let urlComponents = URLComponents(string: (baseURL.absoluteString + method).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        
        if let url = urlComponents?.url {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = httpMethod.rawValue
            
            if httpMethod == .post {
                if let paramsData = encodeParams() {
                    urlRequest.httpBody = paramsData
                }
                
                // add content type based on types
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            return urlRequest
        }
        return nil
    }
    
    // encoded params to data
    func encodeParams() -> Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: .fragmentsAllowed)
            return jsonData
        }catch {
            print("error \(error)")
        }
        return nil
    }
}
