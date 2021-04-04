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

final class LLRBTreeCollectionTests: BaseLLRBTreeTestCase {
    typealias _Tree = LLRBTree<String, Int>
    
    typealias _Index = _Tree.Index
    
    typealias _Node = _Tree.Node
    
    typealias _WrappedNode = WrappedNode<_Node>
    
    override func setUp() {
        super.setUp()
        
        whenRootContainsAllGivenElements()
    }
    
    // MARK: - Tests
    // MARK: - count tests
    func testCount() {
        // when root == nil, then returns 0
        whenIsEmpty()
        XCTAssertNil(sut.root)
        XCTAssertEqual(sut.count, 0)
        
        // when root != nil, then returns root.count
        whenRootContainsAllGivenElements()
        XCTAssertEqual(sut.count, sut.root?.count)
    }
    
    // MARK: - isEmpty tests
    func testIsEmpty() {
        // when root == nil, then returns true
        whenIsEmpty()
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.isEmpty)
        
        // when root != nil, then returns false
        whenRootContainsAllGivenElements()
        XCTAssertFalse(sut.isEmpty)
    }
    
    // MARK: - startIndex tests
    func testStartIndex() {
        // Always returns 0
        sut = _Tree()
        XCTAssertEqual(sut.startIndex, 0)
        
        
        whenRootContainsHalfGivenElements()
        XCTAssertEqual(sut.startIndex, 0)
        
        whenRootContainsAllGivenElements()
        XCTAssertEqual(sut.startIndex, 0)
    }
    
    // MARK: endIndex tests
    func testEndIndex() {
        // always returns same value of count
        sut = _Tree()
        XCTAssertEqual(sut.endIndex, sut.count)
        
        whenRootContainsHalfGivenElements()
        XCTAssertEqual(sut.endIndex, sut.count)
        
        whenRootContainsAllGivenElements()
        XCTAssertEqual(sut.endIndex, sut.count)
    }
    
    // MARK: - first tests
    func testFirst() {
        // when isEmpty == true, then returns nil
        sut = _Tree()
        XCTAssertNil(sut.first)
        
        // when isEmpty == false, then returns min
        whenRootContainsHalfGivenElements()
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
        whenRootContainsHalfGivenElements()
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
        // always returns i + 1
        let i = Int.random(in: 0..<Int.max)
        XCTAssertEqual(sut.index(after: i), i + 1)
    }
    
    // MARK: - formIndex(after:) tests
    func testFormIndexAfter() {
        // always adds 1 to i
        var i = Int.random(in: 0..<Int.max)
        let expectedResult = i + 1
        sut.formIndex(after: &i)
        XCTAssertEqual(i, expectedResult)
    }
    
    // MARK: - index(before:) tests
    func testIndexBefore() {
        // always returns i - 1
        let i = Int.random(in: (Int.min + 1)..<Int.max)
        XCTAssertEqual(sut.index(before: i), i - 1)
    }
    
    // MARK: - formIndex(before:) tests
    func testFormIndexBefore() {
        // always subtracts 1 to i
        var i = Int.random(in: (Int.min + 1)..<Int.max)
        let expectedResult = i - 1
        sut.formIndex(before: &i)
        XCTAssertEqual(i, expectedResult)
    }
    
    // MARK: - subscript tests
    func testSubscript() {
        var iterator = sut.makeIterator()
        var i = sut.startIndex
        while i < sut.endIndex {
            let expectedElement = iterator.next()
            let result = sut[i]
            XCTAssertEqual(result.key, expectedElement?.key)
            XCTAssertEqual(result.value, expectedElement?.value)
            sut.formIndex(after: &i)
        }
    }
    
    // MARK: - remove(at:) tests
    func testRemoveAtIndex() {
        whenRootContainsAllGivenElements()
        for key in givenKeys.shuffled() {
            let copy = sut!
            let prevCount = sut.count
            let expectedValue = sut.getValue(forKey: key)
            let idx = sut.index(forKey: key)!
            let result = sut.remove(at: idx)
            XCTAssertEqual(result.key, key)
            XCTAssertEqual(result.value, expectedValue)
            XCTAssertNil(sut[key])
            XCTAssertEqual(sut.count, prevCount - 1)
            if sut.root != nil {
                assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
            }
            // value semantics test
            XCTAssertFalse(sut.root === copy.root, "has not done copy on write")
        }
    }
    
    // MARK: - index(forKey:) tests
    func testIndexForKey() {
        // when is empty, then always returns nil
        sut = LLRBTree()
        for _ in 0..<10 {
            XCTAssertNil(sut.index(forKey: givenKeys.randomElement()!))
        }
        
        // when is not empty and key is contained,
        // then returns correct index for key
        whenRootContainsAllGivenElements()
        for k in givenKeys.shuffled() {
            let idx = sut.index(forKey: k)
            XCTAssertNotNil(idx)
            if let idx = idx {
                let element = sut[idx]
                XCTAssertEqual(element.key, k)
                XCTAssertEqual(element.value, sut[k])
            }
        }
        // otherwise when key is not contained, then returns nil
        whenRootContainsHalfGivenElements()
        for key in sutNotIncludedKeys {
            XCTAssertNil(sut[key])
            XCTAssertNil(sut.index(forKey: key))
        }
    }
    
}
