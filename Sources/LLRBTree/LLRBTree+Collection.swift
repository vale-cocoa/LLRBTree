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
    
    public subscript(position: Index) -> (Key, Value) {
        get {
            precondition(position.isValidFor(tree: self), "invalid index")
            precondition(!position.path.isEmpty, "index out of bounds")
            
            return position.path.last!.node.element
        }
    }
    
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
                //self.path = pathToMinOf(wRoot)
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
            guard root != nil else { return }
            
            guard var this = path.popLast() else { return }
            
            while let last = path.last {
                guard this.node !== last.node.left else { break }
                
                if
                    let r = last.wrappedRight,
                    r.node !== this.node
                {
                    path.append(contentsOf: [r] + r.node.pathToMin)
                    
                    break
                }
                this = path.popLast()!
            }
        }
        
        func pathToMinOf(_ wrappedNode: WrappedNode<LLRBTree.Node>) -> [WrappedNode<LLRBTree.Node>] {
            var path = [wrappedNode]
            var current = wrappedNode
            while current.wrappedLeft != nil {
                path.append(current.wrappedLeft!)
                current = current.wrappedLeft!
            }
            
            return path
        }
        
        mutating func formPredecessor() {
            guard root != nil else { return }
            
            guard !path.isEmpty else {
                path = pathToMaxOf(root!)
                
                return
            }
            
            var this = path.popLast()!
            while let last = path.popLast() {
                guard
                    this.node !== last.node.right
                else { return }
                
                if
                    let l = last.wrappedLeft,
                    l.node !== this.node
                {
                    path.append(contentsOf: [l] + l.node.pathToMax)
                    
                    break
                }
                this = path.popLast()!
            }
            guard !path.isEmpty else {
                path.append(contentsOf: [root!] + root!.node.pathToMin)
                
                return
            }
        }
        
        func pathToMaxOf(_ wrappedNode: WrappedNode<LLRBTree.Node>) -> [WrappedNode<LLRBTree.Node>] {
            var path = [wrappedNode]
            var current = wrappedNode
            while current.wrappedRight != nil {
                path.append(current.wrappedRight!)
                current = current.wrappedRight!
            }
            
            return path
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
        case (nil, _): return false
        case (_, nil): return true
        case (let lKey, let rKey):
            return lKey! < rKey!
        }
    }
    
    static func areValid(lhs: LLRBTree.Index, rhs: LLRBTree.Index) -> Bool {
        lhs.id === rhs.id
    }
    
}
