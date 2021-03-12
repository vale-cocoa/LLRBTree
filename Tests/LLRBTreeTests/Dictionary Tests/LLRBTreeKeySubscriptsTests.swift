//
//  LLRBTreeKeySubscriptsTests.swift
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

final class LLRBTreeKeySubscriptsTests: BaseLLRBTreeTestCase {
    // MARK: - subscript(key:) tests
    func testSubscriptKeyGetter() {
        // when root is nil returns nil
        XCTAssertNil(sut.root)
        for key in givenKeys {
            XCTAssertNil(sut[key])
        }
        
        // when root is not nil, and
        // root.value(forKey:) returns nil,
        // then returns nil
        sut = LLRBTree(uniqueKeysWithValues: givenHalfElements())
        for key in sutNotIncludedKeys.shuffled() {
            XCTAssertNil(sut.root!.getValue(forKey: key))
            XCTAssertNil(sut[key])
        }
        
        // when root is not nil and root.value(forKey:) returns value, then
        // returns value
        let containedKeys = sut.root!.map { $0.0 }
        for key in containedKeys {
            let expectedValue = sut.root!.getValue(forKey: key)
            XCTAssertNotNil(expectedValue)
            XCTAssertEqual(sut[key], expectedValue)
        }
    }
    
    func testSubscriptKeySetter_whenNewValueIsNotNil() {
        // when key is not in root, then adds a new element:
        for key in givenKeys.shuffled() {
            let prevCount = sut.count
            let newValue = givenRandomValue()
            XCTAssertNil(sut.root?.getValue(forKey: key))
            sut[key] = newValue
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertNotNil(sut.root?.getValue(forKey: key))
            XCTAssertEqual(sut.root?.getValue(forKey: key), newValue)
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
        }
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, givenKeys.count)
        
        // when key is in root, then sets newValue for the root's node
        // with that key:
        for key in givenKeys.shuffled() {
            let oldValue = sut.root?.getValue(forKey: key)
            XCTAssertNotNil(oldValue)
            let newValue = oldValue! + 1
            let prevCount = sut.count
            sut[key] = newValue
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.root?.getValue(forKey: key), newValue)
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
        }
    }
    
    func testSubscriptKeySetter_whenNewValueIsNil() {
        // when root == nil, then nothing changes:
        XCTAssertNil(sut.root)
        for key in givenKeys {
            sut[key] = nil
            XCTAssertNil(sut.root)
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
        }
        
        // when root is not nil, and key is in root,
        // then root's node with key gets deleted:
        sut = LLRBTree(uniqueKeysWithValues: givenHalfElements())
        let containedKeys = Set(sut.root!.map { $0.0 })
        for key in containedKeys.shuffled() {
            let prevCount = sut.count
            sut[key] = nil
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertNil(sut.root?.getValue(forKey: key))
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
            if sut.root != nil {
                assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
                assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: sut.root!)
            }
        }
        XCTAssertNil(sut.root)
        
        // when root is not nil, and key is not in root,
        // then nothing changes:
        sut = LLRBTree(uniqueKeysWithValues: givenHalfElements())
        let expectedElements = sut.root!.map { $0 }
        
        for key in sutNotIncludedKeys.shuffled() {
            let prevCount = sut.count
            sut[key] = nil
            XCTAssertEqual(sut.count, prevCount)
            assertEqualsByElements(lhs: sut, rhs: expectedElements)
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
            if sut.root != nil {
                assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
                assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: sut.root!)
            }
        }
    }
    
    // MARK: - subscript(key:default:) tests
    func testSubscriptKeyDefault_getter() {
        XCTAssertTrue(sut.isEmpty)
        // when is empty then returns defaultValue
        for key in givenKeys {
            let defaultValue = givenRandomValue() * 100
            XCTAssertEqual(sut[key, default: defaultValue], defaultValue)
        }
        // when is not empty and key is not in tree,
        // then returns defaultValue
        whenRootContainsHalfGivenElements()
        for key in sutNotIncludedKeys {
            let defaultValue = givenRandomValue() * 100
            XCTAssertEqual(sut[key, default: defaultValue], defaultValue)
        }
        
        // when is not empty and key is in tree,
        // then returns value for key
        for key in sutIncludedKeys {
            let defaultValue = givenRandomValue() * 100
            let expectedValue = sut.getValue(forKey: key)
            XCTAssertEqual(sut[key, default: defaultValue], expectedValue)
        }
    }
    
    func testSubscriptKeyDefault_setter() {
        // when is empty, then adds newValue for key
        for key in givenKeys {
            sut = LLRBTree()
            let copy = sut!
            let defaultValue = givenRandomValue() * 100
            let newValue = givenRandomValue()
            sut[key, default: defaultValue] = newValue
            XCTAssertEqual(sut[key], newValue)
            XCTAssertFalse(sut.root === copy.root, "has not done copy on write")
            XCTAssertFalse(sut.id === copy.id, "has not changed id")
        }
        
        // when is not empty and doesn't contain key,
        // then adds new element with newValue for key
        whenRootContainsHalfGivenElements()
        for key in sutNotIncludedKeys {
            let defaultValue = givenRandomValue() * 100
            let newValue = givenRandomValue()
            let copy = sut!
            let prevCount = sut.count
            sut[key, default: defaultValue] = newValue
            XCTAssertEqual(sut[key], newValue)
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertFalse(sut.root === copy.root, "has not done copy on write")
            XCTAssertFalse(sut.id === copy.id, "has not changed id")
        }
        
        // when is not empty and contains key,
        // then updates element with key to newValue
        for key in sutIncludedKeys {
            let defaultValue = givenRandomValue() * 100
            let newValue = givenRandomValue()
            let copy = sut!
            let prevCount = sut.count
            sut[key, default: defaultValue] = newValue
            XCTAssertEqual(sut[key], newValue)
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertFalse(sut.root === copy.root, "has not done copy on write")
            XCTAssertFalse(sut.id === copy.id, "has not changed id")
        }
    }
    
    func testSubscriptKeyDefault_getterThenSetter() {
        // when is empty, then uses defaultValue
        for key in givenKeys {
            sut = LLRBTree()
            let defaultValue = givenRandomValue() * 100
            let expectedResult = defaultValue + 30
            sut[key, default: defaultValue] += 30
            XCTAssertEqual(sut[key], expectedResult)
        }
        
        // when is not empty, then uses defaultValue for keys not
        // contained and stored value for contained keys
        whenRootContainsHalfGivenElements()
        for key in givenKeys {
            let defaultValue = givenRandomValue() * 100
            let expectedResult: Int!
            if let oldValue = sut[key] {
                expectedResult = oldValue + 30
            } else {
                expectedResult = defaultValue + 30
            }
            sut[key, default: defaultValue] += 30
            XCTAssertEqual(sut[key], expectedResult)
        }
    }
    
}
