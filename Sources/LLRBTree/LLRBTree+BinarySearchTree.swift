//
//  LLRBTree+BinarySearchTree.swift
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

// MARK: - rank(_:), floor(_:), ceiling(_:), selection(rank:) methods
extension LLRBTree {
    /// The element with the smallest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity: O(1).
    @inline(__always)
    public var min: Element? {
        root?.left?.pathToMin.last?.node.element ?? root?.left?.element ?? root?.element
    }
    
    /// The element with the greatest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity:   O(1).
    @inline(__always)
    public var max: Element? {
        root?.right?.pathToMax.last?.node.element ?? root?.right?.element ?? root?.element
    }
    
    /// The smallest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity:   O(1).
    @inline(__always)
    public var minKey: Key? { root?.minKey }
    
    /// The greatest key stored in this tree; `nil` when
    /// `isEmpty` is `true`.
    ///
    /// - Complexity:   O(1).
    @inline(__always)
    public var maxKey: Key? { root?.maxKey }
    
    /// Get the postion of the given key in this tree, assuming keys in the tree are in
    /// ascendending order in the range `0..<count` as position values.
    ///
    /// The rank of a key in the tree tells us how many keys in that tree have value less
    /// than that key.
    /// Following is a trival example:
    ///
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "B" : 4,
    ///         "D" : 6,
    ///         "E" : -1,
    ///         "F" : 13,
    ///     ]
    ///
    ///     print(tree.rank("A"))
    ///     // prints 0
    ///     // because there is no smaller key than "A" in tree
    ///
    ///     print(tree.rank("B"))
    ///     // prints 0
    ///     // because there is no smaller key than "B" in tree
    ///
    ///     print(tree.rank("C"))
    ///     // prints 1
    ///     // because there is 1 smaller key than "C" in tree
    ///
    ///     print(tree.rank("F"))
    ///     // prints 3
    ///     // because there are 3 smaller keys than "F" in tree
    ///
    ///     print(tree.rank("H"))
    ///     // prints 4
    ///     // because there are 4 smaller keys than "H" in tree
    /// ```
    /// - Parameter key: The key to look for its rank.
    /// - Returns:  An `Int` value representing the position of the given key
    ///             in this tree.
    /// - Complexity: O(log*n*) where *n* is the lenght of this tree.
    /// - Note: When the given key is not in the tree, than the returned rank value
    ///         is the insert postion in the range `0...count`.
    public func rank(_ key: Key) -> Int {
        guard let root = root else { return 0 }
        
        return root.rank(key)
    }
    
    /// Get the largest included key in this tree, which is smaller than or equal
    /// to the given key.
    ///
    /// Following is an example of `floor(_:)` usage:
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "B" : 4,
    ///         "D" : 6,
    ///         "E" : -1,
    ///         "F" : 13,
    ///     ]
    ///
    ///     print(tree.floor("A"))
    ///     // prints nil since there is not a key in the tree
    ///     // preceding or equal to given key "A".
    ///
    ///     print(tree.floor("B"))
    ///     // prints "B" since "B" is in the tree.
    ///
    ///     print(tree.floor("C"))
    ///     // prints "B" since that is the key in tree
    ///     // immediately preceding given key "C".
    ///
    ///     print(tree.floor("L"))
    ///     // prints "F" since that is the key in tree
    ///     // immediately preceding given key "L"
    /// ```
    /// - Parameter key: The key to look for its floor key in this tree.
    /// - Returns:  The greatest included key in this tree, which is smaller than
    ///             or equal to given the key or `nil` if such key doesn't
    ///             exist in this tree.
    /// - Complexity: O(log*n*) where *n* is the lenght of this tree.
    public func floor(_ key: Key) -> Key? {
        
        return root?.floor(key)?.key
    }
    
    /// Get the smallest included key in this tree, which is larger than or equal
    /// to the given key.
    ///
    /// Following is an example of `ceiling(_:)` usage:
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "B" : 4,
    ///         "D" : 6,
    ///         "E" : -1,
    ///         "F" : 13,
    ///     ]
    ///
    ///     print(tree.ceiling("A"))
    ///     // prints "B" since that is the key in tree
    ///     // immediately after given "A" key
    ///
    ///     print(tree.ceiling("B"))
    ///     // prints "B" since "B" is in the tree.
    ///
    ///     print(tree.ceiling("C"))
    ///     // prints "D" since that is the key in tree
    ///     // immediately after given key "C".
    ///
    ///     print(tree.ceiling("L"))
    ///     // prints nil since in tree there is no key
    ///     // equals to or immediately after given key "L".
    /// ```
    /// - Parameter key: The key to look for its ceil key in this tree.
    /// - Returns:  The smallest included key in this tree, which is greater
    ///             than or equal to the given key or `nil` if such key doesn't
    ///             exists in this tree.
    /// - Complexity: O(log*n*) where *n* is the lenght of this tree.
    public func ceiling(_ key: Key) -> Key? {
        
        return root?.ceiling(key)?.key
    }
    
    /// Get the element from this tree at the given position, assuming each element
    /// is in ascending order in the range of `0..<count` as positions.
    ///
    /// Following is a trivial example of `select(position:)` usage
    ///
    /// ```
    ///     let tree: LLRBTree<String, Int> = [
    ///         "A" : 10,
    ///         "B" : 20,
    ///         "C" : 15,
    ///         "D" : 7,
    ///         "E" : 1
    ///     ]
    ///
    ///     let firstElement = tree.select(0)
    ///     // firstElement is ("A", 10)
    ///
    ///     let lastElement = tree.select(4)
    ///     // lastElements is ("E", 1)
    ///
    ///     for (postion, element) in tree.enumerated() {
    ///         let selected = tree.select(position)
    ///         // selected.key == element.key
    ///         // selected.value == element.value
    ///     }
    /// ```
    /// - Parameter position:   An `Int` value representing the position
    ///                         in this tree of the element to retrieve.
    ///                         **Must be positive and less than this tree lenght**.
    /// - Returns: The element in this tree at the given position.
    /// - Complexity: O(log *n*) where *n* is the lenght of this tree.
    /// - Precondition: The tree must not be empty and the given
    ///                 `position` value must be in range `0..<count`.
    public func select(position: Int) -> Element {
        precondition(!isEmpty, "cannot use select(rank:) when isEmpty == true")
        precondition(0..<count ~= position, "rank is out of bounds")
        
        return root!.select(rank: position).element
    }
    
}

// MARK: - Tree traversal
extension LLRBTree {
    /// Traverse the tree in-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func inOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.inOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in reverse-in-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func reverseInOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.reverseInOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in pre-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func preOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.preOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in post-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func postOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.postOrderTraverse({ try body($0.element) })
    }
    
    /// Traverse the tree in level-order executing the given `body` closure
    /// on each element encountered during the traversal operation.
    ///
    /// - Parameter _:  A closure to execute on every element encountered
    ///                 while traversing the tree.
    /// - Complexity:   O(`n`) where `n` is the lenght of this tree.
    public func levelOrderTraverse(_ body: (Element) throws -> Void) rethrows {
        try root?.levelOrderTraverse({ try body($0.element) })
    }
    
}
