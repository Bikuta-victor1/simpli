//
//  DeviceID.swift
//  simpli
//
//  Created by Victor on 03/02/2026.
//

import Foundation

class DeviceID {
    static let shared = DeviceID()
    
    private let key = "device_id"
    
    var id: String {
        if let stored = UserDefaults.standard.string(forKey: key) {
            return stored
        }
        let newID = UUID().uuidString
        UserDefaults.standard.set(newID, forKey: key)
        return newID
    }
}
