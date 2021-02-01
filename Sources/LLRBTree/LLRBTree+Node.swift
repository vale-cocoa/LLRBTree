//
//  LLRBTree+Node.swift
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
import BinaryNode

extension LLRBTree {
    final class Node: NSCopying, BinaryNode {
        var key: Key
        
        var value: Value
        
        var color: Color
        
        var count = 1
        
        var left: Node? = nil
        
        var right: Node? = nil
        
        init(key: Key, value: Value, color: Color = .red) {
            self.key = key
            self.value = value
            self.color = color
        }
        
        func copy(with zone: NSZone? = nil) -> Any {
            let kClone: Key = ((key as? NSCopying)?.copy(with: zone) as? Key) ?? key
            let vClone: Value = ((value as? NSCopying)?.copy(with: zone) as? Value) ?? value
            let clone = LLRBTree.Node(key: kClone, value: vClone, color: color)
            clone.count = count
            clone.left = left?.copy(with: zone) as? LLRBTree.Node
            clone.right = right?.copy(with: zone) as? LLRBTree.Node
            
            return clone
        }
    }
    
}

// MARK: - Color
extension LLRBTree.Node {
    enum Color: CaseIterable {
        case red
        case black
        
        mutating func flip() {
            switch self {
            case .red:
                self = .black
            case .black:
                self = .red
            }
        }
    }
    
}

// MARK: - Computed properties
extension LLRBTree.Node {
    @inlinable
    var min: LLRBTree.Node { left?.min ?? self }
    
    @inlinable
    var max: LLRBTree.Node { right?.max ?? self }
    
    @inlinable
    var minKey: Key { min.key }
    
    @inlinable
    var maxKey: Key { max.key }
    
    @inlinable
    var isRed: Bool { color == .red }
    
    @inlinable
    var hasRedLeftChild: Bool { left?.isRed ?? false }
    
    @inlinable
    var hasRedRightChild: Bool { right?.isRed ?? false }
    
    @inlinable
    var hasRedBothChildren: Bool { hasRedLeftChild && hasRedRightChild }
    
    @inlinable
    var hasRedLeftGrandChild: Bool { left?.left?.isRed ?? false }
    
}

// MARK: - FP implementations
extension LLRBTree.Node {
    func mapValues<T>(_ transform: (Value) throws -> T) rethrows -> LLRBTree<Key, T>.Node {
        let t = try transform(value)
        let result = LLRBTree<Key, T>.Node(key: key, value: t, color: isRed ? .red : .black)
        result.count = count
        result.left = try left?.mapValues(transform)
        result.right = try right?.mapValues(transform)
        
        return result
    }
    
}

// MARK: - Sequence conformance
extension LLRBTree.Node: Sequence {
    typealias Element = (Key, Value)
    
    var underestimatedCount: Int { return count }
}

// MARK: - Equatable conformance
extension LLRBTree.Node: Equatable where Value: Equatable {
    static func == (lhs: LLRBTree.Node, rhs: LLRBTree.Node) -> Bool {
        guard lhs !== rhs else { return true }
        
        guard
            lhs.color == rhs.color,
            lhs.count == rhs.count,
            lhs.key == rhs.key,
            lhs.value == rhs.value
        else { return false }
        
        switch (lhs.left, rhs.left) {
        case (nil, nil): break
        case (let lL, let rL) where lL == rL: break
        default: return false
        }
        
        switch (lhs.right, rhs.right) {
        case (nil, nil): break
        case (let lR, let rR) where lR == rR: break
        default: return false
        }
        
        return true
    }
    
}

// MARK: - Tree manipulations utilities
extension LLRBTree.Node {
    @inlinable
    func rotateLeft() {
        assert(right != nil, "Can't rotate left a node whose right child is nil!")
        let l = left
        let r = right!
        let newLeft = LLRBTree.Node(key: key, value: value, color: .red)
        
        key = r.key
        value = r.value
        
        newLeft.left = l
        newLeft.right = r.left
        newLeft.updateCount()
        
        left = newLeft
        right = r.right
    }
    
