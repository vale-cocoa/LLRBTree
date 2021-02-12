//
//  TestsHelpers.swift
//  LLRBTReeTests
//
//  Created by Valeriano Della Longa on 2021/01/21.
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

import XCTest
@testable import LLRBTree
import BinaryNode

// MARK: - Helpers for testing LLRBTree and its Node class:
extension LLRBTree.Node {
    var is4Node: Bool { hasRedBothChildren || (hasRedLeftChild && hasRedLeftGrandChild) || (hasRedRightChild && (right?.right?.isRed ?? false))}
    
}

extension LLRBTree {
    var rootIsBlack: Bool { root == nil ? true : root!.isRed == false }
    
}

func _transformNodeValue<Key: Comparable, Value, T>(_ node: LLRBTree<Key, Value>.Node?, _ transformValue: (Value) throws -> T) -> LLRBTree<Key, T>.Node? {
    func __translateColor(_ color: LLRBTree<Key, Value>.Node.Color) -> LLRBTree<Key, T>.Node.Color {
        switch color {
        case .red: return .red
        case .black: return .black
        }
    }
    
    guard
        let n = node,
        let t = try? transformValue(n.value)
    else { return nil }
    
    let transformed = LLRBTree<Key, T>.Node(key: n.key, value: t, color: __translateColor(n.color))
    transformed.count = n.count
    
    transformed.left = _transformNodeValue(n.left, transformValue)
    transformed.left?.updatePaths()
    
    transformed.right = _transformNodeValue(n.right, transformValue)
    transformed.right?.updatePaths()
    
    transformed.updatePaths()
    
    return transformed
}

// MARK: - Assertions
func assertLeftLeaningRedBlackTreeInvariants<Key: Comparable, Value>(root: LLRBTree<Key, Value>.Node, message: String? = nil, file: StaticString = #file, line: UInt = #line) {
    XCTAssertTrue(root.isBinarySearchTree, "\(root) is not a binary search tree\n\(message ?? "")", file: file, line: line)
    
    let nodePaths = root.paths
    let colorBalanceNotRespected: Bool = nodePaths
        .reduce(false, { partialResult, path in
            partialResult == true ?
                true :
                path.contains(where: { wrappedNode in
                    wrappedNode.node.hasRedRightChild || wrappedNode.node.is4Node
                })
        })
    XCTAssertFalse(colorBalanceNotRespected, "\(root) either contains 4 node or has red node leaning right\n\(message ?? "")", file: file, line: line)
    
    let blackHeights = nodePaths
        .map { $0.reduce(0, { $1.node.isRed ? $0 : $0 + 1}) }
    let hasSameBlackHeight: Bool = blackHeights.max() == blackHeights.min()
    XCTAssertTrue(hasSameBlackHeight, "\(root) has not the same black height on every path\n\(message ?? "")", file: file, line: line)
}

func assertEachNodeCountAndPathToMinAndMaxAreCorrect<Key: Comparable, Value>(root: LLRBTree<Key, Value>.Node, message: String? = nil, file: StaticString = #file, line: UInt = #line) {
    typealias N = LLRBTree<Key, Value>.Node
    typealias WN = WrappedNode<N>
    
    func realPath(_ node: N, toMin: Bool = true) -> [WN] {
        var result = [WN]()
        var current = toMin ? node.left : node.right
        while current != nil {
            result.append(WrappedNode(node: current!))
            current = toMin ? current!.left : current!.right
        }
        
        
        return result
    }
    
    func fullRecount(_ node: N) -> Int {
        let lC = node.left == nil ? 0 : fullRecount(node.left!)
        let rC = node.right == nil ? 0 : fullRecount(node.right!)
        
        return 1 + lC + rC
    }
    
    root.inOrderTraverse { node in
        let realCount = fullRecount(node)
        XCTAssertEqual(node.count, realCount, "\(root) has not updated count on every node\n\(message ?? "")", file: file, line: line)
        
        let realPathToMin = realPath(node)
        XCTAssertTrue(realPathToMin.elementsEqual(node.pathToMin, by: { $0.node === $1.node }), "\(root) has not updated pathToMin on every node\n\(message ?? "")", file: file, line: line)
        
        let realPathToMax = realPath(node, toMin: false)
        XCTAssertTrue(realPathToMax.elementsEqual(node.pathToMax, by: { $0.node === $1.node }), "\(root) has not updated pathToMax on every node\n\(message ?? "")", file: file, line: line)
    }
}

