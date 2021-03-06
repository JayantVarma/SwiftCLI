//
//  Option.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 3/28/17.
//  Copyright © 2017 jakeheis. All rights reserved.
//

public protocol Option {
    var names: [String] { get }
    var shortDescription: String { get }
    var identifier: String { get }
}

public extension Option {
    func usage(padding: Int) -> String {
        let spacing = String(repeating: " ", count: padding - identifier.count)
        return "\(identifier)\(spacing)\(shortDescription)"
    }
}

public class Flag: Option {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var value: Bool
    
    public var identifier: String {
        return names.joined(separator: ", ")
    }
    
    /// Creates a new flag
    ///
    /// - Parameters:
    ///   - names: the names for the flag; convention is to include a short name (-a) and a long name (--all)
    ///   - description: A short description of what this flag does for usage statements
    ///   - defaultValue: the default value of this flag; default false
    public init(_ names: String ..., description: String = "", defaultValue: Bool = false) {
        self.names = names
        self.value = defaultValue
        self.shortDescription = description
    }
    
    /// Toggles the flag's value; don't call directly
    public func toggle() {
        value = !value
    }
    
}

public protocol AnyKey: Option {
    func updateValue(_ value: String) -> Bool
}

public class Key<T: ConvertibleFromString>: AnyKey {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var value: T?
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    /// Creates a new key
    ///
    /// - Parameters:
    ///   - names: the names for the key; convention is to include a short name (-m) and a long name (--message)
    ///   - description: A short description of what this key does for usage statements
    public init(_ names: String ..., description: String = "") {
        self.names = names
        self.shortDescription = description
    }
    
    /// Toggles the key's value; don't call directly
    public func updateValue(_ value: String) -> Bool {
        guard let value = T.convert(from: value) else {
            return false
        }
        self.value = value
        return true
    }
    
}

public class VariadicKey<T: ConvertibleFromString>: AnyKey {
    
    public let names: [String]
    public let shortDescription: String
    public private(set) var values: [T]
    
    public var identifier: String {
        return names.joined(separator: ", ") + " <value>"
    }
    
    /// Creates a new variadic key
    ///
    /// - Parameters:
    ///   - names: the names for the key; convention is to include a short name (-m) and a long name (--message)
    ///   - description: A short description of what this key does for usage statements
    public init(_ names: String ..., description: String = "") {
        self.names = names
        self.shortDescription = description
        self.values = []
    }
    
    /// Toggles the key's value; don't call directly
    public func updateValue(_ value: String) -> Bool {
        guard let value = T.convert(from: value) else {
            return false
        }
        values.append(value)
        return true
    }
    
}

// MARK: - ConvertibleFromString

public protocol ConvertibleFromString {
    static func convert(from: String) -> Self?
}

extension String: ConvertibleFromString {
    public static func convert(from: String) -> String? {
        return from
    }
}

extension Int: ConvertibleFromString {
    public static func convert(from: String) -> Int? {
        return Int(from)
    }
}

extension Float: ConvertibleFromString {
    public static func convert(from: String) -> Float? {
        return Float(from)
    }
}

extension Double: ConvertibleFromString {
    public static func convert(from: String) -> Double? {
        return Double(from)
    }
}

extension Bool: ConvertibleFromString {
    public static func convert(from: String) -> Bool? {
        let lowercased = from.lowercased()
        
        if ["y", "yes", "t", "true"].contains(lowercased) { return true }
        if ["n", "no", "f", "false"].contains(lowercased) { return false }
        
        return nil
    }
}

extension RawRepresentable where RawValue: ConvertibleFromString {
    public static func convert(from: String) -> Self? {
        guard let val = RawValue.convert(from: from) else {
            return nil
        }
        return Self.init(rawValue: val)
    }
}
