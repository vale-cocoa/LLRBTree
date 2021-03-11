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

extension LLRBTree: BidirectionalCollection {
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
    public var startIndex: Index {
        Index(asStartIndexOf: self)
    }
    
    @inline(__always)
    public var endIndex: Index {
        Index(asEndIndexOf: self)
    }
    
    @inlinable
    public var first: Element? { min }
    
    @inlinable
    public var last: Element? { max }
    
    public func index(after i: Index) -> Index {
        precondition(i.isValidFor(tree: self), "invalid index")
        var next = i
        next.formSuccessor()
        
        return next
    }
    
    public func formIndex(after i: inout Index) {
        precondition(i.isValidFor(tree: self), "invalid index")
        i.formSuccessor()
    }
    
    public func index(before i: Index) -> Index {
        precondition(i.isValidFor(tree: self), "invalid index")
        var before = i
        before.formPredecessor()
        
        return before
    }
    
    public func formIndex(before i: inout Index) {
        precondition(i.isValidFor(tree: self), "invalid index")
        i.formPredecessor()
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
    public subscript(position: Index) -> Element {
        get {
            precondition(position.isValidFor(tree: self), "invalid index")
            precondition(!position.path.isEmpty, "index out of bounds")
            
            return position.path.last!.node.element
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
    /// - Complexity: Amortized O(1).
    @discardableResult
    public mutating func remove(at index: Index) -> Element {
        precondition(index >= startIndex && index < endIndex, "index out of bounds")
        let e = index.path.last!.node.element
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
    public func index(forKey key: Key) -> Index? {
        let idx = Index(asIndexOfKey: key, for: self)
        
        return idx < endIndex ? idx : nil
    }
    
}

extension LLRBTree {
    /// The position of a key-value pair in a tree.
    ///
    /// Tree has two subscripting interfaces:
    ///
    /// 1. Subscripting with a key, yielding an optional value:
    ///
    ///        v = d[k]!
    ///
    /// 2. Subscripting with an index, yielding a key-value pair:
    ///
    ///        (k, v) = d[i]
    public struct Index {
        var id: ID
        
        var root: WrappedNode<LLRBTree.Node>? = nil
        
        var path: [WrappedNode<LLRBTree.Node>] = []
        
        init(asStartIndexOf tree: LLRBTree) {
            self.id = tree.id
            if tree.root != nil {
                let wRoot = WrappedNode(node: tree.root!)
                self.root = wRoot
                self.path = [WrappedNode(node: tree.root!)] + tree.root!.pathToMin
            }
        }
        
        init(asEndIndexOf tree: LLRBTree) {
            self.id = tree.id
            if tree.root != nil {
                self.root = WrappedNode(node: tree.root!)
            }
        }
        
        init(asIndexOfKey k: Key, for tree: LLRBTree) {
            self.id = tree.id
            if tree.root != nil {
                self.root = WrappedNode(node: tree.root!)
                var found = false
                var currentNode: WrappedNode? = WrappedNode(node: tree.root!)
                while !found && currentNode != nil {
                    self.path += [currentNode!]
                    if k == currentNode!.node.key {
                        found = true
                        break
                    } else if k < currentNode!.node.key {
                        currentNode = currentNode!.wrappedLeft
                    } else {
                        currentNode = currentNode!.wrappedRight
                    }
                }
                
                guard
                    found
                else {
                    self.path = []
                    
                    return
                }
            }
        }
        
        func isValidFor(tree: LLRBTree) -> Bool {
            tree.id === id
        }
        
        mutating func formSuccessor() {
            // index of empty tree, no successor to form.
            guard root != nil else { return }
            
            // already endIndex, no successor to form
            guard var this = path.popLast() else { return }
            
            // index has a right subtree,
            // successor is its min
            if let r = this.wrappedRight {
                path.append(contentsOf: [this, r] + r.node.pathToMin)
                
                return
            }
            
            // We ought move back in the path to form
            // successor
            while let last = path.last {
                // index was the left of previous node in path,
                // we're done
                guard
                    this.node !== last.node.left
                else { break }
                
                // get back in path
                this = path.popLast()!
            }
        }
        
        mutating func formPredecessor() {
            // index of empty tree, no predecessor to form.
            guard root != nil else { return }
            
            // endIndex, predecessor is root's rightmost node
            guard !path.isEmpty else {
                path = [root!] + root!.node.pathToMax
                
                return
            }
            
            var this = path.popLast()!
            
            // index has a left subtree,
            // predecessor is its max
            if let l = this.wrappedLeft {
                path.append(contentsOf: [this, l] + l.node.pathToMax)
                
                return
            }
            
            // we ought move back in path to form
            // predecessor
            while let last = path.last {
                // index was the right of previous node in
                // path, we're done
                guard
                    this.node !== last.node.right
                else { break }
                
                // get back in path
                this = path.popLast()!
            }
        }
        
    }
    
}

extension LLRBTree.Index: Comparable {
    public static func ==(lhs: LLRBTree<Key, Value>.Index, rhs: LLRBTree<Key, Value>.Index) -> Bool {
        precondition(areValid(lhs: lhs, rhs: rhs), "Cannot compare indices from two different tree instances.")
        guard
            lhs.path.count == rhs.path.count
        else { return false }
        
        return lhs.path.last?.node === rhs.path.last?.node
    }
    
    public static func <(lhs: LLRBTree<Key, Value>.Index, rhs: LLRBTree<Key, Value>.Index) -> Bool {
        precondition(areValid(lhs: lhs, rhs: rhs), "Cannot compare indices from two different tree instances.")
        switch (lhs.path.last?.node.key, rhs.path.last?.node.key) {
        case (nil, nil): return false
        case (nil, .some(_)): return false
        case (.some(_), nil): return true
        case (.some(let lKey), .some(let rKey)):
            return lKey < rKey
        }
    }
    
    static func areValid(lhs: LLRBTree.Index, rhs: LLRBTree.Index) -> Bool {
        lhs.id === rhs.id
    }
    
}




