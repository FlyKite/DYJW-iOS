//
//  DefaultsKey.swift
//  MineSweeper
//
//  Created by Feng,Zheng on 2020/3/12.
//  Copyright © 2020 Doge Studio. All rights reserved.
//

import UIKit

protocol DefaultsSupportedType { }

protocol DefaultsCustomType: DefaultsSupportedType {
    func getStorableValue() -> DefaultsSupportedType
    init?(storableValue: Any?)
}

@propertyWrapper struct DefaultsProperty<ValueType: DefaultsSupportedType> {
    let key: String
    let defaultValue: ValueType
    
    init(key: String, defaultValue: ValueType) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: ValueType {
        get {
            let value = UserDefaults.standard.value(forKey: key)
            if let storableType = ValueType.self as? DefaultsCustomType.Type {
                let result = storableType.init(storableValue: value)
                return (result as? ValueType) ?? defaultValue
            } else {
                return value as? ValueType ?? defaultValue
            }
        }
        set {
            if let value = newValue as? DefaultsCustomType {
                UserDefaults.standard.set(value.getStorableValue(), forKey: key)
            } else {
                if let value = newValue as? AnyOptional, value.isNil {
                    UserDefaults.standard.removeObject(forKey: key)
                } else {
                    UserDefaults.standard.set(newValue, forKey: key)
                }
            }
        }
    }
}

protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool {
        return self == nil
    }
}

extension Bool: DefaultsSupportedType { }

extension Int: DefaultsSupportedType { }

extension Int8: DefaultsSupportedType { }

extension Int16: DefaultsSupportedType { }

extension Int32: DefaultsSupportedType { }

extension Int64: DefaultsSupportedType { }

extension UInt: DefaultsSupportedType { }

extension UInt8: DefaultsSupportedType { }

extension UInt16: DefaultsSupportedType { }

extension UInt32: DefaultsSupportedType { }

extension UInt64: DefaultsSupportedType { }

extension Float: DefaultsSupportedType { }

extension Double: DefaultsSupportedType { }

extension URL: DefaultsSupportedType { }

extension String: DefaultsSupportedType { }

extension Data: DefaultsSupportedType { }

extension Date: DefaultsSupportedType { }

extension Array: DefaultsSupportedType where Element: DefaultsSupportedType { }

extension Dictionary: DefaultsSupportedType where Key: DefaultsSupportedType, Value: DefaultsSupportedType { }
