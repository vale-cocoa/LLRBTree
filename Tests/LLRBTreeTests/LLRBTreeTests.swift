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
        XCTAssertNil(sut.root)
        whenRootContainsAllGivenElements()
        XCTAssertNotNil(sut.root)
    }
    
    // MARK: - ExpressibleByDictionaryLiteral conformance
    func testInitDictionaryLiteral() {
        sut = [:]
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
        
        let kForV = givenKeys
            .shuffled()
            .prefix(8)
            .map { (key: $0, value: givenRandomValue()) }
        
        sut = [
            kForV[0].key: kForV[0].value,
            kForV[1].key: kForV[1].value,
            kForV[2].key: kForV[2].value,
            kForV[3].key: kForV[3].value,
            kForV[4].key: kForV[4].value,
            kForV[5].key: kForV[5].value,
            kForV[6].key: kForV[6].value,
            kForV[7].key: kForV[7].value,
        ]
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.root)
        
        let expectedElements = kForV.sorted(by: { $0.key < $1.key })
        let rootElements = sut.root?.map { $0 }
        XCTAssertEqual(rootElements?.map({ $0.0 }), expectedElements.map { $0.key })
        XCTAssertEqual(rootElements?.map({ $0.1 }), expectedElements.map { $0.1 })
    }
    
    // MARK: - Other initializers tests
    func testInitUniqueKeysWithValues_whenSequenceIsAnotherLLRBTRee() {
        var other = LLRBTree<String, Int>()
        
        // other's root is nil
        sut = LLRBTree(other)
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
        
        // other'e root is not nil
        let elements = givenElements()
        let otherRoot = LLRBTree.Node(key: elements.first!.key, value: elements.first!.value, color: .black)
        other = LLRBTree(otherRoot)
        for element in elements.dropFirst() {
            other.root!.setValue(element.value, forKey: element.key)
            other.root!.color = .black
        }
        
        sut = LLRBTree(other)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.root, "root was not set")
        XCTAssertTrue(sut.root === other.root, "root is not same instance")
        XCTAssertEqual(sut.root, other.root)
    }
    
    func testInitUniqueKeysWithValues_whenSequenceIsNotAnotherLLRBTRee() {
        var keysAndValues = AnySequence<(key: String, value: Int)>(AnyIterator({ return nil }))
        // when keysAndValues is empty
        sut = LLRBTree(uniqueKeysWithValues: keysAndValues)
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
        
        // when keysAndValues is not empty
        keysAndValues = AnySequence(givenElements())
        sut = LLRBTree(uniqueKeysWithValues: keysAndValues)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.root)
        let expectedElements = keysAndValues
            .sorted(by: { $0.0 < $1.0 })
        assertEqualsByElements(lhs: sut, rhs: expectedElements, message: "elements are not equal")
    }
    
    func testInitUniquingKeysWith_whenCombineThrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in
            throw err
        }
        var keysAndValues: [(String, Int)] = []
        // keysAndValues is empty,
        // then doesn't throw initalizes an empty instance
        XCTAssertNoThrow(try sut = LLRBTree(keysAndValues, uniquingKeysWith: combine))
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
        
        // keysAndValues doesn't contain any duplicate key,
        // then doesn't throw and returns an instance with
        // all elements from keysAndValues
        keysAndValues = givenKeys.map { ($0, givenRandomValue()) }
        XCTAssertNoThrow(try sut = LLRBTree(keysAndValues, uniquingKeysWith: combine))
        XCTAssertNotNil(sut.root)
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
        assertEqualsByElements(lhs: sut, rhs: keysAndValues, message: "elements are not equal")
        
        // keysAndValues contains duplicate keys,
        // then rethrows
        keysAndValues.append(contentsOf: givenKeys.map { ($0, givenRandomValue()) })
        XCTAssertThrowsError(try sut = LLRBTree(keysAndValues, uniquingKeysWith: combine))
    }
    
    func testInitUniquingKeysWith_whenCombineDoesntThrows() {
        var executed: Bool = false
        let combine: (Int, Int) throws -> Int = { prev, next in
            executed = true
            return prev + next
        }
        
        var keysAndValues: [(String, Int)] = []
        // when keysAndValues is empty,
        // combine never gets executed and returns empty instance
        XCTAssertNoThrow(try sut = LLRBTree(keysAndValues, uniquingKeysWith: combine))
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
        
        // when keysAndValues doesn't contain duplicate keys,
        // then combine doesn't get executed and returns instance
        // containing all elements from keysAndValues
        keysAndValues = givenKeys.map { ($0, givenRandomValue()) }
        XCTAssertNoThrow(try sut = LLRBTree(keysAndValues, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertNotNil(sut.root)
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
        assertEqualsByElements(lhs: sut, rhs: keysAndValues)
        
        // when keysAndValues contains duplicate keys,
        // then combine gets executed, and returns a non-empty
        // instance which has for each duplicate key the value
        // calculated by applying combine
        let duplicateKey = keysAndValues.removeFirst().0
        var duplicates: [(String, Int)] = []
        for _ in 0..<3 {
            duplicates.append((duplicateKey, givenRandomValue()))
        }
        keysAndValues.append(contentsOf: duplicates)
        let initialValue = duplicates.removeFirst().1
        let expectedValueForDuplicateKey = try? duplicates
            .map { $0.1 }
            .reduce(initialValue, combine)
        executed = false
        XCTAssertNoThrow(try sut = LLRBTree(keysAndValues, uniquingKeysWith: combine))
        XCTAssertNotNil(sut.root)
        XCTAssertTrue(executed)
        XCTAssertEqual(sut.getValue(forKey: duplicateKey), expectedValueForDuplicateKey)
        for element in keysAndValues.dropLast(3) {
            XCTAssertEqual(sut.getValue(forKey: element.0), element.1)
        }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
    }
    
    func testInitGroupingBy_whenValuesIsEmpty_thenKeyForValueNeverExecutes() {
        typealias GrouppedTree = LLRBTree<String, Array<Int>>
        var hasExecuted = false
        let keyForValue: (Int) throws -> String = { _ in
            hasExecuted = true
            throw err
        }
        XCTAssertNoThrow(try GrouppedTree(grouping: [], by: keyForValue))
        XCTAssertFalse(hasExecuted)
    }
    
    func testInitGroupingBy_whenValuesIsNotEmpty_thenKeyForValueExecutes() {
        typealias GrouppedTree = LLRBTree<String, Array<Int>>
        var hasExecuted = false
        let keyForValue: (Int) throws -> String = { _ in
            hasExecuted = true
            throw err
        }
        XCTAssertThrowsError(try GrouppedTree(grouping: 0..<100, by: keyForValue))
        XCTAssertTrue(hasExecuted)
    }
    
    func testInitGroupingBy_whenKeyForValueThrows_thenRethrows() {
        typealias GrouppedTree = LLRBTree<String, Array<Int>>
        let keyForValue: (Int) throws -> String = { _ in throw err }
        do {
            let _ = try GrouppedTree(grouping: 0..<100, by: keyForValue)
        } catch {
            XCTAssertEqual(error as NSError, err)
            
            return
        }
        XCTFail("didn't rethrow")
    }
    
    func testInitGroupingBy_whenValuesIsNotEmptyAndKeyForValueDoesntThrow_thenInitializesAccordingly() {
        typealias GrouppedTree = LLRBTree<String, Array<Int>>
        let keyForValue: (Int) throws -> String = { v in
            switch v {
            case 0..<10: return "A"
            case 10..<100: return "B"
            case 100..<300: return "C"
            case 300...: return "D"
            default: throw err
            }
        }
        
        let values = 0..<300
        let expectedResult = try! Dictionary(grouping: values, by: keyForValue)
        // values implements withContiguousStorageIfAvailable
        var result: GrouppedTree!
        XCTAssertNoThrow(result = try GrouppedTree(grouping: Array(values), by: keyForValue))
        if let r = result {
            XCTAssertEqual(r.count, expectedResult.count)
            for (key, value) in expectedResult {
                XCTAssertEqual(r.root?.getValue(forKey: key), value)
            }
        } else {
            XCTFail("didn't initialize")
        }
        
        // values is a sequence which doesn't
        // implements withContiguousStorageIfAvailable
        // and returns 0 for underestimatedCount
        var seq = Seq(Array(values))
        seq.ucIsZero = true
        XCTAssertNoThrow(result = try GrouppedTree(grouping: seq, by: keyForValue))
        if let r = result {
            XCTAssertEqual(r.count, expectedResult.count)
            for (key, value) in expectedResult {
                XCTAssertEqual(r.root?.getValue(forKey: key), value)
            }
        } else {
            XCTFail("didn't initialize")
        }
        
        // values is a sequence which doesn't
        // implements withContiguousStorageIfAvailable
        // and returns a value for underestimatedCount a value which is equal to
        // half of its elements count
        seq.ucIsZero = false
        XCTAssertNoThrow(result = try GrouppedTree(grouping: seq, by: keyForValue))
        if let r = result {
            XCTAssertEqual(r.count, expectedResult.count)
            for (key, value) in expectedResult {
                XCTAssertEqual(r.root?.getValue(forKey: key), value)
            }
        } else {
            XCTFail("didn't initialize")
        }
    }
    
    // MARK: - subscript tests
    // Note:    these tests also test value(forKey:),
    //          setValue(_:forKey:) and removeValue(forKey:) methods
    //          since subscript relies on them.
    func testSubscriptGetter() {
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
    
    func testSubscriptSetter_whenNewValueIsNotNil() {
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
    
    func testSubscriptSetter_whenNewValueIsNil() {
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
    
    // MARK: - removeAll() test
    func testRemoveAll() {
        // when is empty, then changes id
        XCTAssertTrue(sut.isEmpty)
        weak var prevID = sut.id
        sut.removeAll()
        XCTAssertNil(sut.root)
        XCTAssertFalse(sut.id === prevID, "has not changed id")
        
        // when is not empty, then sets root to nil and changes id
        whenRootContainsHalfGivenElements()
        prevID = sut.id
        let clone = sut!
        sut.removeAll()
        XCTAssertNil(sut.root)
        XCTAssertFalse(sut.id === prevID, "has not changed id")
        XCTAssertNotNil(clone.root, "has set to nil also copy's root")
        XCTAssertTrue(clone.id === prevID, "has changed id on clone")
    }
    
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
    
    func testMergeUniquingKeysWith_whenCombineThrows() {
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
        givenKeys.forEach { other.updateValue(givenRandomValue(), forKey: $0) }
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
    
    func testMergeUniquingKeysWith_whenCombineDoesntThrow() {
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
    
    func testMergingUniquingKeysWith() {
        // Since this method wraps around
        // merge(_:,uniquingKeysWith:) we are just gonna tests
        // that when it doesn't throw returns a different
        // instance not touching the original one
        
        var executed: Bool = false
        let combine: (Int, Int) throws -> Int = { prev, next in
            executed = true
            return prev + next
        }
        // combine doesn't throws, and root is not nil other is
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
        prevSut.dropFirst(3).forEach { XCTAssertEqual(result.getValue(forKey: $0.0), $0.1) }
        prevNotIncludedKeys.forEach { XCTAssertEqual(result.getValue(forKey: $0), other.getValue(forKey: $0)) }
        expectedResultForDuplicateKeys.forEach { XCTAssertEqual(result.getValue(forKey: $0.0), $0.1) }
        if let root = result.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountAndPathToMinAndMaxAreCorrect(root: root)
        }
    }
    
    func testTreeFilter_whenIsEmpty_thenIsIncludedNeverExecutes() {
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
    
    func testTreeFilter_whenIsNotEmpty_thenIsIncludedExecutes() {
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
    
    func testTreeFilter_whenIsIncludedThrows_thenRethrows() {
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
    
    func testTreeFilter_whenIsIncludedDoesntThrow_thenReturnsFilteredTree() {
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

