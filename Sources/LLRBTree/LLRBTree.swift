//
//  LLRBTree.swift
//  LLRBTree
//  
//  Created by Valeriano Della Longa on 2021/01/26.
//  Copyright © 2021 Valeriano Della Longa
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

/// A value semantics data structure generic over `Key` and  `Value` types,
/// storing its elements in a prefectly balanced binary search tree.
///
/// Left-Leaning Red-Black Trees and Red-Black Trees were invented
/// by Robert Sedgewick.
/// This is a porting to Swift from its original Java implementation.
///
/// https://www.cs.princeton.edu/~rs/talks/LLRB/RedBlack.pdf
///
/// https://www.cs.princeton.edu/~rs/talks/LLRB/LLRB.pdf
///
/// - ToDo: Conformormance to CustomStringConvertible and CustomDebugStringConvertible, add more methods and initializers from Dictionary interface with relative tests
public struct LLRBTree<Key: Comparable, Value> {
    final class ID {  }
    
    var root: Node? = nil
    
    var id: ID = ID()
    
    /// Instantiates and returns a new empty tree.
    ///
    /// - Returns: A new empty tree.
    public init() { }
    
}

// MARK: - ExpressibleByDictionaryLiteral conformance & other initializers
extension LLRBTree: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
    
    /// Returns a new instance initialized to contain all elements from the given
    /// sequence of key/value pairs.
    /// Elements in the given sequence must have unique keys otherwise a runtime
    ///  error will occur.
    ///
    /// - Parameter uniqueKeysWithValues:   A sequence containing
    ///                                     key/value pairs
    ///                                     as elements to store
    ///                                     in the new tree.
    /// - Returns:  A new tree containing all elements from the given sequence.
    /// - Complexity:   O(*n* + log *n*) where *n* is the lenght
    ///                 of the given sequence.
    /// - Note: When the given sequence contains duplicate keys values in its
    ///         elements, a runtime error will occur.
    ///         Use `init(_:uniquingKeysWith:)` in case the sequence
    ///         might contain elements with duplicate keys.
    /// - Precondition: The sequence must not have duplicate keys.
    public init<S: Sequence>(uniqueKeysWithValues keysAndValues: S) where S.Iterator.Element == Element {
        if let other = keysAndValues as? LLRBTree<Key, Value> {
            self.init(other)
        } else {
            self.init()
            var iter = keysAndValues.makeIterator()
            guard let first = iter.next() else { return }
            
            self.root = LLRBTree.Node(key: first.0, value: first.1, color: .black)
            while let newElement = iter.next() {
                self.root!.setValue(newElement.1, forKey: newElement.0, uniquingKeysWith: { _, _ in
                    preconditionFailure("Given sequence must have unique keys.")
                })
                self.root!.color = .black
            }
        }
    }
    
    /// Creates a new instance from the key-value pairs in the given sequence, using
    /// a combining closure to determine the value for any duplicate keys.
    ///
    /// You use this initializer to create a tree when you
    /// have a sequence of key-value tuples that might have duplicate keys. As the
    /// tree is built, the initializer calls the combine closure with the current and new
    /// values for any duplicate keys. Pass a closure as combine that returns the
    /// value to use in the resulting tree: The closure can choose between the two
    /// values, combine them to produce a new value, or even throw an error.
    /// The following example shows how to choose the first and last values for any
    /// duplicate keys:
    ///
    /// ```
    ///     let pairsWithDuplicateKeys = [
    ///         ("a", 1),
    ///         ("b", 2),
    ///         ("a", 3),
    ///         ("b", 4)
    ///     ]
    ///
    ///     let firstValues = LLRBTree(pairsWithDuplicateKeys, uniquingKeysWith: { (first, _) in first })
    ///     // ["b": 2, "a": 1]
    ///
    ///     let lastValues = LLRBTree(pairsWithDuplicateKeys, uniquingKeysWith: { (_, last) in last })
    ///     // ["b": 4, "a": 3]
    ///
    /// ```
    /// - Parameter keysAndValues:  A sequence of key-value pairs to use
    ///                             for the new
    ///                             tree.
    /// - Parameter combine:    A closure that is called with the values for
    ///                         any duplicate keys that are encountered.
    ///                         The closure returns the desired value for
    ///                          the final tree.
    /// - Returns:  A new tree
    ///             containing all the elements in the given sequence, adopting
    ///             the given `combine` closure for uniquing elements with
    ///             duplicate keys.
    /// - Complexity:   Amortized O(*m* + log *n*) where *m* is the
    ///                 lenght of the given sequence,  and *n*is  the lenght of
    ///                 the the final tree.
    ///                 Assuming `combine` closure has O(1) complexity.
    public init<S>(_ keysAndValues: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S : Sequence, S.Iterator.Element == Element {
        self.init()
        try self.merge(keysAndValues, uniquingKeysWith: combine)
    }
    
    init(_ other: LLRBTree) {
        self.init()
        
        root = other.root?.clone()
    }
    
}

