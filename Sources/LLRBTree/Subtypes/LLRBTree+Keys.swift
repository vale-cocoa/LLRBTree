//
//  LLRBTree+Keys.swift
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

// MARK: - Keys type and keys computed property
extension LLRBTree {
    /// A view of a tree's keys
    public struct Keys: BidirectionalCollection, Equatable {
        let _tree: LLRBTree
        
        fileprivate init(_ tree: LLRBTree) {
            self._tree = tree
        }
        
        // BidirectionalCollection conformance
        public typealias Element = Key
        
        public typealias Index = LLRBTree<Key, Value>.Index
        
        public var count: Int { _tree.count }
        
        public var isEmpty: Bool { _tree.isEmpty }
        
        public var startIndex: Index { _tree.startIndex }
        
        public var endIndex: Index { _tree.endIndex }
        
        public func index(after i: Index) -> Index {
            _tree.index(after: i)
        }
        
        public func formIndex(after i: inout LLRBTree<Key, Value>.Index) {
            _tree.formIndex(after: &i)
        }
        
        public func index(before i: Index) -> Index {
            _tree.index(before: i)
        }
        
        public func formIndex(before i: inout LLRBTree<Key, Value>.Index) {
            _tree.formIndex(before: &i)
        }
        
        public subscript(position: Index) -> Key {
            _tree[position].key
        }
        
        // Equatable conformance
        public static func == (lhs: Keys, rhs: Keys) -> Bool {
            guard lhs._tree.root !== rhs._tree.root else { return true }
            
            return lhs._tree.elementsEqual(rhs._tree, by: { $0.key == $1.key })
        }
        
    }
    
    /// A collection containing just the keys of the tree.
    ///
    /// When iterated over, keys appear in this collection in the same order as
    /// they occur in the tree's key-value pairs. Each key in the keys
    /// collection has a unique value.
    ///
    ///     let countryCodes: LLRBTree<String, String> = ["BR": "Brazil", "GH": "Ghana", "JP": "Japan"]
    ///     print(countryCodes)
    ///     // Prints "["BR": "Brazil", "JP": "Japan", "GH": "Ghana"]"
    ///
    ///     for k in countryCodes.keys {
    ///         print(k)
    ///     }
    ///     // Prints "BR"
    ///     // Prints "JP"
    ///     // Prints "GH"
    ///
    /// - Complexity: O(*n*) where *n* is lenght of this hash table.
    @inline(__always)
    public var keys: Keys { Keys(self) }
    
}
