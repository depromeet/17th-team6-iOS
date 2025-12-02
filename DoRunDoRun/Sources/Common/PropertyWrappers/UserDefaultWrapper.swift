//
//  UserDefaultWrapper.swift
//  DoRunDoRun
//
//  Created by Jaehui Yu on 11/5/25.
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
            // Optional 타입일 경우 nil 처리
            if let optional = newValue as? AnyOptional {
                if optional.isNil {
                    storage.removeObject(forKey: key)
                    return
                }
            }
            storage.set(newValue, forKey: key)
        }
    }
}

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}
