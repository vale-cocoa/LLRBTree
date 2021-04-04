//
//  LLRBTreeTests.swift
//  LLRBTreeTests
//
//  Created by Valeriano Della Longa on 2021/01/30.
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

final class LLRBTreeTests: BaseLLRBTreeTestCase {
    func testInit() {
        sut = LLRBTree()
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
    }
    
    func testRoot() {
        sut = LLRBTree()
        XCTAssertNil(sut.root)
        whenRootContainsAllGivenElements()
        XCTAssertNotNil(sut.root)
        let newRoot = LLRBTree.Node(key: givenKeys.randomElement()!, value: givenRandomValue(), color: .black)
        sut.root = newRoot
        XCTAssertTrue(sut.root === newRoot, "has not set root")
    }
    
    func testInitRoot() {
        sut = LLRBTree(nil)
        XCTAssertNil(sut.root)
        let newRoot = LLRBTree.Node(key: givenKeys.randomElement()!, value: givenRandomValue(), color: .black)
        sut = LLRBTree(newRoot)
        XCTAssertTrue(sut.root === newRoot)
    }
    
    func testInitOther() {
        var other = LLRBTree<String, Int>()
        
        sut = LLRBTree(other)
        XCTAssertNil(sut.root)
        
        let newRoot = LLRBTree.Node(key: givenKeys.randomElement()!, value: givenRandomValue(), color: .black)
        other = LLRBTree(newRoot)
        
        sut = LLRBTree(other)
        XCTAssertTrue(sut.root === newRoot, "has set different root")
    }
    
    func testMakeUnique_whenRootIsNil_thenNothingHappens() {
        sut = LLRBTree()
        sut.makeUnique()
        XCTAssertNil(sut.root)
    }
    
    func testMakeUnique_whenRootIsNotNilAndHasNotOtherStrongReferences_thenNothingHappens() {
        whenRootContainsHalfGivenElements()
        weak var prevRoot = sut.root
        
        sut.makeUnique()
        XCTAssertTrue(sut.root === prevRoot, "root changed to different reference")
    }
    
    func testMakeUnique_whenRootIsNotNilAndHasAnotherStrongReference_thenRootIsCloned() {
        whenRootContainsHalfGivenElements()
        let prevRoot = sut.root
        
        sut.makeUnique()
        XCTAssertFalse(sut.root === prevRoot, "root is still same reference")
        XCTAssertEqual(sut.root, prevRoot)
    }
    
}

