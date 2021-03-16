//
//  LLRBTreeOtherOpsTests.swift
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

final class LLRBTreeOtherOpsTests: BaseLLRBTreeTestCase {
    // MARK: - mapValues(_:) tests
    func testMapValues() {
        let transformValue: (Int) -> String = {
            $0 % 2 == 0 ? "EVEN" : "ODD"
        }
        
        // when root is nil, then never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.mapValues { _ in throw err })
        
        // when root is nil, then transform never executes
        var executed: Bool = false
        let _: LLRBTree<String, String> = sut.mapValues { _ in
            executed = true
            
            return ""
        }
        XCTAssertFalse(executed)
        
        // when root is nil, then returns
        // LLRBTree instance with nil root:
        XCTAssertNil(sut.mapValues(transformValue).root)
        
        // when root is not nil and transform throws,
        // then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.mapValues { _ in throw err })
        
        // when root is not nil and transform doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut
                            .mapValues { _ throws -> String in
                                
                                return ""
                            }
        )
        
        // when root is not nil, then returns a new instance
        // with all elements transformed on value according to
        // given transform
        let expectedResult = sut.map { ($0.0, transformValue($0.1)) }
        
        let result = sut.mapValues(transformValue)
        assertEqualsByElements(lhs: result, rhs: expectedResult)
    }
    
    // MARK: - compactMapValues(_:)
    func testCompactMapValues_whenRootIsNil() {
        let transformValue: (Int) -> String? = {
            $0 % 2 == 0 ? "Even" : nil
        }
        XCTAssertNil(sut.root)
        // when transform throws, then never throws
        XCTAssertNoThrow(try sut.compactMapValues { _ in throw err })
        
        // transform never executes
        var executed: Bool = false
        let _: LLRBTree<String, String> = sut.compactMapValues { _ in
            executed = true
            
            return ""
        }
        XCTAssertFalse(executed)
        
        // returns an LLRBTree instance with nil root
        XCTAssertNil(sut.compactMapValues(transformValue).root)
    }
    
    func testCompactMapValues_whenRootIsNotNil() {
        let throwingTransform: (Int) throws -> String? = { value in
            guard value < 1_000 else { throw err }
            guard value % 2 == 0 else { return nil }
            
            return "\(value)"
        }
        whenRootContainsAllGivenElements()
        sut.updateValue(1000, forKey: "Z")
        // when tranform throws, then rethows
        XCTAssertThrowsError(try sut.compactMapValues(throwingTransform))
        
        // when transform doesn't throw, then doesn't throw
        sut.updateValue(999, forKey: "Z")
        XCTAssertNoThrow(try sut.compactMapValues(throwingTransform))
        
        // returns a LLRBTree instance with elements for which
        // transform has not returned nil:
        let transformValue: (Int) -> String? = {
            $0 % 2 == 0 ? "Even" : nil
        }
        for _ in 0..<100 {
            whenRootContainsHalfGivenElements()
            let result = sut.compactMapValues(transformValue)
            let expectedElements: [(String, String)] = sut
                .compactMap {
                    guard
                        let t = transformValue($0.1)
                    else { return nil }
                    
                    return ($0.0, t)
                }
            assertEqualsByElements(lhs: result, rhs: expectedElements)
        }
    }
    
    // MARK: - Merge operations tests
    func testMergeSequenceUniquingKeysWith_whenIsEmptyAndOtherDoesntContainDuplicateKeys_thenCombineNeverGetsCalledAndElementsAreAddedFromOther() {
        var hasExecuted = false
        let combine: (Int, Int) throws -> Int = { _, _ in
            hasExecuted = true
            throw err
        }
        whenIsEmpty()
        // other implements withContiguousStorageIfAvailable
        
        // other is empty
        XCTAssertNoThrow(try sut.merge([], uniquingKeysWith: combine))
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(sut.isEmpty)
        
        // other is not empty
        whenIsEmpty()
        hasExecuted = false
        let otherArr = givenElements()
        XCTAssertNoThrow(try sut.merge(otherArr, uniquingKeysWith: combine))
        XCTAssertFalse(hasExecuted)
        if otherArr.count == sut.count {
            for (key, value) in otherArr {
                XCTAssertEqual(sut[key], value)
            }
        } else {
            XCTFail("elements are not the same amount from other: sut.count: \(sut.count) - other.count: \(otherArr.count)")
        }
        
        // other doesn't implement withContiguousStorageIfAvailable
        // other is empty
        whenIsEmpty()
        var other = Seq<(key: String, value: Int)>([])
        hasExecuted = false
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(hasExecuted)
        XCTAssertTrue(sut.isEmpty)
        
        // other is not empty
        whenIsEmpty()
        other = Seq(otherArr)
        hasExecuted = false
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(hasExecuted)
        if otherArr.count == sut.count {
            for (key, value) in otherArr {
                XCTAssertEqual(sut[key], value)
            }
        } else {
            XCTFail("elements are not the same amount from other: sut.count: \(sut.count) - other.count: \(otherArr.count)")
        }
    }
    
    func testMergeSequenceUniquingKeysWith_whenIsEmptyAndOtherContainsDuplicateKeys_thenCombineExecutes() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, last in
            hasExecuted = true
            
            return last
        }
        whenIsEmpty()
        // other implements withContiguousStorageIfAvailable
        let otherArr = givenElements() + givenElements()
        sut.merge(otherArr, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        
        // other implements withContiguousStorageIfAvailable
        whenIsEmpty()
        let other = Seq(otherArr)
        hasExecuted = false
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
    }
    
    func testMergeSequenceUniquingKeysWith_whenNoDuplicateKeys_thenCombineNeverGetsExecuted() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, last in
            hasExecuted = true
            
            return last
        }
        whenRootContainsHalfGivenElements()
        var otherArr = givenElements().filter { !sutIncludedKeys.contains($0.key) }
        sut.merge(otherArr, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
        
        // other doesn't implement withContiguousStorageIfAvailable
        whenRootContainsHalfGivenElements()
        otherArr = givenElements().filter { !sutIncludedKeys.contains($0.key) }
        let other = Seq(otherArr)
        hasExecuted = false
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertFalse(hasExecuted)
    }
    
    func testMergeSequenceUniquingKeysWith_whenDuplicateKeys_thenCombineExecutes() {
        var hasExecuted = false
        let combine: (Int, Int) -> Int = { _, last in
            hasExecuted = true
            
            return last
        }
        // other contains keys in sut
        whenRootContainsHalfGivenElements()
        var otherArr = givenElements()
        sut.merge(otherArr, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        
        // other doesn't implement withContiguousStorageIfAvailable
        whenRootContainsHalfGivenElements()
        var other = Seq(otherArr)
        hasExecuted = false
        sut.merge(other, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        
        // other doesn't contain keys in sut but has duplicate keys
        whenRootContainsHalfGivenElements()
        otherArr = givenElements().filter { !sutIncludedKeys.contains($0.key) }
        otherArr = (otherArr + otherArr)
        otherArr.shuffle()
        hasExecuted = false
        sut.merge(otherArr, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
        
        // other doesn't implement withContiguousStorageIfAvailable
        whenRootContainsHalfGivenElements()
        otherArr = givenElements().filter { !sutIncludedKeys.contains($0.key) }
        otherArr = (otherArr + otherArr)
        otherArr.shuffle()
        other = Seq(otherArr)
        hasExecuted = false
        sut.merge(otherArr, uniquingKeysWith: combine)
        XCTAssertTrue(hasExecuted)
    }
    
    func testMergeSequenceUniquingKeysWith_whenCombineThrows_thenRethrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in
            throw err
        }
        whenRootContainsHalfGivenElements()
        do {
            try sut.merge(givenElements(), uniquingKeysWith: combine)
            XCTFail("has not thrown error")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
        
        // other doesn't implement withContiguousStorageIfAvailable
        whenRootContainsHalfGivenElements()
        let other = Seq(givenElements())
        do {
            try sut.merge(other, uniquingKeysWith: combine)
            XCTFail("has not thrown error")
        } catch {
            XCTAssertEqual(error as NSError, err)
        }
    }
    
    func testMergeSequenceUniquingKeysWith_whenDuplicateKeysAndCombineDoesntThrow_thenMergesElementsAccordingly() {
        let combine: (Int, Int) -> Int = { $0 + $1 }
        
        // other contains keys in sut
        whenRootContainsHalfGivenElements()
        var otherArr = givenElements()
        var expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(otherArr, uniquingKeysWith: combine)
        sut.merge(otherArr, uniquingKeysWith: combine)
        if expectedResult.count == sut.count {
            for (key, value) in expectedResult {
                XCTAssertEqual(sut[key], value)
            }
        } else {
            XCTFail("elements are not the same amount from other: sut.count: \(sut.count) - other.count: \(otherArr.count)")
        }
        
        // other doesn't implement withContiguousStorageIfAvailable
        whenRootContainsHalfGivenElements()
        var other = Seq(otherArr)
        expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(Array(other), uniquingKeysWith: combine)
        sut.merge(other, uniquingKeysWith: combine)
        if expectedResult.count == sut.count {
            for (key, value) in expectedResult {
                XCTAssertEqual(sut[key], value)
            }
        } else {
            XCTFail("elements are not the same amount from other: sut.count: \(sut.count) - other.count: \(otherArr.count)")
        }
        
        // other doesn't contain keys in sut but has duplicate keys
        whenRootContainsHalfGivenElements()
        otherArr =
            givenElements().filter({ !sutIncludedKeys.contains($0.key) })
        otherArr = otherArr + otherArr
        otherArr.shuffle()
        expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(otherArr, uniquingKeysWith: combine)
        sut.merge(otherArr, uniquingKeysWith: combine)
        if expectedResult.count == sut.count {
            for (key, value) in expectedResult {
                XCTAssertEqual(sut[key], value)
            }
        } else {
            XCTFail("elements are not the same amount from other: sut.count: \(sut.count) - other.count: \(otherArr.count)")
        }
        
        // other doesn't implementWithContiguousStorageIfAvailable
        whenRootContainsHalfGivenElements()
        otherArr =
            givenElements().filter({ !sutIncludedKeys.contains($0.key) })
        otherArr = otherArr + otherArr
        otherArr.shuffle()
        other = Seq(otherArr)
        expectedResult = Dictionary(uniqueKeysWithValues: Array(sut))
        expectedResult.merge(Array(other), uniquingKeysWith: combine)
        sut.merge(other, uniquingKeysWith: combine)
        if expectedResult.count == sut.count {
            for (key, value) in expectedResult {
                XCTAssertEqual(sut[key], value)
            }
        } else {
            XCTFail("elements are not the same amount from other: sut.count: \(sut.count) - other.count: \(otherArr.count)")
        }
    }
    
    func testMergeSequenceUniquingKeysWith_copyOnWrite() {
        // when root is nil and merge adds elements,
        // then clone's root stills nil
        whenIsEmpty()
        let otherArr = givenElements()
        var clone = sut!
        sut.merge(otherArr, uniquingKeysWith: { _, next in
            return next
        })
        XCTAssertNil(clone.root)
        
        // when root is not nil and merge doesn't add new elements,
        // then sut.root doesn't change
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.merge([], uniquingKeysWith: { _, next in next})
        XCTAssertTrue(sut.root === clone.root, "sut.root should be the same instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // when root is not nil and merge adds new elements,
        // then sut.root is cloned
        whenRootContainsHalfGivenElements()
        clone = sut!
        prevCloneRoot = clone.root
        sut.merge(otherArr, uniquingKeysWith: {_, next in return next })
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // tests when other is a sequence not implementing
        // withContiguousStorageIfAvaliable
        whenIsEmpty()
        clone = sut!
        var other = Seq(otherArr)
        sut.merge(other, uniquingKeysWith: { _, next in
            return next
        })
        XCTAssertNil(clone.root)
        
        whenRootContainsHalfGivenElements()
        clone = sut!
        prevCloneRoot = clone.root
        other = Seq([])
        sut.merge(other, uniquingKeysWith: { _, next in
            return next
        })
        XCTAssertTrue(sut.root === clone.root, "sut.root should be the same instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        whenRootContainsHalfGivenElements()
        clone = sut!
        prevCloneRoot = clone.root
        other = Seq(otherArr)
        sut.merge(other, uniquingKeysWith: { _, next in
            return next
        })
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    func testMergeOtherUniquingKeysWith_whenCombineThrows() {
        var other = LLRBTree<String, Int>()
        let combine: (Int, Int) throws -> Int = { _, _ in
            throw err
        }
        
        // root is nil and other is empty,
        // then doesn't rethrows and no element gets inserted
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertNil(sut.root)
        
        // root is nil and other is not empty,
        // then doesn't rethrows and elements from other are
        // inserted
        givenElements()
            .forEach { other.updateValue($0.value, forKey: $0.key) }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertNotNil(sut.root)
        assertEqualsByElements(lhs: sut, rhs: other)
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
        
        // root is not nil and other is empty,
        // then doesn't rethrows and elements are same
        other = LLRBTree()
        let expectedElements = sut!.map { $0 }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        assertEqualsByElements(lhs: sut, rhs: expectedElements)
        
        // root is not nil, other is not empty and doesn't contain
        // any duplicate key, then doesn't rethrow and elements
        // from other get inserted
        whenRootContainsHalfGivenElements()
        for k in sutNotIncludedKeys.shuffled() {
            other.updateValue(givenRandomValue(), forKey: k)
        }
        let prevCount = sut.count
        let prevElements = sut!.map { $0 }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertEqual(sut.count, prevCount + other.count)
        for otherElement in other {
            XCTAssertEqual(sut.getValue(forKey: otherElement.0), otherElement.1)
        }
        for prevElement in prevElements {
            XCTAssertEqual(sut.getValue(forKey: prevElement.0), prevElement.1)
        }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
        
        // root is not nil and other contains duplicate keys,
        // then throws
        let otherRoot = sut.root?.copy() as? LLRBTree<String, Int>.Node
        other = LLRBTree(otherRoot)
        XCTAssertNotNil(other.root)
        XCTAssertThrowsError(try sut.merging(other, uniquingKeysWith: combine))
    }
    
    func testMergeOtherUniquingKeysWith_whenCombineDoesntThrow() {
        var executed: Bool = false
        let combine: (Int, Int) throws -> Int = { prev, next in
            executed = true
            return prev + next
        }
        var other = LLRBTree<String, Int>()
        
        // root is nil and other is empty,
        // then combine doesn't execute and sut.root == nil
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertNil(sut.root)
        
        // root is nil and other is not empty,
        // then combine doesn't execute and other's elements get
        // inserted
        executed = false
        givenKeys.forEach { other.updateValue(givenRandomValue(), forKey: $0) }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertNotNil(sut.root)
        assertEqualsByElements(lhs: sut, rhs: other)
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
        
        // root is not nil, other is not empty and doesn't contain
        // any duplicate key, then combine doesn't execute
        // and elements from other get inserted
        whenRootContainsHalfGivenElements()
        other = LLRBTree()
        for k in sutNotIncludedKeys.shuffled() {
            other.updateValue(givenRandomValue(), forKey: k)
        }
        var prevCount = sut.count
        var prevElements = sut!.map { $0 }
        executed = false
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertEqual(sut.count, prevCount + other.count)
        for otherElement in other {
            XCTAssertEqual(sut.getValue(forKey: otherElement.0), otherElement.1)
        }
        for prevElement in prevElements {
            XCTAssertEqual(sut.getValue(forKey: prevElement.0), prevElement.1)
        }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
        
        // root is not nil, other is not empty and contains
        // duplicate keys, then other elemnts get inserted and
        // for elements with duplicate keys combine executes and
        // its results are set for elements with duplicate keys
        whenRootContainsHalfGivenElements()
        other = LLRBTree()
        sutNotIncludedKeys.forEach {
            other.updateValue(givenRandomValue(), forKey: $0)
        }
        let elementsWithDuplicateKeys = sut
            .prefix(3)
            .map { ($0.key, givenRandomValue()) }
        elementsWithDuplicateKeys.forEach { other.updateValue($0.1, forKey: $0.0) }
        let expectedResultForDuplicateKeys = zip(sut.prefix(3), elementsWithDuplicateKeys)
            .map { ($0.0.0, try! combine($0.0.1, $0.1.1)) }
        executed = false
        prevCount = sut.count
        let prevNotIncludedKeys = sutNotIncludedKeys
        prevElements = sut.dropFirst(3).map { $0 }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertTrue(executed)
        XCTAssertEqual(sut.count, prevCount + prevNotIncludedKeys.count)
        prevElements.forEach { XCTAssertEqual(sut.getValue(forKey: $0.0), $0.1) }
        prevNotIncludedKeys.forEach { XCTAssertEqual(sut.getValue(forKey: $0), other.getValue(forKey: $0)) }
        expectedResultForDuplicateKeys.forEach { XCTAssertEqual(sut.getValue(forKey: $0.0), $0.1) }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
    }
    
    func testMergeOtherUniquingKeysWith_copyOnWrite() {
        // when root is nil and merge adds elements, then clone's root stills nil
        whenIsEmpty()
        var other = LLRBTree(uniqueKeysWithValues: givenElements())
        var clone = sut!
        sut.merge(other, uniquingKeysWith: {_, next in
            return next
        })
        XCTAssertNil(clone.root)
        
        // when root is not nil and merge doesn't
        // add new elements, then sut.root doesn't change
        whenRootContainsHalfGivenElements()
        other = LLRBTree<String, Int>()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.merge(other, uniquingKeysWith: {_, next in next})
        XCTAssertTrue(sut.root === clone.root, "sut.root should be the same instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // when root is not nil and merge adds new elements,
        // then sut.root gets copied
        whenRootContainsHalfGivenElements()
        other = LLRBTree(uniqueKeysWithValues: givenElements())
        clone = sut!
        prevCloneRoot = clone.root
        sut.merge(other, uniquingKeysWith: {_, next in return next })
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    func testMergingOtherUniquingKeysWith() {
        // Since this method wraps around
        // merge(_:,uniquingKeysWith:) we are just gonna test
        // that when it doesn't throw returns a different
        // instance not touching the original one
        
        var executed: Bool = false
        let combine: (Int, Int) throws -> Int = { prev, next in
            executed = true
            return prev + next
        }
        // combine doesn't throw and root is not nil and other is
        // not empty and contains duplicate keys,
        // then returns a copy with merged elements
        whenRootContainsHalfGivenElements()
        var other = LLRBTree<String, Int>()
        sutNotIncludedKeys.forEach {
            other.updateValue(givenRandomValue(), forKey: $0)
        }
        let elementsWithDuplicateKeys = sut
            .prefix(3)
            .map { ($0.0, givenRandomValue()) }
        elementsWithDuplicateKeys.forEach { other.updateValue($0.1, forKey: $0.0) }
        let expectedResultForDuplicateKeys = zip(sut.prefix(3), elementsWithDuplicateKeys)
            .map { ($0.0.0, try! combine($0.0.1, $0.1.1)) }
        executed = false
        var result: LLRBTree<String, Int>!
        let prevSut = sut!
        let prevNotIncludedKeys = sutNotIncludedKeys
        XCTAssertNoThrow(try result = sut.merging(other, uniquingKeysWith: combine))
        XCTAssertTrue(executed)
        XCTAssertFalse(sut.root === result.root, "result.root instance is sut.root")
        XCTAssertFalse(result.root === other.root, "result.root instance is other.root")
        XCTAssertEqual(sut, prevSut)
        XCTAssertEqual(result.count, prevSut.count + prevNotIncludedKeys.count)
        prevSut.dropFirst(3).forEach { XCTAssertEqual(result.getValue(forKey: $0.key), $0.value) }
        prevNotIncludedKeys.forEach { XCTAssertEqual(result.getValue(forKey: $0), other.getValue(forKey: $0)) }
        expectedResultForDuplicateKeys.forEach { XCTAssertEqual(result.getValue(forKey: $0.key), $0.value) }
        if let root = result.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
    }
    
    // MARK: - Filter tests
    func testFilter_whenIsEmpty_thenIsIncludedNeverExecutes() {
        var hasExecuted = false
        let isIncluded: ((key: String, value: Int)) throws -> Bool = { _ in
            hasExecuted = true
            throw err
        }
        XCTAssertTrue(sut.isEmpty)
        var result: LLRBTree<String, Int>? = nil
        
        XCTAssertNoThrow(result = try sut.filter(isIncluded))
        XCTAssertFalse(hasExecuted)
        XCTAssertEqual(result, LLRBTree<String, Int>())
    }
    
    func testFilter_whenIsNotEmpty_thenIsIncludedExecutes() {
        var hasExecuted = false
        let isIncluded: ((key: String, value: Int)) throws -> Bool = { _ in
            hasExecuted = true
            throw err
        }
        whenRootContainsHalfGivenElements()
        var result: LLRBTree<String, Int>? = nil
        
        XCTAssertThrowsError(result = try sut.filter(isIncluded))
        XCTAssertTrue(hasExecuted)
        XCTAssertNil(result)
    }
    
    func testFilter_whenIsIncludedThrows_thenRethrows() {
        let isIncluded: ((key: String, value: Int)) throws -> Bool = {
            _ in
            throw err
        }
        whenRootContainsHalfGivenElements()
        do {
            let _: LLRBTree<String, Int> = try sut.filter(isIncluded)
        } catch {
            XCTAssertEqual(error as NSError, err)
            return
        }
        
        XCTFail("has not rethrown error")
    }
    
    func testFilter_whenIsIncludedDoesntThrow_thenReturnsFilteredTree() {
        let isIncluded: ((key: String, value: Int)) throws -> Bool = {
            $0.value % 2 == 0
        }
        whenRootContainsHalfGivenElements()
        do {
            var expectedResult = LLRBTree<String, Int>()
            try sut.forEach { element in
                guard
                    try isIncluded(element)
                else { return }
                
                expectedResult.updateValue(element.value, forKey: element.key)
            }
            
            let result: LLRBTree<String, Int> = try sut.filter(isIncluded)
            XCTAssertEqual(result, expectedResult)
        } catch {
            XCTFail("isIncluded must not throw")
            
            return
        }
    }
    
}
