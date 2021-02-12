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
    public var startIndex: Index {
        Index(asStartIndexOf: self)
    }
    
    public var endIndex: Index {
        Index(asEndIndexOf: self)
    }
    
    public var first: Element? { min }
    
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
    
    public subscript(position: Index) -> (Key, Value) {
        get {
            precondition(position.isValidFor(tree: self), "invalid index")
            precondition(!position.path.isEmpty, "index out of bounds")
            
            return position.path.last!.node.element
        }
    }
    
}

extension LLRBTree {
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
