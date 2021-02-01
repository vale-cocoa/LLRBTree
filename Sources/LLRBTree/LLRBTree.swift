//
//  LLRBTree.swift
//  LLRBTree
//  
//  Created by Valeriano Della Longa on 2021/01/26.
//  Copyright © 2020 Valeriano Della Longa
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies
//  of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
//  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
//  ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

/// A reference semantics data structure generic over `Key` and  `Value` types,
/// storing its elements in a prefectly balanced binary search tree.
public final class LLRBTree<Key: Comparable, Value>: NSCopying {
    var root: Node? = nil
    
    public init() { }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        
        return LLRBTree(self)
    }
    
}

// MARK: - ExpressibleByDictionaryLiteral conformance & other convenience initializers
extension LLRBTree: ExpressibleByDictionaryLiteral {
    public convenience init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(elements)
    }
    
    public convenience init<S: Sequence>(_ elements: S) where S.Element == (Key, Value) {
        if let other = elements as? LLRBTree<Key, Value> {
            self.init(other)
        } else {
            self.init()
            var iter = elements.makeIterator()
            guard let first = iter.next() else { return }
            
            self.root = LLRBTree.Node(key: first.0, value: first.1, color: .black)
            while let newElement = iter.next() {
                self.root!.setValue(newElement.1, forKey: newElement.0)
                self.root!.color = .black
            }
        }
    }
    
    convenience init(_ other: LLRBTree) {
        self.init()
        
        if let rootClone = other.root?.copy() {
            root = (rootClone as! LLRBTree<Key, Value>.Node)
        }
    }
    
}

// MARK: - Computed properties
extension LLRBTree {
    public var count: Int { root?.count ?? 0 }
    
    public var isEmpty: Bool { root == nil }
    
    public var min: Element? {
        guard let rootMin = root?.min else { return nil }
        
        return (rootMin.key, rootMin.value)
    }
    
    public var max: Element? {
        guard let rootMax = root?.max else { return nil }
        
        return (rootMax.key, rootMax.value)
    }
    
    public var minKey: Key? { root?.minKey }
    
    public var maxKey: Key? { root?.maxKey }
}

// MARK: - subscript and key/value based operations
extension LLRBTree {
    public subscript(key: Key) -> Value? {
        get {
            value(forKey: key)
        }
        
        set {
            if let value = newValue {
                setValue(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    public func value(forKey key: Key) -> Value? {
        root?.value(forKey: key)
    }
    
    public func setValue(_ value: Value, forKey key: Key) {
        if let r = root {
            r.setValue(value, forKey: key)
        } else {
            root = LLRBTree.Node(key: key, value: value)
        }
        root!.color = .black
    }
    
    public func removeValue(forKey key: Key) {
        root = root?.removingValue(forKey: key)
        root?.color = .black
    }
    
    public func removeValueForMinKey() {
        root = root?.removingValueForMinKey()
        root?.color = .black
    }
    
    public func removeValueForMaxKey() {
        root = root?.removingValueForMaxKey()
        root?.color = .black
    }
    
}

// MARK: - Sequence conformance
extension LLRBTree: Sequence {
    public typealias Element = (Key, Value)
    
    public var underestimatedCount: Int { root?.underestimatedCount ?? 0
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        root?.makeIterator() ?? AnyIterator { return nil }
    }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try root?.forEach(body)
    }
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try root?.filter(isIncluded) ?? []
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try root?.map(transform) ?? []
    }
    
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try root?.compactMap(transform) ?? []
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try compactMap(transform)
    }
    
    public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        try root?.flatMap(transform) ?? []
    }
    
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        try root?.reduce(into: initialResult, updateAccumulatingResult) ?? initialResult
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        try root?.reduce(initialResult, nextPartialResult) ?? initialResult
    }
    
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try root?.first(where: predicate)
    }
    
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try root?.contains(where: predicate) ?? false
    }
    
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        try root?.allSatisfy(predicate) ?? true
    }
    
    public func reversed() -> [Element] {
        root?.reversed() ?? []
    }
    
}

// MARK: - Additional FP methods
extension LLRBTree {
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> LLRBTree<Key, T> {
        let mappedRoot = try root?.mapValues(transform)
        let transformed = LLRBTree<Key, T>()
        transformed.root = mappedRoot
        
        return transformed
    }
    
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> LLRBTree<Key, T> {
        let transformed = LLRBTree<Key, T>()
        try root?.forEach { element in
            if let t = try transform(element.1) {
                transformed.setValue(t, forKey: element.0)
            }
        }
        
        return transformed
    }
    
}

// MARK: - Tree traversal
extension LLRBTree {
    public func inOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.inOrderTraverse({ try body($0.element) })
    }
    
    public func reverseInOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.reverseInOrderTraverse({ try body($0.element) })
    }
    
    public func preOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.preOrderTraverse({ try body($0.element) })
    }
    
    public func postOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.postOrderTraverse({ try body($0.element) })
    }
    
    public func levelOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.levelOrderTraverse({ try body($0.element) })
    }
    
}

// MARK: - Equatable conformance
extension LLRBTree: Equatable where Value: Equatable {
    public static func == (lhs: LLRBTree<Key, Value>, rhs: LLRBTree<Key, Value>) -> Bool {
        guard lhs !== rhs else { return true }
        
        switch (lhs.root, rhs.root) {
        case (nil, nil): break
        case (let lRoot, let rRoot) where lRoot == rRoot: break
        default: return false
        }
        
        return true
    }
    
}

// MARK: - Codable conformance
extension LLRBTree: Codable where Key: Codable, Value: Codable {
    public enum Error: Swift.Error {
        case valueForKeyCount
    }
    
    enum CodingKeys: String, CodingKey {
        case keys
        case values
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let elements = map { $0 }
        
        try container.encode(elements.map { $0.0 }, forKey: .keys)
        try container.encode(elements.map { $0.1 }, forKey: .values)
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = try container.decode(Array<Key>.self, forKey: .keys)
        let values = try container.decode(Array<Value>.self, forKey: .values)
        guard
            keys.count == values.count
        else { throw Error.valueForKeyCount }
        
        self.init(zip(keys, values))
    }
    
}
