//
//  LLRBTree+KeySubscripts.swift
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
    /// Accesses the value associated with the given key for reading and writing.
    ///
    /// This *key-based* subscript returns the value for the given key if the key
    /// is found in the tree, or `nil` if the key is not found.
    /// The setter of this subscript will invalidate indices of the tree previously stored.
    ///
    /// The following example creates a new tree and prints the value of a
    /// key found in the tree (`"Coral"`) and a key not found in the
    /// tree (`"Cerise"`).
    ///
    ///     var hues: LLRBTree<String, Int> = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     print(hues["Coral"])
    ///     // Prints "Optional(16)"
    ///     print(hues["Cerise"])
    ///     // Prints "nil"
    ///
    /// When you assign a value for a key and that key already exists, the
    /// tree overwrites the existing value. If the tree doesn't
    /// contain the key, the key and value are added as a new key-value pair.
    ///
    /// Here, the value for the key `"Coral"` is updated from `16` to `18` and a
    /// new key-value pair is added for the key `"Cerise"`.
    ///
    ///     hues["Coral"] = 18
    ///     print(hues["Coral"])
    ///     // Prints "Optional(18)"
    ///
    ///     hues["Cerise"] = 330
    ///     print(hues["Cerise"])
    ///     // Prints "Optional(330)"
    ///
    /// If you assign `nil` as the value for the given key, the tree
    /// removes that key and its associated value.
    ///
    /// In the following example, the key-value pair for the key `"Aquamarine"`
    /// is removed from the tree by assigning `nil` to the key-based
    /// subscript.
    ///
    ///     hues["Aquamarine"] = nil
    ///     print(hues)
    ///     // Prints "["Coral": 18, "Heliotrope": 296, "Cerise": 330]"
    ///
    /// - Parameter key: The key to find in the tree.
    /// - Returns:  The value associated with `key` if `key` is in the tree;
    ///             otherwise, `nil`.
    /// - Complexity:   Amortized O(log *n*) where *n* is
    ///                 the lenght of this tree.
    public subscript(key: Key) -> Value? {
        get {
            getValue(forKey: key)
        }
        
        mutating set {
            if let value = newValue {
                updateValue(value, forKey: key)
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
    /// The setter of this subscript invalidates indices of the tree previously stored.
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
    ///   tree's `Value` type is a class. In that case, the default value
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
        
        _modify {
            makeUnique()
            var other = Self()
            (self, other) = (other, self)
            defer {
                other.invalidateIndices()
                (self, other) = (other, self)
            }
            
            let node: LLRBTree.Node
            if other.root == nil {
                node = Node(key: key, value: defaulValue(), color: .black)
                other.root = node
            } else {
                if let existing = other.root!.binarySearch(key) {
                    node = existing
                } else {
                    other.root!.setValue(defaulValue(), forKey: key)
                    other.root!.color = .black
                    node = other.root!.binarySearch(key)!
                }
            }
    
            yield &node.value
        }
    }
    
}
