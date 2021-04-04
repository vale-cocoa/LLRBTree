//
//  LLRBTreeInitializersTests.swift
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

final class LLRBTreeInitializersTests: BaseLLRBTreeTestCase {
    
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
            assertEachNodeCountIsCorrect(root: root)
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
            assertEachNodeCountIsCorrect(root: root)
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
            assertEachNodeCountIsCorrect(root: root)
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

}
