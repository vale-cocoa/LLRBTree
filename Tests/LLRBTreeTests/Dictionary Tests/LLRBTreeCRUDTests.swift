//
//  LLRBTreeCRUDTests.swift
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

final class LLRBTreeCRUDTests: BaseLLRBTreeTestCase {
    // MARK: - getValue(forKey:) tests
    func testGetValueForKey_whenIsEmpty_thenReturnsNil() {
        XCTAssertTrue(sut.isEmpty)
        for k in givenKeys {
            XCTAssertNil(sut.getValue(forKey: k))
        }
    }
    
    func testGetValueForKey_whenIsNotEmptyAndKeyIsNotInTree_thenReturnsNil() {
        whenRootContainsHalfGivenElements()
        for k in sutNotIncludedKeys {
            XCTAssertNil(sut.getValue(forKey: k))
        }
    }
    
    func testGetValueForKey_whenIsNotEmptyAndKeyIsInTree_thenReturnsValueAssociatedToKey() {
        whenRootContainsHalfGivenElements()
        let allElements = sut.root.map({ $0 })
        for k in sutIncludedKeys {
            let expectedResult = allElements?.first(where: { $0.key == k })?.value
            let result = sut.getValue(forKey: k)
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    // MARK: - updateValue(_:forKey:) tests
    func testUpdateValueForKey_whenIsEmpty_thenAddsNewElementWithKeyAndValueAndReturnsNil() {
        for element in givenElements() {
            sut = LLRBTree()
            XCTAssertNil(sut.updateValue(element.value, forKey: element.key))
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(sut.getValue(forKey: element.key), element.value)
        }
    }
    
    func testUpdateValueForKey_whenIsNotEmptyAndKeyIsNotInTree_thenAddsNewElementWithKeyAndValueAndReturnsNil() {
        whenRootContainsHalfGivenElements()
        for k in sutNotIncludedKeys {
            let newValue = givenRandomValue()
            let prevCount = sut.count
            XCTAssertNil(sut.updateValue(newValue, forKey: k))
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.getValue(forKey: k), newValue)
        }
    }
    
    func testUpdateValueForKey_whenKeyIsInTree_thenUpdatesElementWithKeyToNewValueAndReturnsOldValue() {
        whenRootContainsHalfGivenElements()
        for k in sutIncludedKeys {
            let expectedValue = sut.getValue(forKey: k)
            let newValue = Int.random(in: 1_000..<10_000)
            let prevCount = sut.count
            let oldValue = sut.updateValue(newValue, forKey: k)
            XCTAssertEqual(oldValue, expectedValue)
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.getValue(forKey: k), newValue)
        }
    }
    
