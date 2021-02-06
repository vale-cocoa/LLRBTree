//
//  LLRBTreeTests.swift
//  LLRBTreeTests
//
//  Created by Valeriano Della Longa on 2021/01/30.
//  Copyright © 2020 Valeriano Della Longa
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

final class LLRBTreeTests: XCTestCase {
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
    private func whenRootContainsAllGivenElements() {
        sut = LLRBTree(uniqueKeysWithValues: givenElements())
    }
    
    private func whenRootContainsHalfGivenElements() {
        sut = LLRBTree(uniqueKeysWithValues: givenHalfElements())
    }
    
    // MARK: - Tests
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
        other.root = LLRBTree.Node(key: elements.first!.key, value: elements.first!.value, color: .black)
        for element in elements.dropFirst() {
            other.root!.setValue(element.value, forKey: element.key)
            other.root!.color = .black
        }
        
        sut = LLRBTree(other)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.root, "root was not set")
        XCTAssertFalse(sut.root === other.root, "root was not copied but just referenced")
        XCTAssertEqual(sut.root, other.root)
    }
    
    func testInitUniqueKeysWithValues_whenSequenceIsNotAnotherLLRBTRee() {
        var keysAndValues = AnySequence<(String, Int)>(AnyIterator({ return nil }))
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
        XCTAssertEqual(sut.root?.map { $0.0 }, expectedElements.map { $0.0 })
        XCTAssertEqual(sut.root?.map { $0.1 }, expectedElements.map { $0.1 })
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
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root is not supposed to be nil")
        }
        for element in keysAndValues {
            XCTAssertEqual(sut.value(forKey: element.0), element.1)
        }
        
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
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root is not supposed to be nil")
        }
        for element in keysAndValues {
            XCTAssertEqual(sut.value(forKey: element.0), element.1)
        }
        
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
        XCTAssertEqual(sut.value(forKey: duplicateKey), expectedValueForDuplicateKey)
        for element in keysAndValues.dropLast(3) {
            XCTAssertEqual(sut.value(forKey: element.0), element.1)
        }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root is not supposed to be nil")
        }
    }
    
    // MARK: - Computed properties tests
    func testCount() {
        // when root == nil, then returns 0
        XCTAssertNil(sut.root)
        XCTAssertEqual(sut.count, 0)
        
        // when root != nil, then returns root.count
        whenRootContainsAllGivenElements()
        XCTAssertEqual(sut.count, sut.root?.count)
    }
    
    func testIsEmpty() {
        // when root == nil, then returns true
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.isEmpty)
        
        // when root != nil, then returns false
        whenRootContainsAllGivenElements()
        XCTAssertFalse(sut.isEmpty)
    }
    
    func testMin() {
        // when root is nil, then returns nil
        XCTAssertNil(sut.root)
        XCTAssertNil(sut.min)
        
        // when root is not nil,
        // then returns (root.min.key, root.min.value)
        whenRootContainsAllGivenElements()
        XCTAssertNotNil(sut.root)
        XCTAssertNotNil(sut.min)
        XCTAssertEqual(sut.min?.0, sut.root?.min.key)
        XCTAssertEqual(sut.min?.1, sut.root?.min.value)
    }
    
    func testMax() {
        // when root is nil, then returns nil
        XCTAssertNil(sut.root)
        XCTAssertNil(sut.max)
        
        // when root is not nil,
        // then returns (root.max.key, root.max.value)
        whenRootContainsAllGivenElements()
        XCTAssertNotNil(sut.root)
        XCTAssertNotNil(sut.max)
        XCTAssertEqual(sut.max?.0, sut.root?.max.key)
        XCTAssertEqual(sut.max?.1, sut.root?.max.value)
    }
    
    func testMinKey() {
        // when min is nil, then returns nil
        XCTAssertNil(sut.min)
        XCTAssertNil(sut.minKey)
        
        // when min is not nil, thenm returns min.0
        whenRootContainsAllGivenElements()
        XCTAssertNotNil(sut.min)
        XCTAssertNotNil(sut.minKey)
        XCTAssertEqual(sut.min?.0, sut.minKey)
    }
    
    func testMaxKey() {
        // when max is nil, then returns nil
        XCTAssertNil(sut.max)
        XCTAssertNil(sut.maxKey)
        
        // when max is not nil, thenm returns max.0
        whenRootContainsAllGivenElements()
        XCTAssertNotNil(sut.max)
        XCTAssertNotNil(sut.maxKey)
        XCTAssertEqual(sut.max?.0, sut.maxKey)
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
            XCTAssertNil(sut.root!.value(forKey: key))
            XCTAssertNil(sut[key])
        }
        
        // when root is not nil and root.value(forKey:) returns value, then
        // returns value
        let containedKeys = sut.root!.map { $0.0 }
        for key in containedKeys {
            let expectedValue = sut.root!.value(forKey: key)
            XCTAssertNotNil(expectedValue)
            XCTAssertEqual(sut[key], expectedValue)
        }
    }
    
    func testSubscriptSetter_whenNewValueIsNotNil() {
        // when key is not in root, then adds a new element:
        for key in givenKeys.shuffled() {
            let prevCount = sut.count
            let newValue = givenRandomValue()
            XCTAssertNil(sut.root?.value(forKey: key))
            sut[key] = newValue
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertNotNil(sut.root?.value(forKey: key))
            XCTAssertEqual(sut.root?.value(forKey: key), newValue)
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
        }
        XCTAssertFalse(sut.isEmpty)
        XCTAssertEqual(sut.count, givenKeys.count)
        
        // when key is in root, then sets newValue for the root's node
        // with that key:
        for key in givenKeys.shuffled() {
            let oldValue = sut.root?.value(forKey: key)
            XCTAssertNotNil(oldValue)
            let newValue = oldValue! + 1
            let prevCount = sut.count
            sut[key] = newValue
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.root?.value(forKey: key), newValue)
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
            XCTAssertNil(sut.root?.value(forKey: key))
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
            if sut.root != nil {
                assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
                assertEachNodeCountIsCorrect(root: sut.root!)
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
            XCTAssertEqual(sut.root?.map { $0.0 }, expectedElements.map { $0.0 })
            XCTAssertEqual(sut.root?.map { $0.1 }, expectedElements.map { $0.1 })
            XCTAssertTrue(sut.rootIsBlack, "root should be a black node")
            if sut.root != nil {
                assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
                assertEachNodeCountIsCorrect(root: sut.root!)
            } else {
                XCTFail("root should not be nil")
            }
        }
    }
    
    // MARK: - remove value for minKey and maxKey
    func testRemoveValueForMinKey() {
        // when root is nil, nothing happens
        XCTAssertNil(sut.root)
        sut.removeValueForMinKey()
        XCTAssertNil(sut.root)
        
        // when root contains elements,
        // then removes element with minKey:
        whenRootContainsAllGivenElements()
        while sut.count > 0 {
            let prevMinKey = sut.minKey
            let prevCount = sut.count
            
            sut.removeValueForMinKey()
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
        // when root is nil, nothing happens
        XCTAssertNil(sut.root)
        sut.removeValueForMinKey()
        XCTAssertNil(sut.root)
        
        // when root contains elements,
        // then removes element with maxKey
        whenRootContainsAllGivenElements()
        while sut.count > 0 {
            let prevMaxKey = sut.maxKey
            let prevCount = sut.count
            
            sut.removeValueForMaxKey()
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
    
    // MARK: - rank(_:), floor(_:), ceiling(_:), selection(rank:) methods tests
    // MARK: - rank(_:) tests
    func testRank() {
        // when root is nil, then returns 0 for any key
        XCTAssertNil(sut.root)
        for key in givenKeys {
            XCTAssertEqual(sut.rank(key), 0)
        }
        
        // when root is not nil, and key is included,
        // then returns value equals to i-th enumarated key where
        // key == key
        for key in sutIncludedKeys.shuffled() {
            let result = sut.rank(key)
            for (expectedResult, element) in sut.enumerated() where element.0 == key {
                XCTAssertEqual(result, expectedResult)
            }
        }
        
        // when root is not nil, and key is not included,
        // then returns insert position:
        whenRootContainsHalfGivenElements()
        let sutKeys = sut.map { $0.0 }
        for key in sutNotIncludedKeys.shuffled() {
            let expectedResult = sutKeys.firstIndex(where: {
                $0 == key || ($0 > key)
            }) ?? sut.count
            let result = sut.rank(key)
            XCTAssertEqual(result, expectedResult)
            if key > sut.maxKey! {
                XCTAssertEqual(result, sut.count)
            }
        }
    }
    
    // MARK: - floor(_:) tests
    func testFloor() {
        // when root is nil, then returns nil
        XCTAssertNil(sut.root)
        for k in givenKeys {
            XCTAssertNil(sut.floor(k))
        }
        
        // when root is not nil…
        whenRootContainsHalfGivenElements()
        
        // …and k is larger than or equal minKey,
        // then returns largest included key smaller than k
        let keysLargerThanOrEqualToSutMinKey = givenKeys
            .filter { $0 >= sut.minKey! }
        for k in keysLargerThanOrEqualToSutMinKey {
            let result = sut.floor(k)
            XCTAssertNotNil(result)
            let expectedResult = sut!
                .map { $0.0 }
                .last(where: { $0 <= k} )
            XCTAssertEqual(result, expectedResult, "k was: \(k)")
        }
        
        // …and k is smaller than minKey, then returns nil
        let keysSmallerThanSutMinKey = givenKeys
            .filter { $0 < sut.minKey! }
        for k in keysSmallerThanSutMinKey {
            XCTAssertNil(sut.floor(k))
        }
    }
    
    // MARK: - ceiling(_:) tests
    func testCeiling() {
        // mark when root is nil, then returns nil
        XCTAssertNil(sut.root)
        for k in givenKeys {
            XCTAssertNil(sut.ceiling(k))
        }
        
        // when root is not nil…
        whenRootContainsHalfGivenElements()
        
        // …and k is smaller than or equal maxKey,
        // then returns smallest included key larger than k
        let keysSmallerThanOrEqualToSutMaxKey = givenKeys.filter { $0 <= sut.maxKey! }
        for k in keysSmallerThanOrEqualToSutMaxKey {
            let result = sut.ceiling(k)
            XCTAssertNotNil(result)
            let expectedResult = sut!
                .map { $0.0 }
                .first(where: { $0 >= k })
            XCTAssertEqual(result, expectedResult, "k was \(k)")
        }
        
        // …and k is larger than maxKey, then returns nil
        let keysLargerThanSutMaxKey = givenKeys.filter { $0 > sut.maxKey! }
        for k in keysLargerThanSutMaxKey {
            XCTAssertNil(sut.ceiling(k))
        }
    }
    
    // MARK: - select(rank:) tests
    func testSelect() {
        // returns i-th element of enumerated where i is equal to rank
        whenRootContainsHalfGivenElements()
        for rank in 0..<sut.count {
            for (i, expectedResult) in sut.enumerated() where i == rank {
                let result = sut.selection(rank: rank)
                XCTAssertEqual(result.0, expectedResult.0)
                XCTAssertEqual(result.1, expectedResult.1)
            }
        }
    }
    
    // MARK: - Sequence conformance tests
    func testUnderEstimatedCount() {
        // when root is nil returns 0
        XCTAssertNil(sut.root)
        XCTAssertEqual(sut.underestimatedCount, 0)
        
        // when root is not nil, returns root.understimatedCount
        whenRootContainsAllGivenElements()
        while sut.root != nil {
            XCTAssertEqual(sut.underestimatedCount, sut.root!.underestimatedCount)
            sut.removeValueForMinKey()
        }
    }
    
    func testMakeIterator() {
        // when root is nil, returns an empty iterator:
        XCTAssertNil(sut.root)
        var sutIter = sut.makeIterator()
        XCTAssertNil(sutIter.next())
        
        // when root is not nil,
        // then returns same root's iterator
        whenRootContainsAllGivenElements()
        sutIter = sut.makeIterator()
        let rootIter = sut.root!.makeIterator()
        while let sutElement = sutIter.next() {
            let rootElement = rootIter.next()
            XCTAssertEqual(sutElement.0, rootElement?.0)
            XCTAssertEqual(sutElement.1, rootElement?.1)
        }
        XCTAssertNil(rootIter.next(), "root iterator has more elements than sut iterator")
    }
    
    func testReversed() {
        // when root is nil, then returns empty array
        XCTAssertNil(sut.root)
        XCTAssertTrue(sut.reversed().isEmpty)
        
        // when root is not nil,
        // then returns result of root.reversed
        for _ in 0..<100 {
            whenRootContainsHalfGivenElements()
            let expectedResult = sut.root!.reversed()
            let result = sut.reversed()
            XCTAssertEqual(result.map { $0.0 }, expectedResult.map { $0.0 })
            XCTAssertEqual(result.map { $0.1 }, expectedResult.map { $0.1 })
        }
    }
    
    // MARK: - Functional programming methods & tree traversals tests
    // Note:    Plenty of these methods just wrap around LLRBTree.Node
    //          therefore leveraging also on BinaryNode, thus tests are
    //          not done for main functionality in those cases.
    func testForEach() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.forEach(alwaysThrowingBody))
        
        // when root is nil, body never gets executed:
        var executed: Bool = false
        sut.forEach({ _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil and body throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.forEach(alwaysThrowingBody))
        
        // when root is not nil and body doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.forEach(neverThrowingBody))
        
        // Leverages on BinaryNode forEach(_:) implementation
    }
    
    func testFilter() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.filter(alwaysThrowingPredicate))
        
        // when root is nil, then isIncluded never executes:
        var executed: Bool = false
        let _ = sut.filter { _ in
            executed = true
            return false
        }
        XCTAssertFalse(executed)
        
        // when root is not nil and isIncluded throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.filter(alwaysThrowingPredicate))
        
        // when root is not nil and isIncluded doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.filter(neverThrowingPredicate))
        
        // Leverages on BinaryNode filter(_:) implementation
    }
    
    func testMap() {
        // when root is nil never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut!.map({ _ in throw err }))
        
        // when root is nil, transform never gets executed:
        var executed: Bool = false
        let _: [(String)] = sut!.map({
            executed = true
            return $0.0
        })
        XCTAssertFalse(executed)
        
        // when root is not nil and transform throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut!.map({ _ in throw err }))
        
        // when root is not nil and transform doesn't throw,
        // then doesnt throw
        XCTAssertNoThrow(try sut!.map({ element throws -> String in
                                        return element.0}))
        
        // Leverages on BinaryNode map(_:) implementation
    }
    
    func testCompactMap() {
        // when root is nil never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut!.compactMap({ _ in throw err }))
        
        // when root is nil, transform never gets executed:
        var executed: Bool = false
        let _: [(String)] = sut!.compactMap({
            executed = true
            return $0.0
        })
        XCTAssertFalse(executed)
        
        // when root is not nil and transform throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut!.compactMap({ _ in throw err }))
        
        // when root is not nil and transform doesn't throw,
        // then doesnt throw
        XCTAssertNoThrow(try sut!.compactMap({ element throws -> String in
                                        return element.0}))
        
        // Leverages on BinaryNode compactMap(_:) implementation
    }
    
    func testFlatMap() {
        // when root is nil never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut!.flatMap({ _ throws -> [Bool] in throw err }))
        
        // when root is nil, transform never gets executed:
        var executed: Bool = false
        let _: [String] = sut!.flatMap({ element -> [String] in
            executed = true
            return [element.0]
        })
        XCTAssertFalse(executed)
        
        // when root is not nil and transform throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut!.flatMap({ _ -> [String] in throw err }))
        
        // when root is not nil and transform doesn't throw,
        // then doesnt throw
        XCTAssertNoThrow(try sut.flatMap({ element throws -> [String] in
                                        return [element.0] }))
        
        // Leverages on BinaryNode flatMap(_:) implementation
    }
    
    func testReduceInto() {
        // when root is nil, then never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.reduce(into: "", { _, _  in throw err }))
        
        // when root is nil,
        // then updateAccumulatingResult never executes
        var executed: Bool = false
        let _ = sut.reduce(into: "", { _, _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil, and updateAccumulatingResult throws,
        // then rethrows
        
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.reduce(into: "", { _, _ in throw err }))
        
        // when root is not nil, and updateAccumulatingResult doesn't
        // throw, then doesn't throw
        XCTAssertNoThrow(try sut.reduce(into: "", { _, _ throws -> Void in }))
        
        // Leverages on BinaryNode reduce(into:,_:) implementation
    }
    
    func testReduce() {
        // when root is nil, then never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.reduce("", { _, _  in throw err }))
        
        // when root is nil,
        // then updateAccumulatingResult never executes
        var executed: Bool = false
        let _ = sut.reduce("", { _, _ in executed = true; return "" })
        XCTAssertFalse(executed)
        
        // when root is not nil, and updateAccumulatingResult throws,
        // then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.reduce("", { _, _ in throw err }))
        
        // when root is not nil, and updateAccumulatingResult doesn't
        // throw, then doesn't throw
        XCTAssertNoThrow(try sut.reduce("", { _, _ throws -> String in return "" }))
        
        // Leverages on BinaryNode reduce(_:,_:) implementation
    }
    
    func testFirstWhere() {
        // when root is nil, then never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.first(where: alwaysThrowingPredicate))
        
        // when root is nil, then predicate never gets executed
        var executed: Bool = false
        let _ = sut.first { _ in
            executed = true
            
            return true
        }
        XCTAssertFalse(executed)
        
        // when root is not nil and predicate throws,
        // then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.first(where: alwaysThrowingPredicate))
        
        // when root is not nil and predicate doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.first(where: neverThrowingPredicate))
        
        // Leverages on BinaryNode first(where:) implementation
    }
    
    func testContainsWhere() {
        // when root is nil, then never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.contains(where: alwaysThrowingPredicate))
        
        // when root is nil, then predicate never gets executed
        var executed: Bool = false
        let _ = sut.contains { _ in
            executed = true
            
            return true
        }
        XCTAssertFalse(executed)
        
        // when root is not nil and predicate throws,
        // then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.contains(where: alwaysThrowingPredicate))
        
        // when root is not nil and predicate doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.contains(where: neverThrowingPredicate))
        
        // Leverages on BinaryNode contains(where:) implementation
    }
    
    func testAllSatisfy() {
        // when root is nil, then never throws
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.allSatisfy(alwaysThrowingPredicate))
        
        // when root is nil, then predicate never gets executed
        var executed: Bool = false
        let _ = sut.allSatisfy { _ in
            executed = true
            
            return true
        }
        XCTAssertFalse(executed)
        
        // when root is not nil and predicate throws,
        // then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.allSatisfy(alwaysThrowingPredicate))
        
        // when root is not nil and predicate doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.allSatisfy(neverThrowingPredicate))
        
        // Leverages on BinaryNode allSatisfy(_:) implementation
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
        let result = sut.mapValues(transformValue)
        XCTAssertEqual(result.map { $0.0 }, sut.map { $0.0 })
        XCTAssertEqual(result.map { $0.1 }, sut.map { transformValue($0.1) })
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
        sut.setValue(1000, forKey: "Z")
        // when tranform throws, then rethows
        XCTAssertThrowsError(try sut.compactMapValues(throwingTransform))
        
        // when transform doesn't throw, then doesn't throw
        sut.setValue(999, forKey: "Z")
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
            XCTAssertEqual(result.map { $0.0 }, expectedElements.map { $0.0 })
            XCTAssertEqual(result.map { $0.1 }, expectedElements.map { $0.1 })
        }
    }
    
    func testSetValueForKeyUniquingKeysWith_whenCombineThrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in
            throw err
        }
        // root is nil, then doesn't throw and adds new element
        XCTAssertNil(sut.root)
        let k = givenKeys.randomElement()!
        let newValue = givenRandomValue()
        XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
        XCTAssertEqual(sut.value(forKey: k), newValue)
        XCTAssertEqual(sut.count, 1)
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("root was supposed not to be nil")
        }
        
        // root is not nil, forKey is not in root,
        // then doesn't throw and adds new element
        whenRootContainsHalfGivenElements()
        for k in sutNotIncludedKeys.shuffled() {
            let newValue = givenRandomValue()
            let prevCount = sut.count
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.value(forKey: k), newValue)
            assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
            assertEachNodeCountIsCorrect(root: sut.root!)
        }
        
        // root is not nil and forKey is in tree,
        // then rethrows
        for k in sutIncludedKeys.shuffled() {
            let newValue = givenRandomValue()
            XCTAssertThrowsError(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
        }
    }
    
    func testSetValueForKeyUniquingKeysWith_whenCombineDoesntThrow() {
        var executed: Bool = false
        let combine: (Int, Int) throws -> Int = { prev, next in
            executed = true
            return prev + next
        }
        
        // root is nil, then combine never gets executed
        // and adds new element
        XCTAssertNil(sut.root)
        let newKey = givenKeys.randomElement()!
        let newValue = givenRandomValue()
        XCTAssertNoThrow(try sut.setValue(newValue, forKey: newKey, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertNotNil(sut.root)
        XCTAssertEqual(sut.count, 1)
        XCTAssertEqual(sut.value(forKey: newKey), newValue)
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root is not supposed to be nil")
        }
        
        // root is not nil
        whenRootContainsHalfGivenElements()
        // forKey is not contained in tree,
        // then combine never executes and new element is added
        for k in sutNotIncludedKeys.shuffled() {
            let newValue = givenRandomValue()
            let prevCount = sut.count
            executed = false
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.value(forKey: k), newValue)
            assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
            assertEachNodeCountIsCorrect(root: sut.root!)
        }
        
        // forKey is contained,
        // then combine gets executed, element with that key
        // gets updated with combine result
        for k in sutIncludedKeys.shuffled() {
            let prevCount = sut.count
            let prevValue = sut.value(forKey: k)!
            let newValue = givenRandomValue()
            let expectedValue = try? combine(prevValue, newValue)
            executed = false
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertTrue(executed)
            XCTAssertEqual(sut.value(forKey: k), expectedValue)
            assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
            assertEachNodeCountIsCorrect(root: sut.root!)
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
        givenKeys.forEach { other.setValue(givenRandomValue(), forKey: $0) }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertNotNil(sut.root)
        XCTAssertEqual(sut.map { $0.0 }, other.map { $0.0 })
        XCTAssertEqual(sut.map { $0.1 }, other.map { $0.1 })
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root should not be nil")
        }
        
        // root is not nil and other is empty,
        // then doesn't rethrows and elements are same
        other.root = nil
        let expectedElements = sut!.map { $0 }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertEqual(sut.map { $0.0 }, expectedElements.map { $0.0 })
        XCTAssertEqual(sut.map { $0.1 }, expectedElements.map { $0.1 })
        
        // root is not nil, other is not empty and doesn't contain
        // any duplicate key, then doesn't rethrow and elements
        // from other get inserted
        whenRootContainsHalfGivenElements()
        for k in sutNotIncludedKeys.shuffled() {
            other.setValue(givenRandomValue(), forKey: k)
        }
        let prevCount = sut.count
        let prevElements = sut!.map { $0 }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertEqual(sut.count, prevCount + other.count)
        for otherElement in other {
            XCTAssertEqual(sut.value(forKey: otherElement.0), otherElement.1)
        }
        for prevElement in prevElements {
            XCTAssertEqual(sut.value(forKey: prevElement.0), prevElement.1)
        }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root should not be nil")
        }
        
        // root is not nil and other contains duplicate keys,
        // then throws
        other.root = sut.root?.copy() as? LLRBTree<String, Int>.Node
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
        givenKeys.forEach { other.setValue(givenRandomValue(), forKey: $0) }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertNotNil(sut.root)
        XCTAssertEqual(sut.map { $0.0 }, other.map { $0.0 })
        XCTAssertEqual(sut.map { $0.1 }, other.map { $0.1 })
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root should not be nil")
        }
        
        // root is not nil, other is not empty and doesn't contain
        // any duplicate key, then combine doesn't execute
        // and elements from other get inserted
        whenRootContainsHalfGivenElements()
        other.root = nil
        for k in sutNotIncludedKeys.shuffled() {
            other.setValue(givenRandomValue(), forKey: k)
        }
        var prevCount = sut.count
        var prevElements = sut!.map { $0 }
        executed = false
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertFalse(executed)
        XCTAssertEqual(sut.count, prevCount + other.count)
        for otherElement in other {
            XCTAssertEqual(sut.value(forKey: otherElement.0), otherElement.1)
        }
        for prevElement in prevElements {
            XCTAssertEqual(sut.value(forKey: prevElement.0), prevElement.1)
        }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root should not be nil")
        }
        
        // root is not nil, other is not empty and contains
        // duplicate keys, then other elemnts get inserted and
        // for elements with duplicate keys combine executes and
        // its results are set for elements with duplicate keys
        whenRootContainsHalfGivenElements()
        other.root = nil
        sutNotIncludedKeys.forEach {
            other.setValue(givenRandomValue(), forKey: $0)
        }
        let elementsWithDuplicateKeys = sut
            .prefix(3)
            .map { ($0.0, givenRandomValue()) }
        elementsWithDuplicateKeys.forEach { other.setValue($0.1, forKey: $0.0) }
        let expectedResultForDuplicateKeys = zip(sut.prefix(3), elementsWithDuplicateKeys)
            .map { ($0.0.0, try! combine($0.0.1, $0.1.1)) }
        executed = false
        prevCount = sut.count
        let prevNotIncludedKeys = sutNotIncludedKeys
        prevElements = sut.dropFirst(3).map { $0 }
        XCTAssertNoThrow(try sut.merge(other, uniquingKeysWith: combine))
        XCTAssertTrue(executed)
        XCTAssertEqual(sut.count, prevCount + prevNotIncludedKeys.count)
        prevElements.forEach { XCTAssertEqual(sut.value(forKey: $0.0), $0.1) }
        prevNotIncludedKeys.forEach { XCTAssertEqual(sut.value(forKey: $0), other.value(forKey: $0)) }
        expectedResultForDuplicateKeys.forEach { XCTAssertEqual(sut.value(forKey: $0.0), $0.1) }
        if let root = sut.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("sut.root should not be nil")
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
            other.setValue(givenRandomValue(), forKey: $0)
        }
        let elementsWithDuplicateKeys = sut
            .prefix(3)
            .map { ($0.0, givenRandomValue()) }
        elementsWithDuplicateKeys.forEach { other.setValue($0.1, forKey: $0.0) }
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
        prevSut.dropFirst(3).forEach { XCTAssertEqual(result.value(forKey: $0.0), $0.1) }
        prevNotIncludedKeys.forEach { XCTAssertEqual(result.value(forKey: $0), other.value(forKey: $0)) }
        expectedResultForDuplicateKeys.forEach { XCTAssertEqual(result.value(forKey: $0.0), $0.1) }
        if let root = result.root {
            assertLeftLeaningRedBlackTreeInvariants(root: root)
            assertEachNodeCountIsCorrect(root: root)
        } else {
            XCTFail("result.root should not be nil")
        }
    }
    
    func testInOrderTraverse() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.inOrderTraverse(alwaysThrowingBody))
        
        // when root is nil, body never gets executed:
        var executed: Bool = false
        sut.inOrderTraverse({ _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil and body throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.inOrderTraverse(alwaysThrowingBody))
        
        // when root is not nil and body doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.inOrderTraverse(neverThrowingBody))
        
        // Leverages on BinaryNode inOrderTraverse(_:) implementation
    }
    
    func testReverseInOrderTraverse() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.reverseInOrderTraverse(alwaysThrowingBody))
        
        // when root is nil, body never gets executed:
        var executed: Bool = false
        sut.reverseInOrderTraverse({ _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil and body throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.reverseInOrderTraverse(alwaysThrowingBody))
        
        // when root is not nil and body doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.reverseInOrderTraverse(neverThrowingBody))
        
        // Leverages on BinaryNode reverseInOrderTraverse(_:) implementation
    }
    
    func testPreOrderTraverse() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.preOrderTraverse(alwaysThrowingBody))
        
        // when root is nil, body never gets executed:
        var executed: Bool = false
        sut.preOrderTraverse({ _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil and body throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.preOrderTraverse(alwaysThrowingBody))
        
        // when root is not nil and body doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.preOrderTraverse(neverThrowingBody))
        
        // Leverages on BinaryNode preOrderTraverse(_:) implementation
    }
    
    func testPostOrderTraverse() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.postOrderTraverse(alwaysThrowingBody))
        
        // when root is nil, body never gets executed:
        var executed: Bool = false
        sut.postOrderTraverse({ _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil and body throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.postOrderTraverse(alwaysThrowingBody))
        
        // when root is not nil and body doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.postOrderTraverse(neverThrowingBody))
        
        // Leverages on BinaryNode postOrderTraverse(_:) implementation
    }
    
    func testLevelOrderTraverse() {
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(try sut.levelOrderTraverse(alwaysThrowingBody))
        
        // when root is nil, body never gets executed:
        var executed: Bool = false
        sut.levelOrderTraverse({ _ in executed = true })
        XCTAssertFalse(executed)
        
        // when root is not nil and body throws, then rethrows
        whenRootContainsAllGivenElements()
        XCTAssertThrowsError(try sut.levelOrderTraverse(alwaysThrowingBody))
        
        // when root is not nil and body doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(try sut.levelOrderTraverse(neverThrowingBody))
        
        // Leverages on BinaryNode levelOrderTraverse(_:) implementation
    }
    
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
        lhs.setValue(10, forKey: "A")
        XCTAssertNotNil(lhs.root)
        XCTAssertNil(rhs.root)
        XCTAssertNotEqual(lhs, rhs)
        
        lhs.root = nil
        rhs.setValue(10, forKey: "A")
        XCTAssertNotNil(rhs.root)
        XCTAssertNotEqual(lhs, rhs)
        
        // when both lhs and rhs have non nil root…
        for _ in 0..<100 {
            // …when roots are equal, then returns true
            whenRootContainsHalfGivenElements()
            lhs = sut
            rhs.root = lhs.root?.copy() as? LLRBTree<String, Int>.Node
            XCTAssertEqual(lhs, rhs)
            
            // …when roots are not equal, then returns false:
            rhs.removeValueForMinKey()
            XCTAssertNotEqual(lhs.root, rhs.root)
            XCTAssertNotEqual(lhs, rhs)
        }
    }
    
    // MARK: - Codable tests
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
        XCTAssertEqual(sut!.map { $0.0 }, decoded.map { $0.0 })
        XCTAssertEqual(sut!.map { $0.1 }, decoded.map { $0.1 })
        XCTAssertFalse(sut.root === decoded.root, "sut.root should a different instance than decoded.root")
    }
    
    func testDecode_whenKeysAndValuesAreDifferentCount_thenThrows() {
        let data = try! JSONSerialization.data(withJSONObject: malformedJSONDifferentCounts, options: .prettyPrinted)
        XCTAssertThrowsError(try sut =  JSONDecoder().decode(LLRBTree<String, Int>.self, from: data))
        do {
            sut = try JSONDecoder().decode(LLRBTree<String, Int>.self, from: data)
        } catch {
            XCTAssertEqual(error as NSError, LLRBTree<String, Int>.Error.valueForKeyCount as NSError)
        }
    }
    
    func testDecode_whenKeysContainsDuplicates_thenThrows() {
        let data = try! JSONSerialization.data(withJSONObject: malformedJSONDuplicateKeys, options: .prettyPrinted)
        XCTAssertThrowsError(try sut =  JSONDecoder().decode(LLRBTree<String, Int>.self, from: data))
        do {
            sut = try JSONDecoder().decode(LLRBTree<String, Int>.self, from: data)
        } catch {
            XCTAssertEqual(error as NSError, LLRBTree<String, Int>.Error.duplicateKeys as NSError)
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
        
        // when root is not nil, and other root is a different
        // red-black tree but holds same elements, then
        // are considered identical by Set.
        other.root = nil
        sut.forEach { other.setValue($0.1, forKey: $0.0) }
        XCTAssertNotEqual(sut.root, other.root)
        XCTAssertFalse(set.insert(other).inserted)
    }
    
}