// MARK: - Computed properties
extension LLRBTree {
    /// The number of elements stored in this tree.
    ///
    /// - Complexity: O(1)
    public var count: Int { root?.count ?? 0 }
    
    /// A boolean value, `true` when no element is stored in this tree.
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool { root == nil }
    
    /// The element with the smallest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity: O(l1).
    public var min: Element? {
        guard let rootMin = root?.min else { return nil }
        
        return (rootMin.key, rootMin.value)
        /*
        root?.left?.pathToMin.last?.node.element ?? root?.left?.element ?? root?.element
        */
    }
    
    /// The element with the greatest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity:   O(1).
    public var max: Element? {
        /*
        guard let rootMax = root?.max else { return nil }
        
        return (rootMax.key, rootMax.value)
        */
        root?.right?.pathToMax.last?.node.element ?? root?.right?.element ?? root?.element
    }
    /// The smallest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity:   O(1).
    public var minKey: Key? { root?.minKey }
    
    /// The greatest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity:   O(1).
    public var maxKey: Key? { root?.maxKey }
}

// MARK: - subscript and key/value based operations
extension LLRBTree {
    /// Access elements' values stored in this tree, via keys subscription.
    ///
    /// - Parameter key: The key of the element to access.
    /// - Returns:  The value stored for the given key,
    ///             or `nil` if such key is not present.
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
    /// - Complexity:   Amortized O(log *n*) where *n* is
    ///                 the lenght of this tree.
    public subscript(key: Key) -> Value? {
        get {
            value(forKey: key)
        }
        
        mutating set {
            if let value = newValue {
                setValue(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    /// Get the value stored for given key, if such key exists in this tree.
    ///
    /// - Parameter forKey: The key to use for retrieving the element's value.
    /// - Returns:  The value stored in the element with such given key,
    ///             `nil` if such element does not exist in this tree.
    /// - Complexity:   O(log *n*) where *n* is the lenght of this tree.
    public func value(forKey key: Key) -> Value? {
        root?.value(forKey: key)
    }
    
    /// Set the given value for the given key. If such key exists in this tree
    /// then the element's value with such key gets updated to the given value;
    /// otherwise a new element with the given key/value pair gets
    /// created and inserted in the tree.
    ///
    /// - Parameter value: The new value to set for the given key.
    /// - Parameter forKey: The key to use for retrieving the element to
    ///                     update or to insert in the tree if it doesn't exists.
    /// - Complexity:   Amortized O(log *n*) where *n* is
    ///                 the lenght of this tree.
    public mutating func setValue(_ value: Value, forKey key: Key) {
        if root != nil {
            makeUnique()
            root!.setValue(value, forKey: key)
        } else {
            root = LLRBTree.Node(key: key, value: value)
        }
        root!.color = .black
        id = ID()
    }
    
    /// Removes the element with the given key from this tree.
    ///
    /// - Parameter forKey: The key of the element to remove.
    /// - Complexity:   Amortized O(log *n*) where *n* is
    ///                 the lenght of this tree.
    public mutating func removeValue(forKey key: Key) {
        makeUnique()
        root = root?.removingValue(forKey: key)
        root?.color = .black
        id = ID()
    }
    
    /// Removes the element with the smallest key from
    /// this tree.
    ///
    /// - Complexity:   Amortized O(log *n*) where *n* is
    ///                 the lenght of this tree.
    public mutating func removeValueForMinKey() {
        makeUnique()
        root = root?.removingValueForMinKey()
        root?.color = .black
        id = ID()
    }
    
    /// Removes the element with the greatest key from
    /// this tree.
    ///
    /// - Complexity:   Amortized O(log *n*) where *n* is
    ///                 the lenght of this tree.
    public mutating func removeValueForMaxKey() {
        makeUnique()
        root = root?.removingValueForMaxKey()
        root?.color = .black
        id = ID()
    }
    
}

// MARK: - rank(_:), floor(_:), ceiling(_:), selection(rank:) methods
extension LLRBTree {
    /// Get the postion of the given key in this tree, assuming keys in the tree are in
    /// ascendending order in the range `0..<count` as position values.
    ///
    /// The rank of a key in the tree tells us how many keys in that tree have value less
    /// than that key.
    /// Following is a trival example:
    ///
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "B" : 4,
    ///         "D" : 6,
    ///         "E" : -1,
    ///         "F" : 13,
    ///     ]
    ///
    ///     print(tree.rank("A"))
    ///     // prints 0
    ///     // because there is no smaller key than "A" in tree
    ///
    ///     print(tree.rank("B"))
    ///     // prints 0
    ///     // because there is no smaller key than "B" in tree
    ///
    ///     print(tree.rank("C"))
    ///     // prints 1
    ///     // because there is 1 smaller key than "C" in tree
    ///
    ///     print(tree.rank("F"))
    ///     // prints 3
    ///     // because there are 3 smaller keys than "F" in tree
    ///
    ///     print(tree.rank("H"))
    ///     // prints 4
    ///     // because there are 4 smaller keys than "H" in tree
    /// ```
    /// - Parameter key: The key to look for its rank.
    /// - Returns:  An `Int` value representing the position of the given key
    ///             in this tree.
    /// - Complexity: O(log*n*) where *n* is the lenght of this tree.
    /// - Note: When the given key is not in the tree, than the returned rank value
    ///         is the insert postion in the range `0...count`.
    public func rank(_ key: Key) -> Int {
        guard let root = root else { return 0 }
        
        return root.rank(key)
    }
    
    /// Get the largest included key in this tree, which is smaller than or equal
    /// to the given key.
    ///
    /// Following is an example of `floor(_:)` usage:
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "B" : 4,
    ///         "D" : 6,
    ///         "E" : -1,
    ///         "F" : 13,
    ///     ]
    ///
    ///     print(tree.floor("A"))
    ///     // prints nil since there is not a key in the tree
    ///     // preceding or equal to given key "A".
    ///
    ///     print(tree.floor("B"))
    ///     // prints "B" since "B" is in the tree.
    ///
    ///     print(tree.floor("C"))
    ///     // prints "B" since that is the key in tree
    ///     // immediately preceding given key "C".
    ///
    ///     print(tree.floor("L"))
    ///     // prints "F" since that is the key in tree
    ///     // immediately preceding given key "L"
    /// ```
    /// - Parameter key: The key to look for its floor key in this tree.
    /// - Returns:  The greatest included key in this tree, which is smaller than
    ///             or equal to given the key or `nil` if such key doesn't
    ///             exist in this tree.
    /// - Complexity: O(log*n*) where *n* is the lenght of this tree.
    public func floor(_ key: Key) -> Key? {
        
        return root?.floor(key)?.key
    }
    
    /// Get the smallest included key in this tree, which is larger than or equal
    /// to the given key.
    ///
    /// Following is an example of `ceiling(_:)` usage:
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "B" : 4,
    ///         "D" : 6,
    ///         "E" : -1,
    ///         "F" : 13,
    ///     ]
    ///
    ///     print(tree.ceiling("A"))
    ///     // prints "B" since that is the key in tree
    ///     // immediately after given "A" key
    ///
    ///     print(tree.ceiling("B"))
    ///     // prints "B" since "B" is in the tree.
    ///
    ///     print(tree.ceiling("C"))
    ///     // prints "D" since that is the key in tree
    ///     // immediately after given key "C".
    ///
    ///     print(tree.ceiling("L"))
    ///     // prints nil since in tree there is no key
    ///     // equals to or immediately after given key "L".
    /// ```
    /// - Parameter key: The key to look for its ceil key in this tree.
    /// - Returns:  The smallest included key in this tree, which is greater
    ///             than or equal to the given key or `nil` if such key doesn't
    ///             exists in this tree.
    /// - Complexity: O(log*n*) where *n* is the lenght of this tree.
    public func ceiling(_ key: Key) -> Key? {
        
        return root?.ceiling(key)?.key
    }
    
    /// Get the element from this tree at the given position, assuming each element
    /// is in ascending order in the range of `0..<count` as positions.
    ///
    /// Following is a trivial example of `select(position:)` usage
    ///
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "A" : 10,
    ///         "B" : 20,
    ///         "C" : 15,
    ///         "D" : 7,
    ///         "E" : 1
    ///     ]
    ///
    ///     let firstElement = tree.select(0)
    ///     // firstElement is ("A", 10)
    ///
    ///     let lastElement = tree.select(4)
    ///     // lastElements is ("E", 1)
    ///
    ///     for (postion, element) in tree.enumerated() {
    ///         let selected = tree.select(position)
    ///         // selected.key == element.key
    ///         // selected.value == element.value
    ///     }
    /// ```
    /// - Parameter position:   An `Int` value representing the position
    ///                         in this tree of the element to retrieve.
    ///                         **Must be positive and less than this tree lenght**.
    /// - Returns: The element in this tree at the given position.
    /// - Complexity: O(log *n*) where *n* is the lenght of this tree.
    /// - Precondition: The tree must not be empty and the given
    ///                 `position` value must be in range `0..<count`.
    public func select(position: Int) -> Element {
        precondition(!isEmpty, "cannot use select(rank:) when isEmpty == true")
        precondition(0..<count ~= position, "rank is out of bounds")
        
        return root!.select(rank: position).element
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
    /// Returns a new tree containing the keys of this tree with
    ///  the values transformed by the given closure.
    ///
    /// - Parameter transform:  A closure that transforms a value.
    ///                         transform accepts each value of the
    ///                         tree as its
    ///                         parameter and returns a transformed value
    ///                         of the same or of a different type.
    /// - Returns:  A tree containing the keys and transformed values
    ///             of this tree.
    /// - Complexity:   O(log *n*) where *n* is the lenght of this tree.
    public func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> LLRBTree<Key, T> {
        let mappedRoot = try root?.mapValues(transform)
        var transformed = LLRBTree<Key, T>()
        transformed.root = mappedRoot
        
        return transformed
    }
    
    /// Returns a new tree containing only the key-value pairs that have non-nil
    /// values as the result of transformation by the given closure.
    ///
    /// Use this method to receive a tree  with non-optional
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
    ///                         tree as its
    ///                         parameter and returns an optional
    ///                         transformed value of the same or of a
    ///                         different type.
    /// - Returns:  A tree containing the keys and
    ///             non-nil transformed values of this
    ///             tree.
    /// - Complexity:   O(*m* + *n*) where *n* is the lenght of this tree,
    ///                 and *m* is the lenght of the returned tree.
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> LLRBTree<Key, T> {
        var transformed = LLRBTree<Key, T>()
        try root?.forEach { element in
            if let t = try transform(element.1) {
                transformed.setValue(t, forKey: element.0)
            }
        }
        
        return transformed
    }
    
    /// Set the given value for the given key. If such key exists in this tree then the
    /// element's value with such key gets updated to the result of the `combine`
    /// closure called with the previously stored value and the new value.
    /// Otherwise a new element with the given key/value pair gets
    /// created and inserted in the tree.
    ///
    /// - Parameter value: The new value to set for the given key.
    /// - Parameter forKey: The key to use for retrieving the element's value or
    ///                     to insert in the tree if it doesn't exists.
    /// - Parameter combine:    A closure that is called with the values
    ///                         for a duplicate key that is encountered.
    ///                         The closure returns the desired value for
    ///                         updating the key.
    /// - Complexity:   Amortized O(log *n*) where *n* is the
    ///                 lenght of this tree.
    ///                 Assuming given `combine` closure
    ///                 has O(1) complexity.
    public mutating func setValue(_ value: Value, forKey key: Key, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        guard
            root != nil
        else {
            setValue(value, forKey: key)
            
            return
        }
        
        makeUnique()
        try root!
            .setValue(value, forKey: key, uniquingKeysWith: combine)
        root!.color = .black
        id = ID()
    }
    
    /// Merges the key-value pairs in the given sequence into the tree, using a
    /// combining closure to determine the value for any duplicate keys.
    ///
    /// Use the combine closure to select a value to use in the updated tree,
    /// or to combine existing and new values.
    /// As the key-value pairs are merged with the tree, the combine closure
    /// is called with the current and new values for any duplicate keys
    /// that are encountered.
    ///
    /// This example shows how to choose the current or new values
    ///  for any duplicate keys:
    ///
    /// ```
    ///     var tree: LLRBTree<String, Int> = ["a": 1, "b": 2]
    ///
    ///     // Keeping existing value for key "a":
    ///     tree .merge(zip(["a", "c"], [3, 4])) { (current, _) in current }
    ///     // ["b": 2, "a": 1, "c": 4]
    ///
    ///     // Taking the new value for key "a":
    ///     tree.merge(zip(["a", "d"], [5, 6])) { (_, new) in new }
    ///     // ["b": 2, "a": 5, "c": 4, "d": 6]
    /// ```
    /// - Parameter other: A sequence of key-value pairs.
    /// - Parameter combine:    A closure that takes the current and new
    ///                         values for any duplicate keys.
    ///                         The closure returns the desired value
    ///                         for the final tree.
    /// - Complexity:   Amortized O(*m* + log *n*) where *m* is the lenght
    ///                 of the given sequence, and *n* is the lenght of the
    ///                 final tree.
    ///                 Assuming `combine` closure has O(1) complexity.
    public mutating func merge<S: Sequence>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows where S.Iterator.Element == Element {
        id = ID()
        var otherIterator = other.makeIterator()
        guard
            let otherRootElement = otherIterator.next()
        else { return }
        
        if root != nil {
            makeUnique()
            try root!.setValue(otherRootElement.1, forKey: otherRootElement.0, uniquingKeysWith: combine)
        } else {
            root = LLRBTree.Node(key: otherRootElement.0, value: otherRootElement.1, color: .black)
        }
        
        while let otherElement = otherIterator.next() {
            try root!.setValue(otherElement.1, forKey: otherElement.0, uniquingKeysWith: combine)
            root!.color = .black
        }
    }
    
    /// Creates a tree by merging key-value pairs in a sequence into the tree,
    /// using a combining closure to determine the value for duplicate keys.
    ///
    /// Use the combine closure to select a value to use in the returned tree,
    /// or to combine existing and new values.
    /// As the key-value pairs are merged with the tree, the combine closure
    ///  is called with the current and new values for any duplicate keys
    ///  that are encountered.
    ///
    /// This example shows how to choose the current or new values
    /// for any duplicate keys:
    ///
    /// ```
    ///     let tree: LLRBTree<String, Int> = ["a": 1, "b": 2]
    ///     let newKeyValues = zip(["a", "b"], [3, 4])
    ///
    ///     let keepingCurrent = tree.merging(newKeyValues) { (current, _) in current }
    ///     // ["b": 2, "a": 1]
    ///
    ///     let replacingCurrent = tree.merging(newKeyValues) { (_, new) in new }
    ///     // ["b": 4, "a": 3]
    /// ```
    /// - Parameter other: A sequence of key-value pairs.
    /// - Parameter combine:    A closure that takes the current and new
    ///                         values for any duplicate keys.
    ///                         The closure returns the desired value
    ///                         for the final tree.
    /// - Returns:  A new tree with the combined keys and values
    ///             of this tree and other.
    /// - Complexity:   Amortized O(*m* + log *n*) where *m* is the
    ///                 lenght of the given sequence, and *n* is the
    ///                  lenght of the final tree.
    ///                 Assuming `combine` has O(1) complexity.
    public func merging<S: Sequence>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LLRBTree where S.Iterator.Element == Element {
        var new = self
        try new
            .merge(other, uniquingKeysWith: combine)
        
        return new
    }
    
}

// MARK: - Tree traversal
extension LLRBTree {
    /// Traverse the tree in-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func inOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.inOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in reverse-in-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func reverseInOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.reverseInOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in pre-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func preOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.preOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in post-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func postOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.postOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in level-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func levelOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.levelOrderTraverse({ try body($0.element) })
    }
    
}

// MARK: - Equatable conformance
extension LLRBTree: Equatable where Value: Equatable {
    public static func == (lhs: LLRBTree<Key, Value>, rhs: LLRBTree<Key, Value>) -> Bool {
        guard lhs.root !== rhs.root else { return true }
        
        switch (lhs.root, rhs.root) {
        case (nil, nil): return true
        case (nil, .some(_)): return false
        case (.some(_), nil): return false
        case (.some(let lRoot), .some(let rRoot)):
            
            return lRoot.elementsEqual(rRoot, by: { $0.0 == $1.0 && $0.1 == $1.1 })
        }
    }
    
}

// MARK: - Codable conformance
extension LLRBTree: Codable where Key: Codable, Value: Codable {
    public enum Error: Swift.Error {
        case valueForKeyCount
        case duplicateKeys
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
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let keys = try container.decode(Array<Key>.self, forKey: .keys)
        let values = try container.decode(Array<Value>.self, forKey: .values)
        guard
            keys.count == values.count
        else { throw Error.valueForKeyCount }
        
        try self.init(zip(keys, values), uniquingKeysWith: { _, _ in
            throw Error.duplicateKeys
        })
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
    
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
            
        return hasher.finalize()
    }
    
}

// MARK: - Copy On Write helpers
extension LLRBTree {
    mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&root) {
            root = root?.clone()
        }
    }
    
}
