//
//  TreeOperations.swift
//  LLRBTree
//
//  Created by Valeriano Della Longa on 2021/01/26.
//  Copyright © 2020 Valeriano Della Longa
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

/*
// MARK: - lookup(node:key:)
func lookup<Key: Comparable, Value>(node: LLRBTree<Key, Value>.Node?, key k: Key) -> Value? {
    guard let n = node else { return nil }
    
    if k < n.key { return lookup(node: n.left, key: k) }
    if k > n.key { return lookup(node: n.right, key: k) }
    if k == n.key { return n.value }
    
    return nil
}

// MARK: - set(_:value:forKey:)
func set<Key: Comparable, Value>(_ node: LLRBTree<Key, Value>.Node?, value v: Value, forKey k: Key) -> LLRBTree<Key, Value>.Node {
    guard
        var n = node
    else { return LLRBTree.Node(key: k, value: v) }
    
    if k < n.key {
        n.left = set(n.left, value: v, forKey: k)
    } else if k > n.key {
        n.right = set(n.right, value: v, forKey: k)
    } else {
        n.value = v
    }
    
    return fixUp(&n)
}


// MARK: - removeValue(_:forKey:), removeValueForMaxKey(_:), removeValueForMinKey(_:)
func removeValue<Key: Comparable, Value>(_ node: LLRBTree<Key, Value>.Node?, forKey k: Key) -> LLRBTree<Key, Value>.Node? {
    guard var n = node else { return nil }
    
    if k < n.key {
        if !n.hasRedLeftChild && !n.hasRedLeftGrandChild {
            n = moveRedLeft(&n)
        }
        n.left = removeValue(n.left, forKey: k)
    } else {
        if n.hasRedLeftChild { n = rotateRight(n) }
        if k == n.key && n.right == nil { return nil }
        if k == n.key {
            let rightMin = n.right!.min
            n.key = rightMin.key
            n.value = rightMin.value
            n.right = removeValueForMinKey(n.right)
        } else {
            n.right = removeValue(n.right, forKey: k)
        }
    }
    
    return fixUp(&n)
}

func removeValueForMaxKey<Key: Comparable, Value>(_ node: LLRBTree<Key, Value>.Node?) -> LLRBTree<Key, Value>.Node? {
    guard var n = node else { return nil }
    
    if n.hasRedLeftChild {
        n = rotateRight(n)
    }
    guard n.right != nil else { return nil }
    
    if (!n.hasRedRightChild && !n.right!.hasRedLeftChild) {
        n = moveRedRight(&n)
    }
    n.left = removeValueForMaxKey(n.left)
    
    return fixUp(&n)
}

func removeValueForMinKey<Key: Comparable, Value>(_ node: LLRBTree<Key, Value>.Node?) -> LLRBTree<Key, Value>.Node? {
    if node?.left == nil { return nil }
    var n = node!
    if (!n.hasRedLeftChild && !n.hasRedLeftGrandChild) {
        n = moveRedLeft(&n)
    }
    n.left = removeValueForMinKey(n.left)
    
    return fixUp(&n)
}

// MARK: - Tree manipulation utilites
func fixUp<Key: Comparable, Value>(_ node: inout LLRBTree<Key, Value>.Node) -> LLRBTree<Key, Value>.Node {
    if node.hasRedRightChild {
        node = rotateLeft(node)
    }
    if (node.hasRedLeftChild && node.hasRedLeftGrandChild) {
        node = rotateRight(node)
    }
    if (node.hasRedLeftChild && node.hasRedRightChild) {
        node.flipColors()
    }
    node.updateCount()
    
    return node
}

func rotateLeft<Key: Comparable, Value>(_ node: LLRBTree<Key, Value>.Node) -> LLRBTree<Key, Value>.Node {
    assert(node.right != nil, "Can't rotate left a node whose right child is nil!")
    let x = node.right!
    node.right = x.left
    x.left = node
    x.color = node.color
    node.color = .red
    x.count = node.count
    node.updateCount()
    
    return x
}

func rotateRight<Key: Comparable, Value>(_ node: LLRBTree<Key, Value>.Node) -> LLRBTree<Key, Value>.Node {
    assert(node.left != nil, "Can't rotate right a node whose left child is nil")
    let x = node.left!
    node.left = x.right
    x.right = node
    x.color = node.color
    node.color = .red
    x.count = node.count
    node.updateCount()
    
    return x
}

func moveRedLeft<Key: Comparable, Value>(_ node: inout LLRBTree<Key, Value>.Node) -> LLRBTree<Key, Value>.Node {
    node.flipColors()
    if (node.right?.hasRedLeftChild ?? false) {
        node.right = rotateRight(node.right!)
        node = rotateLeft(node)
        node.flipColors()
    }
    
    return node
}

func moveRedRight<Key: Comparable, Value>(_ node: inout LLRBTree<Key, Value>.Node) -> LLRBTree<Key, Value>.Node {
    node.flipColors()
    if node.hasRedLeftGrandChild {
        node = rotateRight(node)
        node.flipColors()
    }
    
    return node
}
*/
