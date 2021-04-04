//
//  LLRBTree+Node.swift
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
        
        func clone() -> LLRBTree<Key, Value>.Node {
            self.copy() as! LLRBTree<Key, Value>.Node
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

// MARK: - rank(_:), floor(_:), ceiling(_:), select(rank:)
extension LLRBTree.Node {
    func rank(_ k: Key) -> Int {
        if k < key {
            
            return left?.rank(k) ?? 0
        }
        let lCount = left?.count ?? 0
        if k == key {
            
            return lCount
        }
        let rRank = right?.rank(k) ?? 0
        
        return 1 + lCount + rRank
    }
    
    func floor(_ k: Key) -> LLRBTree.Node? {
        if k == key { return self }
        if k < key { return left?.floor(k) }
        
        return right?.floor(k) ?? self
    }
    
    func ceiling(_ k: Key) -> LLRBTree.Node? {
        if k == key { return self }
        if k > key { return right?.ceiling(k) }
        
        return left?.ceiling(k) ?? self
    }
    
    func select(rank: Int) -> LLRBTree.Node {
        assert(0..<count ~= rank, "rank is out of bounds")
        let leftCount = left?.count ?? 0
        
        if leftCount > rank {
            
            return left!.select(rank: rank)
        }
        
        if leftCount == rank { return self }
        
        return right!.select(rank: rank - leftCount - 1)
    }
    
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
    typealias Element = (key: Key, value: Value)
    
    struct Iterator: IteratorProtocol {
        private var position = 0
        
        private var node: WrappedNode<LLRBTree.Node>?
        
        init(_ node: LLRBTree.Node) {
            self.node = withExtendedLifetime(node) { WrappedNode(node: $0) }
        }
        
        mutating func next() -> Element? {
            guard node != nil else { return nil }
            
            defer {
                position += 1
                if position >= (node?.node.count ?? 0) { node = nil }
            }
            
            return node?.node.select(rank: position).element
        }
        
    }
    
    var underestimatedCount: Int { count }
    
    func makeIterator() -> Iterator { Iterator(self) }
    
}

// MARK: - Equatable conformance
extension LLRBTree.Node: Equatable where Value: Equatable {
    static func == (lhs: LLRBTree.Node, rhs: LLRBTree.Node) -> Bool {
        guard lhs !== rhs else { return true }
        
        let nodeBaseCmp: (LLRBTree.Node, LLRBTree.Node) -> Bool = {
            $0.color == $1.color &&
                $0.count == $1.count &&
                $0.key == $1.key &&
                $0.value == $1.value
        }
         
        guard
            nodeBaseCmp(lhs, rhs) == true
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
    func getValue(forKey k: Key) -> Value? {
        binarySearch(k)?.value
    }
    
    func setValue(_ v: Value, forKey k: Key) {
        setValue(v, forKey: k, uniquingKeysWith: { _, newValue in return newValue })
    }
    
    func setValue(_ v: Value, forKey k: Key, uniquingKeysWith combine: (Value, Value) throws -> Value) rethrows {
        if k < key {
            if left != nil {
                try left!.setValue(v, forKey: k, uniquingKeysWith: combine)
            } else {
                left = LLRBTree.Node(key: k, value: v)
            }
        } else if k > key {
            if right != nil {
                try right!.setValue(v, forKey: k, uniquingKeysWith: combine)
            } else {
                right = LLRBTree.Node(key: k, value: v)
            }
        } else {
            try value = combine(value, v)
        }
        
        fixUp()
    }
    
    @discardableResult
    func updateValue(_ v: Value, forKey k: Key) -> Value? {
        var result: Value? = nil
        if k < key {
            if left != nil {
                result = left!.updateValue(v, forKey: k)
            } else {
                left = LLRBTree.Node(key: k, value: v)
            }
        } else if k > key {
            if right != nil {
                result = right!.updateValue(v, forKey: k)
            } else {
                right = LLRBTree.Node(key: k, value: v)
            }
        } else {
            result = value
            value = v
        }
        fixUp()
        
        return result
    }
    
}

// MARK: - remove
extension LLRBTree.Node {
    func removingElement(withKey k: Key) -> (element: Element?, node: LLRBTree<Key, Value>.Node?) {
        var childResult: (element: Element?, node: LLRBTree<Key, Value>.Node?) = (nil, nil)
        if k < key {
            if left != nil && !hasRedLeftChild && !hasRedLeftGrandChild {
                moveRedLeft()
            }
            childResult = left?.removingElement(withKey: k) ?? childResult
            left = childResult.node
        } else {
            if hasRedLeftChild { rotateRight() }
            if k == key && right == nil { return (element, nil) }
            if (right != nil && !hasRedRightChild && !right!.hasRedLeftChild) {
                moveRedRight()
            }
            if k == key {
                let rightMinElement = right!.min.element
                right!.min.key = key
                right!.min.value = value
                key = rightMinElement.key
                value = rightMinElement.value
                childResult = right!.removingElementWithMinKey()
            } else {
                childResult = right?.removingElement(withKey: k) ?? childResult
            }
            right = childResult.node
        }
        
        fixUp()
        
        return (childResult.element, self)
    }
    
    func removingElementWithMinKey() -> (element: Element?, node: LLRBTree<Key, Value>.Node?) {
        guard
            left != nil
        else {
            
            return (element, nil)
        }
        
        if (!hasRedLeftChild && !hasRedLeftGrandChild) {
            moveRedLeft()
        }
        
        let childResult = left!.removingElementWithMinKey()
        left = childResult.node
        
        fixUp()
        
        return (childResult.element, self)
    }
    
    func removingElementWithMaxKey() -> (element: Element?, node: LLRBTree<Key, Value>.Node?) {
        if hasRedLeftChild {
            rotateRight()
        }
        
        guard right != nil else { return (element, nil) }
        
        if !hasRedRightChild && !right!.hasRedLeftChild {
            moveRedRight()
        }
        
        let childResult = right!.removingElementWithMaxKey()
        right = childResult.node
        
        fixUp()
        
        return (childResult.element, self)
    }
    
}

// MARK: - filtering
extension LLRBTree.Node {
    func filtered(_ isIncluded: (Element) throws -> Bool) rethrows -> LLRBTree.Node? {
        var result: LLRBTree.Node? = nil
        for candidate in self where try isIncluded(candidate) {
            guard
                let r = result
            else {
                result = LLRBTree.Node(key: candidate.key, value: candidate.value, color: .black)
                
                continue
            }
            
            r.updateValue(candidate.value, forKey: candidate.key)
            r.color = .black
        }
        
        return result
    }
    
}
