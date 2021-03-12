//
//  LLRBTreeIndexTests.swift
//  LLRBTReeTests
//
//  Created by Valeriano Della Longa on 2021/02/12.
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

final class LLRBTReeIndexTests: XCTestCase {
    typealias _Tree = LLRBTree<String, Int>
    
    typealias _Index = _Tree.Index
    
    typealias _Node = _Tree.Node
    
    typealias _WrappedNode = WrappedNode<_Node>
    
    var sut: _Index!
    
    override func setUp() {
        super.setUp()
        
        sut = _Index(asStartIndexOf: LLRBTree())
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenFullTree() -> _Tree {
        var tree = _Tree()
        givenKeys
            .shuffled()
            .forEach { tree.updateValue(givenRandomValue(), forKey: $0) }
        
        return tree
    }
    
    // MARK: - Tests
    // MARK: - Initializers tests
    func testInitAsStartIndexOf() {
        // when tree is empty
        var tree = _Tree()
        sut = _Index(asStartIndexOf: tree)
        XCTAssertTrue(tree.id === sut.id, "id on startIndex was not set to the same of tree")
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.path.isEmpty, "path on startIndex for empty tree should be empty")
        
        // when tree is not empty
        tree = givenFullTree()
        sut = _Index(asStartIndexOf: tree)
        XCTAssertTrue(tree.id === sut.id, "id on startIndex was not set to the same of tree")
        XCTAssertTrue(sut.root?.node === tree.root, "startIndex root was wrapping a different node than tree's root")
        XCTAssertFalse(sut.path.isEmpty, "path on startIndex was empty for not empty tree")
        XCTAssertTrue(sut.path.first?.node === tree.root, "first wrapped node in startIndex path is not tree root")
        XCTAssertTrue(sut.path[1..<sut.path.endIndex].elementsEqual(tree.root!.pathToMin, by: { $0.node === $1.node }), "nodes in startIndexPath after first one are not equal to pathToMin ones in tree's root")
    }
    
    func testInitAsEndIndexOf() {
        // when tree is empty
        var tree = _Tree()
        sut = _Index(asEndIndexOf: tree)
        XCTAssertTrue(sut.id === tree.id, "id on endIndex was not set to the same of tree")
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.path.isEmpty, "path on endIndex should be empty")
        
