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
        let keys = givenKeys.shuffled()
        sut.root = LLRBTree.Node(key: keys.first!, value: givenRandomValue(), color: .black)
        for key in keys.dropFirst() {
            sut.root!.setValue(givenRandomValue(), forKey: key)
            sut.root!.color = .black
        }
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
    
    // MARK: - NSCopying conformance tests
    func testCopyWith_whenRootIsNil() {
        XCTAssertNil(sut.root)
        let clone = sut.copy() as? LLRBTree<String, Int>
        XCTAssertNotNil(clone, "copy has returned an instance of a different type")
        XCTAssertNil(clone?.root)
        XCTAssertFalse(sut === clone, "copy returned the same instance instead of a new")
    }
    
    func testCopyWith_whenRootIsNotNil() {
        whenRootContainsAllGivenElements()
        let clone = sut.copy() as! LLRBTree<String, Int>
        XCTAssertNotNil(clone.root, "copy has not copied root")
        XCTAssertEqual(sut.root, clone.root)
        XCTAssertFalse(sut.root === clone.root, "copy was not deep")
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
    
    // MARK: - Other convenience initializers tests
    func testInitElements_whenSequenceIsAnotherLLRBTRee() {
        let other = LLRBTree<String, Int>()
        
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
    
    func testInitElements_whenSequenceIsNotAnotherLLRBTRee() {
        var elements = AnySequence<(String, Int)>(AnyIterator({ return nil }))
        // when elements is empty
        sut = LLRBTree(uniqueKeysWithValues: elements)
        XCTAssertNotNil(sut)
        XCTAssertNil(sut.root)
        
        // when elements is not empty
        elements = AnySequence(givenElements())
        sut = LLRBTree(uniqueKeysWithValues: elements)
        XCTAssertNotNil(sut)
        XCTAssertNotNil(sut.root)
        let expectedElements = elements
            .sorted(by: { $0.0 < $1.0 })
        XCTAssertEqual(sut.root?.map { $0.0 }, expectedElements.map { $0.0 })
        XCTAssertEqual(sut.root?.map { $0.1 }, expectedElements.map { $0.1 })
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
        // the doesn't throw
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
        // when lhs and rhs are same instance, then returns true
        var lhs = sut!
        var rhs = lhs
        XCTAssertEqual(lhs, rhs)
        
        // when lhs and rhs are not same instance:
        // then returns true when both have root == nil
        rhs = LLRBTree()
        XCTAssertFalse(lhs === rhs, "are same instance")
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
        
        // when both lhs and rhs have non nil root:
        for _ in 0..<100 {
            // …and when roots are equal, then returns true
            whenRootContainsHalfGivenElements()
            lhs = sut
            rhs.root = lhs.root?.copy() as? LLRBTree<String, Int>.Node
            XCTAssertEqual(lhs, rhs)
            
            // …and when roots are not equal, then returns false:
            rhs.removeValueForMinKey()
            XCTAssertNotEqual(lhs.root, rhs.root)
            XCTAssertNotEqual(lhs, rhs)
        }
    }
    
    // MARK: - Codable tests
    
    
}

