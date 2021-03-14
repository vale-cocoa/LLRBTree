//
//  LLRBTree+OtherOps.swift
//  LLRBTRee
//
//  Created by Valeriano Della Longa on 2021/03/11.
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

// MARK: - map values
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
                transformed.updateValue(t, forKey: element.0)
            }
        }
        
        return transformed
    }
    
}

// MARK: - Merge
extension LLRBTree {
    /// Merges the given tree into this tree, using a combining
    /// closure to determine the value for any duplicate keys.
    ///
    /// Use the `combine` closure to select a value to use in the updated
    /// tree, or to combine existing and new values. As the key-values
    /// pairs in `other` are merged with this tree, the `combine` closure
    /// is called with the current and new values for any duplicate keys that
    /// are encountered.
    ///
    /// This method will invalidate indices of the tree previously stored.
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
        guard
            !other.isEmpty
        else { return }
        
        guard !self.isEmpty else {
            self = other
            
            return
        }
        
        makeUnique()
        invalidateIndices()
        for element in other {
            try root!.setValue(element.value, forKey: element.key, uniquingKeysWith: combine)
            root!.color = .black
        }
        
    }
    
    /// Merges the key-value pairs in the given sequence into the tree, using a
    /// combining closure to determine the value for any duplicate keys.
    ///
    /// Use the combine closure to select a value to use in the updated tree,
    /// or to combine existing and new values.
    /// As the key-value pairs are merged with the tree, the combine closure
    /// is called with the current and new values for any duplicate keys
    /// that are encountered. This method will invalidate indices of the tree
    /// previously stored.
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
        guard
            !self.isEmpty
        else {
            self = try .init(other, uniquingKeysWith: combine)
            
            return
        }
        
        let done: Bool = try other
            .withContiguousStorageIfAvailable({ otherBuff in
                let otherCount = otherBuff.count
                guard
                    otherBuff.baseAddress != nil,
                    otherCount > 0
                else {
                    
                    return true
                }
                
                makeUnique()
                invalidateIndices()
                for element in otherBuff {
                    try self.root!.setValue(element.value, forKey: element.key, uniquingKeysWith: combine)
                    self.root!.color = .black
                }
                
                return true
            }) ?? false
        if !done {
            var otherIterator = other.makeIterator()
            guard
                let otherFirstElement = otherIterator.next()
            else { return }
            
            makeUnique()
            invalidateIndices()
            try root!.setValue(otherFirstElement.value, forKey: otherFirstElement.key, uniquingKeysWith: combine)
            root!.color = .black
            while let otherElement = otherIterator.next() {
                try root!.setValue(otherElement.value, forKey: otherElement.key, uniquingKeysWith: combine)
                root!.color = .black
            }
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
    
}

// MARK: - filter
extension LLRBTree {
    /// Returns a new tree containing the key-value pairs of the tree
    /// that satisfy the given predicate.
    ///
    /// - Parameter isIncluded: A closure that takes a key-value pair as its
    ///                         argument and returns a Boolean value
    ///                         indicating whether the pair
    ///                         should be included in the returned tree.
    /// - Returns: A tree of the key-value pairs that `isIncluded` allows.
    public func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> LLRBTree {
        let filteredRoot = try root?.filtered(isIncluded)
        
        return LLRBTree(filteredRoot)
    }
    
}
