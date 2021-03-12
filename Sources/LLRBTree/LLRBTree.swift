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
    
    var root: Node? = nil
    
    private(set) var id: ID = ID()
    
    /// Instantiates and returns a new empty tree.
    ///
    /// - Returns: A new empty tree.
    public init() { }
    
    // MARK: - Internal initializers
    init(_ root: LLRBTree.Node?) {
        self.root = root
    }
    
    init(_ other: LLRBTree) {
        self.id = other.id
        self.root = other.root
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