    @inlinable
    func rotateRight() {
        assert(left != nil, "Can't rotate right a node whose left child is nil")
        let l = left!
        let r = right
        let newRight = LLRBTree.Node(key: key, value: value, color: .red)
        
        key = l.key
        value = l.value
        
        newRight.left = l.right
        newRight.right = r
        newRight.updateCount()
        
        left = l.left
        right = newRight
    }
    
    @inlinable
    func moveRedLeft() {
        flipColors()
        if (right?.hasRedLeftChild ?? false) {
            right!.rotateRight()
            rotateLeft()
            flipColors()
        }
    }
    
    @inlinable
    func moveRedRight() {
        flipColors()
        if hasRedLeftGrandChild {
            rotateRight()
            flipColors()
        }
    }
    
    @inlinable
    func fixUp() {
        if hasRedRightChild {
            rotateLeft()
        }
        if (hasRedLeftChild && hasRedLeftGrandChild) {
            rotateRight()
        }
        if (hasRedLeftChild && hasRedRightChild) {
            flipColors()
        }
        
        updateCount()
    }
    
    @inlinable
    func flipColors() {
        color.flip()
        left?.color.flip()
        right?.color.flip()
    }
    
    @inlinable
    func updateCount() {
        count = 1 + (left?.count ?? 0) + (right?.count ?? 0)
    }
    
}

// MARK: - C.R.U.D.
// MARK: - get/set value for key
extension LLRBTree.Node {
    func value(forKey k: Key) -> Value? {
        binarySearch(k)?.value
    }
    
    func setValue(_ v: Value, forKey k: Key) {
        if k < key {
            if let l = left {
                l.setValue(v, forKey: k)
            } else {
                left = LLRBTree.Node(key: k, value: v)
            }
        } else if k > key {
            if let r = right {
                r.setValue(v, forKey: k)
            } else {
                right = LLRBTree.Node(key: k, value: v)
            }
        } else {
            value = v
        }
        
        fixUp()
    }
    
    func setValue(_ v: Value, forKey k: Key, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        if k < key {
            if let l = left {
                try l.setValue(v, forKey: k, uniquingKeysWith: combine)
            } else {
                left = LLRBTree.Node(key: k, value: v)
            }
        } else if k > key {
            if let r = right {
                try r.setValue(v, forKey: k, uniquingKeysWith: combine)
            }
        } else {
            try value = combine(value, v)
        }
        
        fixUp()
    }
    
}

// MARK: - remove value for key
extension LLRBTree.Node {
    func removingValue(forKey k: Key) -> LLRBTree.Node? {
        if k < key {
            if left != nil && !hasRedLeftChild && !hasRedLeftGrandChild {
                moveRedLeft()
            }
            left = left?.removingValue(forKey: k)
        } else {
            if hasRedLeftChild { rotateRight() }
            if k == key && right == nil { return nil }
            if (right != nil && !hasRedRightChild && !right!.hasRedLeftChild) {
                moveRedRight()
            }
            if k == key {
                let rightMin = right!.min
                key = rightMin.key
                value = rightMin.value
                right = right!.removingValueForMinKey()
            } else {
                right = right?.removingValue(forKey: k)
            }
        }
        
        fixUp()
        
        return self
    }
    
    func removingValueForMinKey() -> LLRBTree.Node? {
        guard left != nil else { return nil }
        
        if (!hasRedLeftChild && !hasRedLeftGrandChild) {
            moveRedLeft()
        }
        
        left = left!.removingValueForMinKey()
        
        fixUp()
        
        return self
    }
    
    func removingValueForMaxKey() -> LLRBTree.Node? {
        if hasRedLeftChild {
            rotateRight()
        }
        
        guard right != nil else { return nil }
        
        if !hasRedRightChild && !right!.hasRedLeftChild {
            moveRedRight()
        }
        
        right = right!.removingValueForMaxKey()
        
        fixUp()
        
        return self
    }
    
}
