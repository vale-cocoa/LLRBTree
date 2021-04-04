//
//  LLRBTree+CRUD.swift
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
    /// Get the value stored for given key, if such key exists in this tree.
    ///
    /// - Parameter forKey: The key to use for retrieving the element's value.
    /// - Returns:  The value stored in the element with such given key,
    ///             `nil` if such element does not exist in this tree.
    /// - Complexity:   O(log *n*) where *n* is the lenght of this tree.
    public func getValue(forKey key: Key) -> Value? {
        root?.getValue(forKey: key)
    }
    
    /// Updates the value stored in the tree for the given key, or adds a
    /// new key-value pair if the key does not exist.
    ///
    /// Use this method instead of key-based subscripting when you need to know
    /// whether the new value supplants the value of an existing key. If the
    /// value of an existing key is updated, `updateValue(_:forKey:)` returns
    /// the original value. This method will invalidate all indices of the tree previously stored.
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
    /// If the key is found in the tree, this method returns the key's
    /// associated value. This method will invalidate all indices of the tree previously stored.
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
    public mutating func removeValue(forKey key: Key) -> Value? {
        defer {
            root?.color = .black
        }
        makeUnique()
        let result = root?.removingElement(withKey: key)
        root = result?.node
        
        return result?.element?.value
    }
    
    /// Removes the element with the smallest key from the tree.
    ///
    /// If the treee is not empty, this method returns the smallests key's
    /// associated value. This method will invalidate all indices of the tree previously stored.
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
        defer {
            root?.color = .black
        }
        makeUnique()
        let result = root?.removingElementWithMinKey()
        root = result?.node
        
        return result?.element?.value
    }
    
    /// Removes the element with the largest key from the tree.
    ///
    /// If the treee is not empty, this method returns the largest key's
    /// associated value. This method will invalidate all indices of the tree previously stored.
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
        defer {
            root?.color = .black
        }
        makeUnique()
        let result = root?.removingElementWithMaxKey()
        root = result?.node
        
        return result?.element?.value
    }
    
    /// Removes all key-value pairs from the tree.
    ///
    /// Calling this method invalidates all indices of the tree previously stored
    ///
    /// - Complexity: O(1).
    public mutating func removeAll() {        
        root = nil
    }
    
}
