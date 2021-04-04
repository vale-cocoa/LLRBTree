//
//  LLRBTreeKeysTests.swift
//  LLRBTreeTests
//
//  Created by Valeriano Della Longa on 2021/03/12.
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

final class LLRBTreeKeys: BaseLLRBTreeTestCase {
    func testKeys_whenIsEmpty_thenKeysIsEmptyToo() {
        sut = LLRBTree()
        XCTAssertTrue(sut.keys.isEmpty)
    }
    
    func testKeys_whenIsNotEmpty_thenKeysContainsTreeKeysInSameOrder() {
        whenRootContainsHalfGivenElements()
        XCTAssertFalse(sut.keys.isEmpty)
        XCTAssertTrue(sut.keys.indices.elementsEqual(sut.indices, by: { sut.keys[$0] == sut[$1].key }), "keys doesn't contains same keys in the same order")
    }
    
    func testKeys_invalidation() {
        // when storing keys before changing tree,
        // then previously stored keys is different.
        whenRootContainsHalfGivenElements()
        for key in sutNotIncludedKeys {
            let storedKeys = sut.keys
            sut[key] = givenRandomValue()
            
            XCTAssertNotEqual(storedKeys, sut.keys)
        }
    }
    
}
