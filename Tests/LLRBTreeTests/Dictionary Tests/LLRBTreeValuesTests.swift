//
//  LLRBTreeValuesTests.swift
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

final class LLRBTreeValuesTests: BaseLLRBTreeTestCase {
    // MARK: - values tests
    func testValues_getter() {
        // when is empty, then values is empty too
        sut = LLRBTree()
        XCTAssertTrue(sut.values.isEmpty)
        
        // when is not empty, then values is not empty and contains
        // all values in same order
        whenRootContainsHalfGivenElements()
        XCTAssertFalse(sut.values.isEmpty)
        XCTAssertTrue(sut.values.indices.elementsEqual(sut.indices, by: { sut.values[$0] == sut[$1].value }))
    }
    
    func testValues_getter_copyOnWrite() {
        // when storing values and then changing hash table values,
        // then stored values is different
        whenRootContainsHalfGivenElements()
        var storedValues = sut.values
        for k in sut.keys {
            sut[k]! += 10
        }
        XCTAssertNotEqual(storedValues, sut.values)
        
        // when storing values and then changing it, then tree
        // is not affected:
        storedValues = sut.values
        storedValues[storedValues.startIndex] += 10
        XCTAssertNotEqual(storedValues, sut.values)
    }
    
    func testValues_setter() {
        whenRootContainsHalfGivenElements()
        let clone = sut!
        let expectedResult = sut!.values.map { $0 + 10 }
        for offset in 0..<sut.values.count {
            let idx = sut.values.index(sut.values.startIndex, offsetBy: offset)
            sut.values[idx] += 10
        }
        
        XCTAssertTrue(sut.values.elementsEqual(expectedResult))
        XCTAssertFalse(sut.root === clone.root, "has not done copy on write")
        XCTAssertFalse(sut.id === clone.id, "has not changed id")
    }
    
}
