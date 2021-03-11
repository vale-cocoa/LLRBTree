//
//  LLRBTree+Initializers.swift
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

extension LLRBTree {
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
            self.init(keysAndValues) { _, _ in
                preconditionFailure("uniqueKeysWithValues must contain unique keys")
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
        var newRoot: LLRBTree.Node? = nil
        let done: Bool = try keysAndValues
            .withContiguousStorageIfAvailable { kvBuffer in
                let kvCount = kvBuffer.count
                guard
                    kvBuffer.baseAddress != nil && kvCount > 0
                else { return true }
                
                let firstElement = kvBuffer.first!
                newRoot = LLRBTree.Node(key: firstElement.key, value: firstElement.value, color: .black)
                for element in kvBuffer.dropFirst() {
                    try newRoot!.setValue(element.value, forKey: element.key, uniquingKeysWith: combine)
                    newRoot!.color = .black
                }
                return true
            } ?? false
        if !done {
            var iter = keysAndValues.makeIterator()
            guard
                let firstElement = iter.next()
            else {
                self.init()
                
                return
            }
            
            newRoot = LLRBTree.Node(key: firstElement.key, value: firstElement.value, color: .black)
            while let element = iter.next() {
                try newRoot!.setValue(element.value, forKey: element.key, uniquingKeysWith: combine)
                newRoot!.color = .black
            }
        }
        self.init(newRoot)
    }
    
    /// Creates a new tree whose keys are the groupings returned by the
    /// given closure and whose values are arrays of the elements that returned
    /// each key.
    ///
    /// The arrays in the "values" position of the tree each contain at
    /// least one element, with the elements in the same order as the source
    /// sequence.
    ///
    /// The following example declares an array of names, and then creates a
    /// tree from that array by grouping the names by first letter:
    ///
    ///     let students = ["Kofi", "Abena", "Efua", "Kweku", "Akosua"]
    ///     let studentsByLetter = LLRBTree(grouping: students, by: { $0.first! })
    ///     // ["E": ["Efua"], "K": ["Kofi", "Kweku"], "A": ["Abena", "Akosua"]]
    ///
    /// The new `studentsByLetter` tree has three entries, with students'
    /// names grouped by the keys `"E"`, `"K"`, and `"A"`.
    ///
    /// - Parameters:
    ///   - values: A sequence of values to group into a tree.
    ///   - keyForValue: A closure that returns a key for each element in
    ///     `values`.
    public init<S>(grouping values: S, by keyForValue: (S.Element) throws -> Key) rethrows where Value == [S.Element], S : Sequence {
        var newRoot: LLRBTree<Key, Value>.Node? = nil
        let done: Bool = try values
            .withContiguousStorageIfAvailable { vBuff in
                guard
                    vBuff.baseAddress != nil && vBuff.count > 0
                else { return true }
                
                let firstValue = vBuff.first!
                let firstKey = try keyForValue(firstValue)
                newRoot = LLRBTree.Node(key: firstKey, value: [firstValue], color: .black)
                for v in vBuff.dropFirst() {
                    let k = try keyForValue(v)
                    newRoot!.setValue([v], forKey: k, uniquingKeysWith: +)
                    newRoot!.color = .black
                }
                
                return true
            } ?? false
        if !done {
            var iter = values.makeIterator()
            if let firstValue = iter.next() {
                let firstKey = try keyForValue(firstValue)
                newRoot = LLRBTree.Node(key: firstKey, value: [firstValue], color: .black)
                while let v = iter.next() {
                    let k = try keyForValue(v)
                    newRoot!.setValue([v], forKey: k, uniquingKeysWith: +)
                    newRoot!.color = .black
                }
            }
        }
        self.init(newRoot)
    }
    
}

// MARK: - ExpressibleByDictionaryLiteral conformance
extension LLRBTree: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
    
}