        // when tree is not empty
        tree = givenFullTree()
        sut = _Index(asEndIndexOf: tree)
        XCTAssertTrue(sut.id === tree.id, "id on endIndex was not set to the same of tree")
        XCTAssertTrue(sut.root?.node === tree.root, "endIndex root was wrapping a different node than tree's root")
        XCTAssertTrue(sut.path.isEmpty, "path on endIndex should be empty")
    }
    
    func testInitAsIndexOfKeyFor() {
        // when tree is empty
        var tree = _Tree()
        sut = _Index(asIndexOfKey: givenKeys.randomElement()!, for: tree)
        XCTAssertTrue(sut.id === tree.id, "set a different id")
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.path.isEmpty)
        
        // when tree is not empty, and key is in tree
        tree = givenFullTree()
        for key in givenKeys {
            sut = _Index(asIndexOfKey: key, for: tree)
            XCTAssertTrue(sut.id === tree.id, "set a different id")
            XCTAssertTrue(sut.root?.node === tree.root, "set a different root")
            XCTAssertFalse(sut.path.isEmpty)
            XCTAssertEqual(sut.path.last?.node.element.key, key)
            XCTAssertEqual(sut.path.last?.node.element.value, tree[key])
        }
        
        // when tree is not empty and key is not in tree
        for _ in 0..<10 {
            let notContainedKey = givenKeys.randomElement()! + givenKeys.randomElement()!
            sut = _Index(asIndexOfKey: notContainedKey, for: tree)
            XCTAssertTrue(sut.id === tree.id, "set a different id")
            XCTAssertTrue(sut.root?.node === tree.root, "set a different root")
            XCTAssertTrue(sut.path.isEmpty)
        }
    }
    
    // MARK: - isValid(for:) tests
    func testIsValidFor() {
        // returns tree.id === id result
        var tree = _Tree()
        sut = _Index(asStartIndexOf: tree)
        XCTAssertTrue(sut.isValidFor(tree: tree))
        let treeClone = tree
        XCTAssertTrue(sut.isValidFor(tree: treeClone))
        tree = givenFullTree()
        XCTAssertFalse(sut.isValidFor(tree: tree))
        
        // when tree has mutated, then returns false
        sut = _Index(asStartIndexOf: tree)
        tree.removeValueForMinKey()
        XCTAssertFalse(sut.isValidFor(tree: tree))
    }
    
    // MARK: - formSuccessor() tests
    func testFormSuccessor() {
        // when root is nil, then nothing changes
        XCTAssertNil(sut.root)
        var previous = sut!
        
        sut.formSuccessor()
        XCTAssertTrue(sut.id === previous.id)
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.path.elementsEqual(previous.path, by: { $0.node === $1.node }))
        
        // when root is not nil
        let tree = givenFullTree()
        
        // path.isEmpty == true, then nothing changes
        sut = _Index(asEndIndexOf: tree)
        previous = sut!
        sut.formSuccessor()
        XCTAssertTrue(sut.id === previous.id)
        XCTAssertTrue(sut.path.elementsEqual(previous.path, by: { $0.node === $1.node }))
        
        // path.isEmpty == false, then path's last node is next element:
        sut = _Index(asStartIndexOf: tree)
        var treeIterator = tree.makeIterator()
        while let nextTreeElement = treeIterator.next() {
            XCTAssertEqual(sut.path.last?.node.key, nextTreeElement.0)
            XCTAssertEqual(sut.path.last?.node.value, nextTreeElement.1)
            sut.formSuccessor()
        }
        XCTAssertTrue(sut.path.isEmpty)
    }
    
    // MARK: - formPredecessor() tests
    func testFormPredecessor() {
        // when root is nil, then nothing changes
        XCTAssertNil(sut.root)
        var previous = sut!
        sut.formPredecessor()
        XCTAssertTrue(sut.id === previous.id)
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.path.elementsEqual(previous.path, by: { $0.node === $1.node }))
        
        // when root is not nil
        let tree = givenFullTree()
        
        // path.isEmpty == true, then forms index to max
        sut = _Index(asEndIndexOf: tree)
        previous = sut!
        sut.formPredecessor()
        XCTAssertTrue(sut.id === previous.id)
        XCTAssertTrue(sut.path.elementsEqual(([_WrappedNode(node: tree.root!)] + tree.root!.pathToMax), by: { $0.node === $1.node }))
        
        // path.isEmpty == false, then paths's last node is
        // previous element
        let reversed = tree.reversed()
        var reversedIterator = reversed.makeIterator()
        while let prevTreeElement = reversedIterator.next() {
            XCTAssertEqual(sut.path.last?.node.key, prevTreeElement.0)
            XCTAssertEqual(sut.path.last?.node.value, prevTreeElement.1)
            sut.formPredecessor()
        }
        XCTAssertTrue(sut.path.isEmpty)
    }
    
    // MARK: - Comparable conformance tests
    func testAreValid() {
        // returns result of lhs.id === rhs.id
        var tree = givenFullTree()
        var lhs = _Index(asStartIndexOf: tree)
        var rhs = _Index(asStartIndexOf: tree)
        while !rhs.path.isEmpty {
            XCTAssertTrue(lhs.id === rhs.id)
            XCTAssertTrue(_Index.areValid(lhs: lhs, rhs: rhs))
            rhs.formSuccessor()
        }
        tree.removeValueForMinKey()
        lhs = _Index(asStartIndexOf: tree)
        while !lhs.path.isEmpty {
            XCTAssertFalse(lhs.id === rhs.id)
            XCTAssertFalse(_Index.areValid(lhs: lhs, rhs: rhs))
            lhs.formSuccessor()
        }
    }
    
    func testEqualTo() {
        let tree = givenFullTree()
        // when path.count are different then returns false
        var lhs = _Index(asStartIndexOf: tree)
        var rhs = _Index(asEndIndexOf: tree)
        XCTAssertNotEqual(lhs, rhs)
        
        // when path.count are equal and path.last are
        // same wrapped node, then returns true
        rhs = _Index(asStartIndexOf: tree)
        while !lhs.path.isEmpty {
            XCTAssertEqual(lhs, rhs)
            lhs.formSuccessor()
            rhs.formSuccessor()
        }
        // when path.isEmpty == true for both, then returns true
        XCTAssertTrue(lhs.path.isEmpty)
        XCTAssertTrue(rhs.path.isEmpty)
        XCTAssertEqual(lhs, rhs)
        
        // when path.count are equal and path.last are
        // different nodes, then returns false
        lhs = _Index(asStartIndexOf: tree)
        rhs = lhs
        lhs.formSuccessor()
        rhs.formSuccessor()
        rhs.formSuccessor()
        while !rhs.path.isEmpty && rhs.path.count != lhs.path.count && lhs.path.last?.node !== rhs.path.last?.node {
            rhs.formSuccessor()
        }
        if !rhs.path.isEmpty && lhs.path.last?.node !== rhs.path.last?.node {
            XCTAssertNotEqual(lhs, rhs)
        }
    }
    
    func testLessThan() {
        let tree = givenFullTree()
        
        // when path.last == nil for both, returns false
        var lhs = _Index(asEndIndexOf: tree)
        var rhs = _Index(asEndIndexOf: tree)
        XCTAssertFalse(lhs < rhs)
        
        // when lhs.path.last == nil and rhs.path.last != nil,
        // then returns false
        rhs.formPredecessor()
        XCTAssertFalse(lhs < rhs)
        
        // when lhs.path.last != nil and rhs.path.last == nil,
        // then returns true
        lhs.formPredecessor()
        rhs = _Index(asEndIndexOf: tree)
        XCTAssertTrue(lhs < rhs)
        
        // when both path.last != nil and…
        
        // …lhs.path.last.node.key < rhs.path.last.node.key,
        // then returns true
        lhs = _Index(asEndIndexOf: tree)
        lhs.formPredecessor()
        lhs.formPredecessor()
        rhs = _Index(asEndIndexOf: tree)
        rhs.formPredecessor()
        while !lhs.path.isEmpty {
            XCTAssertTrue(lhs < rhs)
            lhs.formPredecessor()
            rhs.formPredecessor()
        }
        
        // …lhs.path.last.node.key == rhs.path.last.node.key,
        // then returns false
        lhs = _Index(asEndIndexOf: tree)
        lhs.formPredecessor()
        rhs = _Index(asEndIndexOf: tree)
        rhs.formPredecessor()
        while !lhs.path.isEmpty {
            XCTAssertFalse(lhs < rhs)
            lhs.formPredecessor()
            rhs.formPredecessor()
        }
        
        // …lhs.path.last.node.key > rhs.path.last.node.key,
        // then returns false
        lhs = _Index(asEndIndexOf: tree)
        lhs.formPredecessor()
        rhs = _Index(asEndIndexOf: tree)
        rhs.formPredecessor()
        rhs.formPredecessor()
        while !rhs.path.isEmpty {
            XCTAssertFalse(lhs < rhs)
            lhs.formPredecessor()
            rhs.formPredecessor()
        }
    }
    
}

