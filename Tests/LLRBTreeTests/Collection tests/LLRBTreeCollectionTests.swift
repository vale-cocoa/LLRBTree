//
//  LLRBTreeCollectionTests.swift
//  LLRBTreeTests
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

final class LLRBTreeCollectionTests: XCTestCase {
    typealias _Tree = LLRBTree<String, Int>
    
    typealias _Index = _Tree.Index
    
    typealias _Node = _Tree.Node
    
    typealias _WrappedNode = WrappedNode<_Node>
    
    var sut: LLRBTree<String, Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = givenFullTree()
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
            .forEach { tree.setValue(givenRandomValue(), forKey: $0) }
        
        return tree
    }
    
    // MARK: - Tests
    // MARK: - startIndex tests
    func testStartIndex() {
        // when isEmpty == true,
        // then returns Index with empty path,
        // nil root and same id of tree
        sut = _Tree()
        var idx = sut.startIndex
        XCTAssertNil(idx.root)
        XCTAssertTrue(idx.path.isEmpty)
        XCTAssertTrue(idx.id === sut.id)
        
        // when isEmpty == false,
        // then returns Index with root wrapping
        // tree root node, path not empty, path.last wrapping
        // tree's root.min node, and same id of tree
        sut = givenFullTree()
        idx = sut.startIndex
        XCTAssertTrue(idx.root?.node === sut.root)
        XCTAssertFalse(idx.path.isEmpty)
        XCTAssertTrue(idx.path.last?.node === sut.root?.min)
        XCTAssertTrue(idx.id === sut.id)
    }
    
    // MARK: endIndex tests
    func testEndIndex() {
        // when isEmpty == true,
        // then returns Index with empty path,
        // nil root and same id of tree
        sut = _Tree()
        var idx = sut.endIndex
        XCTAssertNil(idx.root)
        XCTAssertTrue(idx.path.isEmpty)
        XCTAssertTrue(idx.id === sut.id)
        
        // when isEmpty == false,
        // then returns Index with root wrapping
        // tree root node, path empty, and same id of tree
        sut = givenFullTree()
        idx = sut.endIndex
        XCTAssertTrue(idx.root?.node === sut.root)
        XCTAssertTrue(idx.path.isEmpty)
        XCTAssertTrue(idx.id === sut.id)
    }
    
    // MARK: - first tests
    func testFirst() {
        // when isEmpty == true, then returns nil
        sut = _Tree()
        XCTAssertNil(sut.first)
        
        // when isEmpty == false, then returns min
        sut = givenFullTree()
        while !sut.isEmpty {
            let min = sut.min
            XCTAssertNotNil(sut.first)
            XCTAssertEqual(sut.first?.0, min?.0)
            XCTAssertEqual(sut.first?.1, min?.1)
            sut.removeValueForMinKey()
        }
    }
    
    // MARK: - last tests
    func testLast() {
        // when isEmpty == true, then returns nil
        sut = _Tree()
        XCTAssertNil(sut.last)
        
        // when isEmpty == false, then returns max
        sut = givenFullTree()
        while !sut.isEmpty {
            let max = sut.max
            XCTAssertNotNil(sut.last)
            XCTAssertEqual(sut.last?.0, max?.0)
            XCTAssertEqual(sut.last?.1, max?.1)
            sut.removeValueForMaxKey()
        }
    }
    
    // MARK: - index(after:) tests
    func testIndexAfter() {
        // when i == endIndex, then returns endIndex
        var i = sut.endIndex
        var indexAfter = sut.index(after: i)
        XCTAssertEqual(indexAfter, sut.endIndex)
        
        // when i != endIndex, returns index pointing to next
        // element
        i = sut.startIndex
        indexAfter = i
        let iterator = sut.makeIterator()
        while let expectedElement = iterator.next() {
            XCTAssertEqual(indexAfter.path.last?.node.key, expectedElement.0)
            XCTAssertEqual(indexAfter.path.last?.node.value, expectedElement.1)
            i = indexAfter
            indexAfter = sut.index(after: i)
            XCTAssertGreaterThan(indexAfter, i)
        }
        XCTAssertEqual(indexAfter, sut.endIndex)
    }
    
    // MARK: - formIndex(after:) tests
    func testFormIndexAfter() {
        // when i == endIndex, then returns endIndex
        var i = sut.endIndex
        sut.formIndex(after: &i)
        XCTAssertEqual(i, sut.endIndex)
        
        // when i != endIndex, then returns index pointing to
        // next element
        i = sut.startIndex
        let iterator = sut.makeIterator()
        while let expectedElement = iterator.next() {
            XCTAssertEqual(i.path.last?.node.key, expectedElement.0)
            XCTAssertEqual(i.path.last?.node.value, expectedElement.1)
            let prev = i
            sut.formIndex(after: &i)
            XCTAssertGreaterThan(i, prev)
        }
        XCTAssertEqual(i, sut.endIndex)
    }
    
    // MARK: - index(before:) tests
    func testIndexBefore() {
        // when i == startIndex, then returns endIndex
        var i = sut.startIndex
        var indexBefore = sut.index(before: i)
        XCTAssertEqual(indexBefore, sut.endIndex)
        
        // when i == endIndex, then returns index pointing to
        // last element
        i = sut.endIndex
        indexBefore = sut.index(before: i)
        XCTAssertEqual(indexBefore.path.last?.node.key, sut.max?.0)
        XCTAssertEqual(indexBefore.path.last?.node.value, sut.max?.1)
        
        // when i != endIndex && i != startIndex,
        // then returns index pointing to element before
        let reversed = sut.reversed()
        var reversedIterator = reversed.makeIterator()
        while let prevElement = reversedIterator.next() {
            XCTAssertEqual(indexBefore.path.last?.node.key, prevElement.0)
            XCTAssertEqual(indexBefore.path.last?.node.value, prevElement.1)
            i = indexBefore
            indexBefore = sut.index(before: i)
        }
        XCTAssertEqual(indexBefore, sut.endIndex)
    }
    
    func testFormIndexBefore() {
        // when i == startIndex, then returns endIndex
        var i = sut.startIndex
        sut.formIndex(before: &i)
        XCTAssertEqual(i, sut.endIndex)
        
        // when i == endIndex, then returns index pointing to
        // last element
        i = sut.endIndex
        sut.formIndex(before: &i)
        XCTAssertEqual(i.path.last?.node.key, sut.max?.0)
        XCTAssertEqual(i.path.last?.node.value, sut.max?.1)
        
        // when i != endIndex && i != startIndex,
        // then returns index pointing to element before
        let reversed = sut.reversed()
        var reversedIterator = reversed.makeIterator()
        while let prevElement = reversedIterator.next() {
            XCTAssertEqual(i.path.last?.node.key, prevElement.0)
            XCTAssertEqual(i.path.last?.node.value, prevElement.1)
            sut.formIndex(before: &i)
        }
        XCTAssertEqual(i, sut.endIndex)
    }
    
    // MARK: subscript tests
    func testSubscript() {
        let iterator = sut.makeIterator()
        var i = sut.startIndex
        while i < sut.endIndex {
            let expectedElement = iterator.next()
            let result = sut[i]
            XCTAssertEqual(result.0, expectedElement?.0)
            XCTAssertEqual(result.1, expectedElement?.1)
            sut.formIndex(after: &i)
        }
    }
    
}
