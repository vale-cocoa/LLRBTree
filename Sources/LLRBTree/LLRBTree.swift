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
    
    /// Instantiates and returns a new empty Left-Leaning Red-Black Tree.
    ///
    /// - Returns: A new empty Left-Leaning Red-Black Tree instance.
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
    
    /// Returns a new instance initialized to contain all elements from given sequence.
    ///
    /// - Parameter elements:   A sequence containing key/value paris as elements to
    ///                         store in the new Left-Leaning Red-Black Tree instance.
    /// - Returns:  A new Left-Leaning Red-Black Tree instance containing all elements in
    ///             the given `elements` sequence.
    /// - Complexity:   O(*n*log*n*) where *n* is the number of elements contained
    ///                 in the given sequience.
    /// - Note: When the given sequence contains duplicate keys values in its elements,
    ///         the last element's value with the duplicate key willbe stored in the returned
    ///         instance.
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
    /// The number of elements stored in this Left-Leaning Red-Black Tree instance.
    /// - Complexity: O(1)
    public var count: Int { root?.count ?? 0 }
    
    /// A boolean value, `true` when no element is stored in this
    /// Left-Leaning Red-Black Tree instance.
    /// - Complexity: O(1)
    public var isEmpty: Bool { root == nil }
    
    /// The element with the smallest key stored in this Left-Leaning Red-Black Tree instance.
    /// Returns `nil` when `isEmpty` is `true`.
    /// - Complexity:   O(log *n*) where *n* is the number of stored elements in
    ///                 this Left-Leaning Red-Black Tree instance.
    public var min: Element? {
        guard let rootMin = root?.min else { return nil }
        
        return (rootMin.key, rootMin.value)
    }
    
    /// The element with the greatest key stored in this Left-Leaning Red-Black Tree instance.
    /// Returns `nil` when `isEmpty` is `true`.
    /// - Complexity:   O(log *n*) where *n* is the number of stored elements in
    ///                 this Left-Leaning Red-Black Tree instance.
    public var max: Element? {
        guard let rootMax = root?.max else { return nil }
        
        return (rootMax.key, rootMax.value)
    }
    /// The smallest key stored in this Left-Leaning Red-Black Tree instance.
    /// Returns `nil` when `isEmpty` is `true`.
    /// - Complexity:   O(log *n*) where *n* is the number of stored elements in
    ///                 this Left-Leaning Red-Black Tree instance.
    public var minKey: Key? { root?.minKey }
    
    /// The greatest key stored in this Left-Leaning Red-Black Tree instance.
    /// Returns `nil` when `isEmpty` is `true`.
    /// - Complexity:   O(log *n*) where *n* is the number of stored elements in
    ///                 this Left-Leaning Red-Black Tree instance.
    public var maxKey: Key? { root?.maxKey }
}

// MARK: - subscript and key/value based operations
extension LLRBTree {
    /// Access elements' values stored in this Left-Leaning Red-Black Tree instance, via keys.
    ///
    /// - Parameter key: The key of the element to access.
    /// - Returns: The value stored for the given key or `nil` if such key is not present.
    /// - Note: The subscript can be used to update, insert or delete an element:
    ///         ```
    ///         var tree = LLRBTree<String, Int>()
    ///         tree["A"] = 1
    ///         // ("A", 1) is inserted in tree
    ///
    ///         print("\(tree["A"] ?? "nil")")
    ///         // prints 1
    ///
    ///         tree["A"] = 3
    ///         // element with key "A" get its value updated to 3
    ///
    ///         print("\(tree["A"] ?? "nil")")
    ///         // prints 3
    ///
    ///         tree["A"] = nil
    ///         // removes the element with key "A"
    ///
    ///         print("\(tree["A"] ?? "nil")")
    ///         // prints nil
    ///         ```
    /// - Complexity:   Amortized O(log *n*) where *n* is the count of
    ///                 this Left-Leaning Red-Black Tree instance.
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
    
    /// Get the value stored for given key, if such key exists in
    /// this Left-Leaning Red-Black Tree instance.
    ///
    /// - Parameter forKey: The key to use for retrieving the element's value.
    /// - Returns:  The value stored in the element with such given key, `nil` if such
    ///             element does not exist in this Left-Leaning Red-Black Tree instance.
    /// - Complexity:   O(log *n*) where *n* is the count of
    ///                 this Left-Leaning Red-Black Tree instance.
    public func value(forKey key: Key) -> Value? {
        root?.value(forKey: key)
    }
    
