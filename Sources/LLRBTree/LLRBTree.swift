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
/// - ToDo: Conformormance to CustomStringConvertible and CustomDebugStringConvertible
public struct LLRBTree<Key: Comparable, Value> {
    final class ID {  }
    
    fileprivate(set) var root: Node? = nil
    
    fileprivate(set) var id: ID = ID()
    
    /// Instantiates and returns a new empty tree.
    ///
    /// - Returns: A new empty tree.
    public init() { }
    
    // MARK: - Internal initializers
    init(_ other: LLRBTree) {
        self.id = other.id
        self.root = other.root
    }
    
    init(_ root: LLRBTree.Node?) {
        self.root = root
    }
    
    // MARK: - Copy On Write and ID helpers
    @inline(__always)
    mutating func makeUnique() {
        if !isKnownUniquelyReferenced(&root) {
            root = root?.clone()
        }
    }
    
    @inline(__always)
    mutating func invalidateIndices() {
        id = ID()
    }
    
}

// MARK: - Computed properties
extension LLRBTree {
    
    
}

// MARK: - key subscript and key/value based operations
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
            getValue(forKey: key)
        }
        
        mutating set {
            if let value = newValue {
                setValue(value, forKey: key)
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    /// Accesses the value with the given key. If tree doesn't contain
    /// the given key, accesses the provided default value as if the key and
    /// default value existed in the hash table.
    ///
    /// Use this subscript when you want either the value for a particular key
    /// or, when that key is not present in the hash table, a default value.
    /// The setter of this subscript invalidates all indices of the tree.
    /// This example uses the subscript with a message to use in case an HTTP response
    /// code isn't recognized:
    ///
    ///     var responseMessages: LLRBTree<Int, String> = [
    ///         200: "OK",
    ///         403: "Access forbidden",
    ///         404: "File not found",
    ///         500: "Internal server error"
    ///     ]
    ///
    ///     let httpResponseCodes = [200, 403, 301]
    ///     for code in httpResponseCodes {
    ///         let message = responseMessages[code, default: "Unknown response"]
    ///         print("Response \(code): \(message)")
    ///     }
    ///     // Prints "Response 200: OK"
    ///     // Prints "Response 403: Access Forbidden"
    ///     // Prints "Response 301: Unknown response"
    ///
    /// When a tree's `Value` type has value semantics, you can use this
    /// subscript to perform in-place operations on values in the tree.
    /// The following example uses this subscript while counting the occurrences
    /// of each letter in a string:
    ///
    ///     let message = "Hello, Elle!"
    ///     var letterCounts: LLRBTree<Character, Int> = [:]
    ///     for letter in message {
    ///         letterCounts[letter, default: 0] += 1
    ///     }
    ///     // letterCounts == ["H": 1, "e": 2, "l": 4, "o": 1, ...]
    ///
    /// When `letterCounts[letter, defaultValue: 0] += 1` is executed with a
    /// value of `letter` that isn't already a key in `letterCounts`, the
    /// specified default value (`0`) is returned from the subscript,
    /// incremented, and then added to the tree under that key.
    ///
    /// - Note: Do not use this subscript to modify tree values if the
    ///   dictionary's `Value` type is a class. In that case, the default value
    ///   and key are not written back to the tree after an operation.
    ///
    /// - Parameters:
    ///   - key: The key to look up in the tree.
    ///   - defaultValue:   The default value to use if `key` doesn't exist
    ///                     in the tree.
    /// - Returns:  The value associated with `key` in the tree;
    ///             otherwise, `defaultValue`.
    public subscript(key: Key, default defaulValue: @autoclosure() -> Value) -> Value {
        get {
            getValue(forKey: key) ?? defaulValue()
        }
        
        mutating set {
            setValue(newValue, forKey: key)
        }
    }
    
    /// Get the value stored for given key, if such key exists in this tree.
    ///
    /// - Parameter forKey: The key to use for retrieving the element's value.
    /// - Returns:  The value stored in the element with such given key,
    ///             `nil` if such element does not exist in this tree.
    /// - Complexity:   O(log *n*) where *n* is the lenght of this tree.
    public func getValue(forKey key: Key) -> Value? {
        root?.getValue(forKey: key)
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
    
    /// Updates the value stored in the tree for the given key, or adds a
    /// new key-value pair if the key does not exist.
    ///
    /// Use this method instead of key-based subscripting when you need to know
    /// whether the new value supplants the value of an existing key. If the
    /// value of an existing key is updated, `updateValue(_:forKey:)` returns
    /// the original value. This method will invalidate all indices of the tree.
    ///
    ///     var hues: LLRBTree<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///
    ///     if let oldValue = hues.updateValue(18, forKey: "Coral") {
    ///         print("The old value of \(oldValue) was replaced with a new one.")
    ///     }
    ///     // Prints "The old value of 16 was replaced with a new one."
    ///
    /// If the given key is not present in the tree, this method adds the
    /// key-value pair and returns `nil`.
    ///
    ///     if let oldValue = hues.updateValue(330, forKey: "Cerise") {
    ///         print("The old value of \(oldValue) was replaced with a new one.")
    ///     } else {
    ///         print("No value was found in the tree for that key.")
    ///     }
    ///     // Prints "No value was found in the tree for that key."
    ///
    /// - Parameters:
    ///   - value: The new value to add to the tree.
    ///   - key:    The key to associate with `value`. If `key` already exists in
    ///             the hash table, `value` replaces the existing associated value.
    ///             If `key` isn't already a key of the hash table,
    ///             the `(key, value)` pair is added.
    /// - Returns:  The value that was replaced, or `nil` if a new key-value pair
    ///             was added.
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        defer {
            root!.color = .black
            id = ID()
        }
        if root != nil {
            makeUnique()
            
            return root!.updateValue(value, forKey: key)
        } else {
            root = LLRBTree.Node(key: key, value: value)
            
            return nil
        }
    }
    
    /// Removes the given key and its associated value from the tree.
    ///
    /// If the key is found in the treee, this method returns the key's
    /// associated value. This method invalidates all indices of the hash table.
    ///
    ///     var hues: LLRBTree<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     if let value = hues.removeValue(forKey: "Coral") {
    ///         print("The value \(value) was removed.")
    ///     }
    ///     // Prints "The value 16 was removed."
    ///
    /// If the key isn't found in the tree, `removeValue(forKey:)` returns
    /// `nil`.
    ///
    ///     if let value = hues.removeValueForKey("Cerise") {
    ///         print("The value \(value) was removed.")
    ///     } else {
    ///         print("No value found for that key.")
    ///     }
    ///     // Prints "No value found for that key.""
    ///
    /// - Parameter key: The key to remove along with its associated value.
    /// - Returns:  The value that was removed, or `nil` if the key was not
    ///             present in the tree.
    ///
    /// - Complexity: Amortized O(log *n*) where *n* is the lenght of this tree.
    @discardableResult
    public mutating func removeValue(forKey k: Key) -> Value? {
        makeUnique()
        let result = root?.removingElement(withKey: k)
        root = result?.node
        root?.color = .black
        id = ID()
        
        return result?.element?.value
    }
    
    /// Removes the element with the smallest key from the tree.
    ///
    /// If the treee is not empty, this method returns the smallests key's
    /// associated value. This method invalidates all indices of the hash table.
    ///
    ///     var hues: LLRBTree<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     if let value = hues.removeValueForMinKey() {
    ///         print("The value \(value) was removed.")
    ///     }
    ///     // Prints "The value 156 was removed."
    ///
    /// If the tree is empty, `removeValueForMinKey()` returns `nil`.
    ///
    ///     hues = LLRBTree()
    ///     if let value = hues.removeValueForMinKey() {
    ///         print("The value \(value) was removed.")
    ///     } else {
    ///         print("No value found for that key.")
    ///     }
    ///     // Prints "No value found for minKey.""
    ///
    /// - Returns:  The value that was removed, or `nil` if the tree was empty.
    ///
    /// - Complexity: Amortized O(log *n*) where *n* is the lenght of this tree.
    @discardableResult
    public mutating func removeValueForMinKey() -> Value? {
        makeUnique()
        let result = root?.removingElementWithMinKey()
        root = result?.node
        root?.color = .black
        id = ID()
        
        return result?.element?.value
    }
    
    /// Removes the element with the largest key from the tree.
    ///
    /// If the treee is not empty, this method returns the largest key's
    /// associated value. This method invalidates all indices of the hash table.
    ///
    ///     var hues: LLRBTree<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     if let value = hues.removeValueForMaxKey() {
    ///         print("The value \(value) was removed.")
    ///     }
    ///     // Prints "The value 296 was removed."
    ///
    /// If the tree is empty, `removeValueForMaxKey()` returns `nil`.
    ///
    ///     hues = LLRBTree()
    ///     if let value = hues.removeValueForMaxKey() {
    ///         print("The value \(value) was removed.")
    ///     } else {
    ///         print("No value found for that key.")
    ///     }
    ///     // Prints "No value found for minKey.""
    ///
    /// - Returns:  The value that was removed, or `nil` if the tree was empty.
    ///
    /// - Complexity: Amortized O(log *n*) where *n* is the lenght of this tree.
    @discardableResult
    public mutating func removeValueForMaxKey() -> Value? {
        makeUnique()
        let result = root?.removingElementWithMaxKey()
        root = result?.node
        root?.color = .black
        id = ID()
        
        return result?.element?.value
    }
    
    /// Removes all key-value pairs from the tree.
    ///
    /// Calling this method invalidates all indices of the tree.
    ///
    /// - Complexity: O(1).
    public mutating func removeAll() {
        id = ID()
        root = nil
    }
    
}

// MARK: - Additional methods
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
    
    /// Merges the given tree into this tree, using a combining
    /// closure to determine the value for any duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the updated
    /// tree, or to combine existing and new values. As the key-values
    /// pairs in `other` are merged with this tree, the `combine` closure
    /// is called with the current and new values for any duplicate keys that
    /// are encountered.
    ///
    /// This method might invalidate all indices of the hash table.
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     var dictionary: LLRBTree<String, Int> = ["a": 1, "b": 2]
    ///     var other = LLRBTree<String, Int> = ["a": 3, "c": 4]
    ///
    ///     // Keeping existing value for key "a":
    ///     dictionary.merge(other) { (current, _) in current }
    ///     // ["b": 2, "a": 1, "c": 4]
    ///
    ///     // Taking the new value for key "a":
    ///     other = ["a": 5, "d": 6]
    ///     dictionary.merge(other) { (_, new) in new }
    ///     // ["b": 2, "a": 5, "c": 4, "d": 6]
    ///
    /// - Parameters:
    ///   - other:  A tree to merge.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final tree.
    public mutating func merge(_ other: LLRBTree, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        guard !other.isEmpty else { return }
        
        id = ID()
        for element in other {
            try setValue(element.value, forKey: element.key, uniquingKeysWith: combine)
        }
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
        if let otherTree = other as? LLRBTree<Key, Value> {
            try self.merge(otherTree, uniquingKeysWith: combine)
            
            return
        }
        
        var otherIterator = other.makeIterator()
        guard
            let otherRootElement = otherIterator.next()
        else { return }
        
        id = ID()
        if root != nil {
            makeUnique()
            try root!.setValue(otherRootElement.value, forKey: otherRootElement.key, uniquingKeysWith: combine)
        } else {
            root = LLRBTree.Node(key: otherRootElement.key, value: otherRootElement.value, color: .black)
        }
        
        while let otherElement = otherIterator.next() {
            try root!.setValue(otherElement.value, forKey: otherElement.key, uniquingKeysWith: combine)
            root!.color = .black
        }
    }
    
    /// Creates a tree by merging the given tree into this
    /// tree, using a combining closure to determine the value for
    /// duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the returned
    /// tree, or to combine existing and new values. As the key-value
    /// pairs in `other` are merged with this tree, the `combine` closure
    /// is called with the current and new values for any duplicate keys that
    /// are encountered.
    ///
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     let dictionary: LLRBTRee<String, Int> = ["a": 1, "b": 2]
    ///     let other: LLRBTree<String, Int> = ["a": 3, "b": 4]
    ///
    ///     let keepingCurrent = dictionary.merging(other)
    ///           { (current, _) in current }
    ///     // ["b": 2, "a": 1]
    ///     let replacingCurrent = dictionary.merging(other)
    ///           { (_, new) in new }
    ///     // ["b": 4, "a": 3]
    ///
    /// - Parameters:
    ///   - other:  A tree to merge.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final tree.
    /// - Returns:  A new tree with the combined keys and values
    ///             of this tree and `other`.
    func merging(_ other: LLRBTree, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LLRBTree {
        guard !other.isEmpty else { return self }
        
        guard !self.isEmpty else { return other }
        
        var merged = self
        try merged.merge(other, uniquingKeysWith: combine)
        
        return merged
    }
    
    /// Creates a tree by merging key-value pairs in a sequence into the
    /// tree, using a combining closure to determine the value for
    /// duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the returned
    /// tree, or to combine existing and new values. As the key-value
    /// pairs are merged with the tree, the `combine` closure is called
    /// with the current and new values for any duplicate keys that are
    /// encountered.
    ///
    /// This example shows how to choose the current or new values for any
    /// duplicate keys:
    ///
    ///     let dictionary: LLRBTree<String, Int> = ["a": 1, "b": 2]
    ///     let newKeyValues = zip(["a", "b"], [3, 4])
    ///
    ///     let keepingCurrent = dictionary.merging(newKeyValues) { (current, _) in current }
    ///     // ["b": 2, "a": 1]
    ///     let replacingCurrent = dictionary.merging(newKeyValues) { (_, new) in new }
    ///     // ["b": 4, "a": 3]
    ///
    /// - Parameters:
    ///   - other:  A sequence of key-value pairs.
    ///   - combine:    A closure that takes the current and new values for any
    ///                 duplicate keys. The closure returns the desired value
    ///                 for the final tree.
    /// - Returns:  A new tree with the combined keys and values
    ///             of this tree and `other`.
    func merging<S>(_ other: S, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows -> LLRBTree where S : Sequence, S.Element == Element {
        if let otherTree = other as? LLRBTree<Key, Value> {
            
            return try merging(otherTree, uniquingKeysWith: combine)
        }
        
        guard
            !isEmpty
        else {
            
            return try LLRBTree(other, uniquingKeysWith: combine)
        }
        
        var merged = self
        try merged.merge(other, uniquingKeysWith: combine)
        
        return merged
    }
    
    /// Returns a new tree containing the key-value pairs of the tree
    /// that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes a key-value pair as its
    ///                         argument and returns a Boolean value
    ///                         indicating whether the pair
    ///                         should be included in the returned tree.
    /// - Returns: A tree of the key-value pairs that `isIncluded` allows.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> LLRBTree {
        guard !self.isEmpty else { return LLRBTree() }
        
        var filteredRoot: LLRBTree.Node? = nil
        for element in self.root! where try isIncluded(element) == true
        {
            guard
                filteredRoot != nil
            else {
                filteredRoot = LLRBTree.Node(key: element.key, value: element.value, color: .black)
                
                continue
            }
            
            filteredRoot!.setValue(element.value, forKey: element.key)
            filteredRoot!.color = .black
        }
        
        var filtered = LLRBTree()
        filtered.root = filteredRoot
        
        return filtered
    }
    
}
