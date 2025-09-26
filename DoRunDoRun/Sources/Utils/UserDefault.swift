//
//  UserDefault.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 9/26/25.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    let storage: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            return storage.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            storage.set(newValue, forKey: key)
        }
    }
}

enum Defaults {
    enum Key: String {
        case hasSeenOnboarding
    }
    
    @UserDefault(key: Key.hasSeenOnboarding.rawValue, defaultValue: false) static var hasSeenOnboarding: Bool
}
