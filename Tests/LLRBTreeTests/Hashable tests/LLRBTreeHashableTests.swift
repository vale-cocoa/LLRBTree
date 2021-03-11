//
//  LLRBTreeHashableTests.swift
//  LLRBTreeTests
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

import XCTest
@testable import LLRBTree

final class LLRBTreeHashableTests: BaseLLRBTreeTestCase {
    // MARK: - Equatable conformance tests
    func testEquatable() {
        // when lhs and rhs have same root instance, then returns true
        var lhs = sut!
        var rhs = lhs
        XCTAssertTrue(lhs.root === rhs.root, "lhs.root is not the same instance of rhs.root")
        XCTAssertEqual(lhs, rhs)
        
        // when lhs and rhs are not same instance:
        // then returns true when both have root == nil
        rhs = LLRBTree()
        XCTAssertNil(lhs.root)
        XCTAssertNil(rhs.root)
        XCTAssertEqual(lhs, rhs)
        
        // when either root is nil and other's root is not nil,
        // then returns false
        lhs.updateValue(10, forKey: "A")
        XCTAssertNotNil(lhs.root)
        XCTAssertNil(rhs.root)
        XCTAssertNotEqual(lhs, rhs)
        
        lhs = LLRBTree()
        rhs.updateValue(10, forKey: "A")
        XCTAssertNotNil(rhs.root)
        XCTAssertNotEqual(lhs, rhs)
        
        // when both lhs and rhs have non nil root…
        for _ in 0..<100 {
            // …when roots are equal, then returns true
            whenRootContainsHalfGivenElements()
            lhs = sut
            rhs = LLRBTree(lhs.root?.clone())
            XCTAssertEqual(lhs, rhs)
            
            // …when roots are not equal, then returns false:
            rhs.removeValueForMinKey()
            XCTAssertNotEqual(lhs.root, rhs.root)
            XCTAssertNotEqual(lhs, rhs)
        }
    }
    
    // MARK: - Hashable tests
    func testHashableConformance() {
        var set: Set<LLRBTree<String, Int>> = []
        
        // when root is nil and other.root is nil too,
        // then are considered identical by Set
        XCTAssertNil(sut.root)
        set.insert(sut)
        XCTAssertFalse(set.insert(LLRBTree<String, Int>()).inserted)
        
        // when root is not nil and other has same root,
        // then are considered identical by Set
        set.removeAll()
        whenRootContainsHalfGivenElements()
        set.insert(sut)
        var other = sut!
        XCTAssertFalse(set.insert(other).inserted)
        // when root is not nil and other has different count
        // of elements, then are considered not identical by
        // Set
        other.removeValueForMinKey()
        XCTAssertTrue(set.insert(other).inserted)
        
        // when root is not nil, and other root is not nil
        // and have same elements, then
        // are considered identical by Set
        other = LLRBTree()
        sut.shuffled().forEach { other.updateValue($0.value, forKey: $0.key) }
        assertEqualsByElements(lhs: sut.root!, rhs: other.root!)
        XCTAssertFalse(set.insert(other).inserted)
    }
    
}