func assertSamePathsToMinAndToMax<Key: Comparable, Value: Equatable>(lhs: LLRBTree<Key, Value>.Node, rhs: LLRBTree<Key, Value>.Node, message: String? = nil, file: StaticString = #file, line: UInt = #line) {
    typealias WN = WrappedNode<LLRBTree<Key, Value>.Node>
    let nodesEqualByElementCmp: (WN, WN) -> Bool = {
        $0.node.key == $1.node.key && $0.node.value == $1.node.value
    }
    guard
        lhs.pathToMin
            .elementsEqual(rhs.pathToMin, by: nodesEqualByElementCmp)
    else {
        XCTFail("\(message ?? "")", file: file, line: line)
        return
    }
    
    guard
        lhs.pathToMax
            .elementsEqual(rhs.pathToMax, by: nodesEqualByElementCmp)
    else {
        XCTFail("\(message ?? "")", file: file, line: line)
        return
    }
}

func assertEqualsByElements<Key: Comparable, Value: Equatable, LHS: Sequence, RHS: Sequence>(lhs: LHS, rhs: RHS, message: String? = nil, file: StaticString = #file, line: UInt = #line) where LHS.Iterator.Element == RHS.Iterator.Element, LHS.Iterator.Element == (Key, Value) {
    XCTAssertTrue(
        lhs.elementsEqual(rhs, by: { $0.0 == $1.0 && $0.1 == $1.1 }),
        "\(message ?? "")",
        file: file,
        line: line
    )
}

// MARK: - Dummies
final class MYKey: Comparable, NSCopying {
    var k: String
    
    init(_ k: String) {
        self.k = k
    }
    
    static func < (lhs: MYKey, rhs: MYKey) -> Bool {
        lhs.k < rhs.k
    }
    
    static func == (lhs: MYKey, rhs: MYKey) -> Bool {
        lhs.k == rhs.k
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        MYKey(self.k)
    }
    
}

final class MyValue: Equatable, NSCopying {
    var v: Int
    
    init(_ v: Int) {
        self.v = v
    }
    
    static func == (lhs: MyValue, rhs: MyValue) -> Bool {
        lhs.v == rhs.v
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        MyValue(self.v)
    }
    
}

struct MYSKey: Comparable {
    var k: String
    
    static func < (lhs: MYSKey, rhs: MYSKey) -> Bool {
        lhs.k < rhs.k
    }
    
    static func == (lhs: MYSKey, rhs: MYSKey) -> Bool {
        lhs.k == rhs.k
    }
}

struct MYSValue: Equatable {
    var v: Int
}

// MARK: - GIVEN
let givenKeys = "A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
    .components(separatedBy: " ")

func givenElements() -> [(key: String, value: Int)] {
    givenKeys
        .shuffled()
        .map { (key: $0, value: givenRandomValue()) }
}

func givenHalfElements() -> [(key: String, value: Int)] {
    givenKeys
        .shuffled()
        .prefix(givenKeys.count / 2)
        .map { (key: $0, value: givenRandomValue()) }
}

func givenRandomValue() -> Int {
    Int.random(in: 1...301)
}

// MARK: - Other utilties for tests
let err = NSError(domain: "com.vdl.error", code: 1, userInfo: nil)

let alwaysThrowingBody: ((String, Int)) throws -> Void = { _ in
    throw err
}

let neverThrowingBody: ((String, Int)) throws -> Void = { _ in }

let alwaysThrowingPredicate: ((String, Int)) throws -> Bool = { _ in
    throw err
}

let neverThrowingPredicate: ((String, Int)) throws -> Bool = { _ throws -> Bool in
    return true
}

// MARK: - helpers for testing decode throwing
let malformedJSONDifferentCounts: [String : Any] = {
    let lessValues = givenKeys
        .dropLast(5)
        .map { _ in givenRandomValue() }
    
    return [
    "keys" : givenKeys,
    "values" : lessValues
    ]
}()

let malformedJSONDuplicateKeys: [String : Any] = {
    let keysWithDuplicates = givenKeys + givenKeys
    let values = keysWithDuplicates
        .map { _ in givenRandomValue()}
    
    return [
    "keys" : keysWithDuplicates,
    "values" : values
    ]
}()
