//
//  LLRBTree+Collection.swift
//  LLRBTree
//
//  Created by Valeriano Della Longa on 2021/02/06.
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
import BinaryNode

extension LLRBTree: BidirectionalCollection, RandomAccessCollection {
    /// The number of elements stored in this tree.
    ///
    /// - Complexity: O(1)
    @inline(__always)
    public var count: Int { root?.count ?? 0 }
    
    /// A boolean value, `true` when no element is stored in this tree.
    ///
    /// - Complexity: O(1)
    @inline(__always)
    public var isEmpty: Bool { root == nil }
    
    @inline(__always)
    public var startIndex: Int{ 0 }
    
    @inline(__always)
    public var endIndex: Int { count }
    
    public func index(after i: Int) -> Int {
        i + 1
    }
    
    public func formIndex(after i: inout Int) {
        i += 1
    }
    
    public func index(before i: Int) -> Int {
        i - 1
    }
    
    public func formIndex(before i: inout Int) {
        i -= 1
    }
    
    /// Accesses the key-value pair at the specified position.
    ///
    /// This subscript takes an index into the tree, instead of a key, and
    /// returns the corresponding key-value pair as a tuple. When performing
    /// collection-based operations that return an index into a tree, use
    /// this subscript with the resulting value.
    ///
    /// For example, to find the key for a particular value in a tree use
    /// the `firstIndex(where:)` method.
    ///
    ///     let countryCodes: LLRBTree<String, String> = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     if let index = countryCodes.firstIndex(where: { $0.value == "Japan" }) {
    ///         print(countryCodes[index])
    ///         print("Japan's country code is '\(countryCodes[index].key)'.")
    ///     } else {
    ///         print("Didn't find 'Japan' as a value in the dictionary.")
    ///     }
    ///     // Prints "("JP", "Japan")"
    ///     // Prints "Japan's country code is 'JP'."
    ///
    /// - Parameter position:   The position of the key-value pair to access.
    ///                         `position` must be a valid index of the tree
    ///                         and not equal to `endIndex`.
    /// - Returns:  A two-element tuple with the key and value corresponding to
    ///             `position`.
    /// - Complexity: Amortized O(log*n*) where *n* is the lenght of the tree.
    public subscript(position: Int) -> Element {
        get {
            precondition(0..<count ~= position, "Index out of bounds")
            
            return root!.select(rank: position).element
        }
    }
    
    /// Removes and returns the key-value pair at the specified index.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// tree.
    ///
    /// - Parameter index:  The position of the key-value pair to remove. `index`
    ///                     must be a valid index of the tree,
    ///                     and must not equal the tree's end index.
    /// - Returns: The key-value pair that correspond to `index`.
    ///
    /// - Complexity: Amortized O(log *n*) where *n* is the lenght of the tree.
    @discardableResult
    public mutating func remove(at index: Int) -> Element {
        precondition(0..<count ~= index, "Index out of bounds")
        let e = root!.select(rank: index).element
        defer {
            removeValue(forKey: e.key)
        }
        
        return e
    }
    
    /// Returns the index for the given key.
    ///
    /// If the given key is found in the tree, this method returns an index
    /// into the tree that corresponds with the key-value pair.
    ///
    ///     let countryCodes: LLRBTree<String, String> = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     let index = countryCodes.index(forKey: "JP")
    ///
    ///     print("Country code for \(countryCodes[index!].value): '\(countryCodes[index!].key)'.")
    ///     // Prints "Country code for Japan: 'JP'."
    ///
    /// - Parameter key: The key to find in the tree.
    /// - Returns:  The index for `key` and its associated value if `key` is in
    ///             the tree; otherwise, `nil`.
    public func index(forKey key: Key) -> Int? {
        guard
            let idx = root?.rank(key),
            idx < endIndex,
            root!.select(rank: idx).key == key
        else { return nil }
        
        return idx
    }
    
}
