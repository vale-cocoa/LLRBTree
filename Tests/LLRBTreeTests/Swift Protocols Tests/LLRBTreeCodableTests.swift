//
//  LLRBTreeCodableTests.swift
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

final class LLRBTreeCodableTests: BaseLLRBTreeTestCase {
    func testEncodeThenDecode() {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        // when root is nil
        XCTAssertNil(sut.root)
        var data: Data!
        var decoded: LLRBTree<String, Int>!
        XCTAssertNoThrow(data = try encoder.encode(sut))
        XCTAssertNotNil(data)
        XCTAssertNoThrow(decoded = try decoder.decode(LLRBTree<String, Int>.self, from: data))
        XCTAssertNil(decoded.root)
        
        // when root is not nil
        whenRootContainsHalfGivenElements()
        XCTAssertNoThrow(data = try encoder.encode(sut))
        XCTAssertNotNil(data)
        XCTAssertNoThrow(decoded = try decoder.decode(LLRBTree<String, Int>.self, from: data))
        XCTAssertNotNil(decoded.root)
        XCTAssertEqual(sut, decoded)
        XCTAssertFalse(sut.root === decoded.root, "sut.root should a different instance than decoded.root")
    }
    
    func testDecode_whenKeysAndValuesAreDifferentCount_thenThrows() {
        let data = try! JSONSerialization.data(withJSONObject: malformedJSONDifferentCounts, options: .prettyPrinted)
        XCTAssertThrowsError(try sut =  JSONDecoder().decode(LLRBTree<String, Int>.self, from: data))
        do {
            sut = try JSONDecoder().decode(LLRBTree<String, Int>.self, from: data)
        } catch {
            XCTAssertEqual(error as NSError, LLRBTree<String, Int>.Error.valueForKeyCount as NSError)
            
            return
        }
        
        XCTFail("must throw when decoded keys and values have different count")
    }
    
    func testDecode_whenKeysContainsDuplicates_thenThrows() {
        let data = try! JSONSerialization.data(withJSONObject: malformedJSONDuplicateKeys, options: .prettyPrinted)
        XCTAssertThrowsError(try sut =  JSONDecoder().decode(LLRBTree<String, Int>.self, from: data))
        do {
            sut = try JSONDecoder().decode(LLRBTree<String, Int>.self, from: data)
        } catch {
            XCTAssertEqual(error as NSError, LLRBTree<String, Int>.Error.duplicateKeys as NSError)
            
            return
        }
        
        XCTFail("must throw when decoded keys contains duplicates")
    }
    
}