    /// Set the given value for the given key. If such key exists in
    /// this Left-Leaning Red-Black Tree instance then the element's value with such key
    /// gets updated to the given value; otherwise a new element with the given
    /// key/value pair gets created and inserted in the tree.
    ///
    /// - Parameter value: the new value to set for the given key.
    /// - Parameter forKey: The key to use for retrieving the element's value or
    ///                     to insert in the tree if it doesn't exixts.
    /// - Returns:  The value stored in the element with such given key, `nil` if such
    ///             element does not exist in this Left-Leaning Red-Black Tree instance.
    /// - Complexity:   Amortized O(log *n*) where *n* is the count of
    ///                 this Left-Leaning Red-Black Tree instance.
    public func setValue(_ value: Value, forKey key: Key) {
        if let r = root {
            r.setValue(value, forKey: key)
        } else {
            root = LLRBTree.Node(key: key, value: value)
        }
        root!.color = .black
    }
    
    /// Removes the element with the given key from this Left-Leaning Red-Black Tree instance.
    ///
    /// - Parameter forKey: The key of the element to remove.
    /// - Complexity:   Amortized O(log *n*) where *n* is the count of
    ///                 this Left-Leaning Red-Black Tree instance.
    public func removeValue(forKey key: Key) {
        root = root?.removingValue(forKey: key)
        root?.color = .black
    }
    
    /// Removes the element with the smallest key from
    /// this Left-Leaning Red-Black Tree instance.
    ///
    /// - Complexity:   Amortized O(log *n*) where *n* is the count of
    ///                 this Left-Leaning Red-Black Tree instance.
    public func removeValueForMinKey() {
        root = root?.removingValueForMinKey()
        root?.color = .black
    }
    
    /// Removes the element with the greatest key from
    /// this Left-Leaning Red-Black Tree instance.
    ///
    /// - Complexity:   Amortized O(log *n*) where *n* is the count of
    ///                 this Left-Leaning Red-Black Tree instance.
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
    /// Returns a new Left-Leaning Red-Black Tree containing the keys of this
    /// Left-Leaning Red-Black Tree with the values transformed by the given closure.
    ///
    /// - Parameter transform:  A closure that transforms a value.
    ///                         transform accepts each value of the
    ///                         Left-Leaning Red-Black Tree as its
    ///                         parameter and returns a transformed value
    ///                         of the same or of a different type.
    /// - Returns:  A Left-Leaning Red-Black Tree containing the keys and
    ///             transformed values of this Left-Leaning Red-Black Tree.
    /// - Complexity:   O(*n*) where *n* is the count of elements
    ///                 in this Left-Leaning Red-Black Tree.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> LLRBTree<Key, T> {
        let mappedRoot = try root?.mapValues(transform)
        let transformed = LLRBTree<Key, T>()
        transformed.root = mappedRoot
        
        return transformed
    }
    
    /// Returns a new Left-Leaning Red-Black Tree containing only the key-value
    /// pairs that have non-nil values as the result of transformation by the given
    /// closure.
    ///
    /// Use this method to receive a Left-Leaning Red-Black Tree  with non-optional
    /// values when your transformation produces optional values.
    ///
    /// In this example, note the difference in the result of using mapValues and
    /// compactMapValues with a transformation that returns an optional Int value.
    /// ```
    ///     let data: LLRBTree = [
    ///         "a": "1",
    ///         "b": "three",
    ///         "c": "///4///"
    ///     ]
    ///
    ///     let m: LLRBTree<String, Int?> = data
    ///         .mapValues { str in Int(str) }
    ///     // ["a": 1, "b": nil, "c": nil]
    ///
    ///     let c: LLRBTRee<String,Int> = data
    ///         .compactMapValues { str in Int(str) }
    ///     // ["a": 1]
    /// ```
    /// - Parameter transform:  A closure that transforms a value.
    ///                         transform accepts each value of the
    ///                         Left-Leaning Red-Black Tree as its
    ///                         parameter and returns an optional
    ///                         transformed value of the same or of a
    ///                         different type.
    /// - Returns:  A Left-Leaning Red-Black Tree containing the keys and
    ///             non-nil transformed values of this
    ///             Left-Leaning Red-Black Tree.
    /// - Complexity:   O(*m* + *n*) where *n* is the count of elements
    ///                 in this Left-Leaning Red-Black Tree,
    ///                 and *m* is the count of the resulting
    ///                 Left_Leaning Red-Black Tree.
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

// MARK: - Hashable conformance
extension LLRBTree: Hashable where Key: Hashable, Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(count)
        root?.forEach {
            hasher.combine($0.0)
            hasher.combine($0.1)
        }
    }
    
}
