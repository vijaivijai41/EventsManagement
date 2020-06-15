//
//  OENetworkResponse.swift
//  OfflineEvent
//
//  Created by Vijay on 11/06/20.
//  Copyright © 2020 Vijay. All rights reserved.
//

import Foundation

struct OENetworkResponse: Codable {

    let status: String
    var data: Codable
    
    private enum CodingKeys: String,CodingKey {
        case status
        case data
        
    }
    
    public func encode(to encoder: Encoder) throws {
        
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
       
        self.status = try container.decode(String.self, forKey: .status)
        if self.status == "success" {
            if let dataArray = try? container.decode([EventModel].self,forKey: .data) {
                self.data = dataArray
            } else if let eventObj = try? container.decode(EventModel.self,forKey: .data) {
                self.data = eventObj
            } else if let errorStr = try?  container.decode(String.self, forKey:.data) {
                self.data = errorStr
            } else {
                self.data = OEEmptyData()
            }
        } else {
            self.data = try container.decode(String.self, forKey: .data)
        }
    }
    
}

public struct OEEmptyData: Codable { }


