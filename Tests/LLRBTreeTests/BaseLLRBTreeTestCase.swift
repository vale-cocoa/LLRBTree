//
//  BaseLLRBTreeTestCase.swift
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

class BaseLLRBTreeTestCase: XCTestCase {
    var sut: LLRBTree<String, Int>!
    
    var sutIncludedKeys: Set<String> {
        Set(sut.root?.map { $0.0 } ?? [])
    }
    
    var sutNotIncludedKeys: Set<String> {
        Set(givenKeys.filter { !sutIncludedKeys.contains($0) } )
    }
    
    override func setUp() {
        super.setUp()
        
        sut = LLRBTree()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - WHEN
    func whenIsEmpty() {
        sut = LLRBTree()
    }
    
    func whenRootContainsAllGivenElements() {
        sut = LLRBTree(uniqueKeysWithValues: givenElements())
    }
    
    func whenRootContainsHalfGivenElements() {
        sut = LLRBTree(uniqueKeysWithValues: givenHalfElements())
    }
    
}