    func testUpdateValueForKey_copyOnWrite() {
        // when root is nil, then clone's root stills nil:
        XCTAssertNil(sut.root)
        var clone = sut!
        sut.updateValue(10, forKey: "A")
        XCTAssertNil(clone.root)
        
        // when root is not nil, then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.updateValue(1000, forKey: givenKeys.randomElement()!)
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    // MARK: - removeValue(forKey:) tests
    func testRemoveValueForKey_whenIsEmpty_thenReturnsNil() {
        XCTAssertTrue(sut.isEmpty)
        for k in givenKeys {
            XCTAssertNil(sut.removeValue(forKey: k))
            XCTAssertTrue(sut.isEmpty)
        }
    }
    
    func testRemoveValueForKey_whenIsNotEmptyAndKeyIsNotInTree_thenReturnsNilAndElementsDontChangeAndRootColorIsBlack() {
        whenRootContainsHalfGivenElements()
        let prevElements = sut.root!.map { $0 }
        for k in sutNotIncludedKeys {
            XCTAssertNil(sut.removeValue(forKey: k))
            XCTAssertEqual(sut.root?.color, .black)
            if sut.count == prevElements.count {
                for element in prevElements {
                    XCTAssertEqual(sut.getValue(forKey: element.key), element.value)
                }
            } else {
                XCTFail("has changed count")
            }
        }
    }
    
    func testRemoveValueForKey_whenKeyIsInTree_thenRemovesElementWithKeyAndReturnsItsValueAndRootColorIsBlackOrNilWhenLastElementIsRemoved() {
        whenRootContainsHalfGivenElements()
        for k in sutIncludedKeys {
            let prevCount = sut.count
            let elementValue = sut.getValue(forKey: k)
            let removedElement = sut.removeValue(forKey: k)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertNil(sut.getValue(forKey: k))
            XCTAssertEqual(removedElement, elementValue)
            if sut.root != nil {
                XCTAssertEqual(sut.root!.color, .black)
            }
        }
        XCTAssertNil(sut.root)
    }
    
    func testRemoveValueForKey_copyOnWrite() {
        // when root is nil, then clone's root stills nil
        XCTAssertNil(sut.root)
        var clone = sut!
        sut.removeValueForMinKey()
        XCTAssertNil(clone.root)
        
        // when root is not nil and forKey is not included,
        // then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.removeValue(forKey: sutNotIncludedKeys.randomElement()!)
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // when root is not nil and forKey is included
        // then sut.root gets copied
        clone = sut!
        prevCloneRoot = clone.root
        sut.removeValue(forKey: sutIncludedKeys.randomElement()!)
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    // MARK: - remove value for minKey and maxKey
    func testRemoveValueForMinKey() {
        // when root is nil, nothing happens and returns nil
        XCTAssertNil(sut.root)
        XCTAssertNil(sut.removeValueForMinKey())
        XCTAssertNil(sut.root)
        
        // when root contains elements,
        // then removes element with minKey ands returns its value:
        whenRootContainsAllGivenElements()
        while sut.count > 0 {
            let prevMinKey = sut.minKey
            let prevCount = sut.count
            let prevMinValue = sut.min?.value
            
            XCTAssertEqual(sut.removeValueForMinKey(), prevMinValue)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertNotEqual(sut.minKey, prevMinKey)
            if prevMinKey != nil {
                XCTAssertNil(sut[prevMinKey!])
            } else {
                XCTFail("sut.count was greater than 0 but minKey was nil")
            }
            XCTAssertTrue(sut.rootIsBlack)
        }
        XCTAssertNil(sut.root, "root is not nil after all its elements have been removed")
    }
    
    func testRemoveValueForMinKey_copyOnWrite() {
        // when root is nil, then clone's root stills nil
        XCTAssertNil(sut.root)
        var clone = sut!
        sut.removeValueForMinKey()
        XCTAssertNil(clone.root)
        
        // when root is not nil, then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.removeValueForMinKey()
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    func testRemoveValueForMaxKey() {
        // when root is nil, nothing happens and returns nil
        XCTAssertNil(sut.root)
        XCTAssertNil(sut.removeValueForMinKey())
        XCTAssertNil(sut.root)
        
        // when root contains elements,
        // then removes element with maxKey and returns its value
        whenRootContainsAllGivenElements()
        while sut.count > 0 {
            let prevMaxKey = sut.maxKey
            let prevCount = sut.count
            let prevMaxValue = sut.max?.value
            
            XCTAssertEqual(sut.removeValueForMaxKey(), prevMaxValue)
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertNotEqual(sut.maxKey, prevMaxKey)
            if prevMaxKey != nil {
                XCTAssertNil(sut[prevMaxKey!])
            } else {
                XCTFail("sut.count was greater than 0 but maxKey was nil")
            }
            XCTAssertTrue(sut.rootIsBlack)
        }
        XCTAssertNil(sut.root, "root is not nil after all its elements have been removed")
    }
    
    func testRemoveValueForMaxKey_copyOnWrite() {
        // when root is nil, then clone's root stills nil
        XCTAssertNil(sut.root)
        var clone = sut!
        sut.removeValueForMaxKey()
        XCTAssertNil(clone.root)
        
        // when root is not nil, then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.removeValueForMinKey()
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    // MARK: - removeAll() test
    func testRemoveAll() {
        // when is empty, then root stays nil
        XCTAssertTrue(sut.isEmpty)
        sut.removeAll()
        XCTAssertNil(sut.root)
        
        // when is not empty, then sets root to nil
        whenRootContainsHalfGivenElements()
        let clone = sut!
        sut.removeAll()
        XCTAssertNil(sut.root)
        XCTAssertNotNil(clone.root, "has set to nil also copy's root")
    }
    
}
