//
//  LLRBTreeCollectionTests.swift
//  LLRBTreeTests
//
//  Created by Valeriano Della Longa on 2021/02/12.
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
import BinaryNode

final class LLRBTreeCollectionTests: BaseLLRBTreeTestCase {
    typealias _Tree = LLRBTree<String, Int>
    
    typealias _Index = _Tree.Index
    
    typealias _Node = _Tree.Node
    
    typealias _WrappedNode = WrappedNode<_Node>
    
    override func setUp() {
        super.setUp()
        
        whenRootContainsAllGivenElements()
    }
    
    // MARK: - Tests
    // MARK: - startIndex tests
    func testStartIndex() {
        // when isEmpty == true,
        // then returns Index with empty path,
        // nil root and same id of tree
        sut = _Tree()
        var idx = sut.startIndex
        XCTAssertNil(idx.root)
        XCTAssertTrue(idx.path.isEmpty)
        XCTAssertTrue(idx.id === sut.id)
        
        // when isEmpty == false,
        // then returns Index with root wrapping
        // tree root node, path not empty, path.last wrapping
        // tree's root.min node, and same id of tree
        whenRootContainsHalfGivenElements()
        idx = sut.startIndex
        XCTAssertTrue(idx.root?.node === sut.root)
        XCTAssertFalse(idx.path.isEmpty)
        XCTAssertTrue(idx.path.last?.node === sut.root?.min)
        XCTAssertTrue(idx.id === sut.id)
    }
    
    // MARK: endIndex tests
    func testEndIndex() {
        // when isEmpty == true,
        // then returns Index with empty path,
        // nil root and same id of tree
        sut = _Tree()
        var idx = sut.endIndex
        XCTAssertNil(idx.root)
        XCTAssertTrue(idx.path.isEmpty)
        XCTAssertTrue(idx.id === sut.id)
        
        // when isEmpty == false,
        // then returns Index with root wrapping
        // tree root node, path empty, and same id of tree
        whenRootContainsHalfGivenElements()
        idx = sut.endIndex
        XCTAssertTrue(idx.root?.node === sut.root)
        XCTAssertTrue(idx.path.isEmpty)
        XCTAssertTrue(idx.id === sut.id)
    }
    
    // MARK: - first tests
    func testFirst() {
        // when isEmpty == true, then returns nil
        sut = _Tree()
        XCTAssertNil(sut.first)
        
        // when isEmpty == false, then returns min
        whenRootContainsHalfGivenElements()
        while !sut.isEmpty {
            let min = sut.min
            XCTAssertNotNil(sut.first)
            XCTAssertEqual(sut.first?.0, min?.0)
            XCTAssertEqual(sut.first?.1, min?.1)
            sut.removeValueForMinKey()
        }
    }
    
    // MARK: - last tests
    func testLast() {
        // when isEmpty == true, then returns nil
        sut = _Tree()
        XCTAssertNil(sut.last)
        
        // when isEmpty == false, then returns max
        whenRootContainsHalfGivenElements()
        while !sut.isEmpty {
            let max = sut.max
            XCTAssertNotNil(sut.last)
            XCTAssertEqual(sut.last?.0, max?.0)
            XCTAssertEqual(sut.last?.1, max?.1)
            sut.removeValueForMaxKey()
        }
    }
    
    // MARK: - index(after:) tests
    func testIndexAfter() {
        // when i == endIndex, then returns endIndex
        var i = sut.endIndex
        var indexAfter = sut.index(after: i)
        XCTAssertEqual(indexAfter, sut.endIndex)
        
        // when i != endIndex, returns index pointing to next
        // element
        i = sut.startIndex
        indexAfter = i
        var iterator = sut.makeIterator()
        while let expectedElement = iterator.next() {
            XCTAssertEqual(indexAfter.path.last?.node.key, expectedElement.0)
            XCTAssertEqual(indexAfter.path.last?.node.value, expectedElement.1)
            i = indexAfter
            indexAfter = sut.index(after: i)
            XCTAssertGreaterThan(indexAfter, i)
        }
        XCTAssertEqual(indexAfter, sut.endIndex)
    }
    
    // MARK: - formIndex(after:) tests
    func testFormIndexAfter() {
        // when i == endIndex, then returns endIndex
        var i = sut.endIndex
        sut.formIndex(after: &i)
        XCTAssertEqual(i, sut.endIndex)
        
        // when i != endIndex, then returns index pointing to
        // next element
        i = sut.startIndex
        var iterator = sut.makeIterator()
        while let expectedElement = iterator.next() {
            XCTAssertEqual(i.path.last?.node.key, expectedElement.0)
            XCTAssertEqual(i.path.last?.node.value, expectedElement.1)
            let prev = i
            sut.formIndex(after: &i)
            XCTAssertGreaterThan(i, prev)
        }
        XCTAssertEqual(i, sut.endIndex)
    }
    
    // MARK: - index(before:) tests
    func testIndexBefore() {
        // when i == startIndex, then returns endIndex
        var i = sut.startIndex
        var indexBefore = sut.index(before: i)
        XCTAssertEqual(indexBefore, sut.endIndex)
        
        // when i == endIndex, then returns index pointing to
        // last element
        i = sut.endIndex
        indexBefore = sut.index(before: i)
        XCTAssertEqual(indexBefore.path.last?.node.key, sut.max?.0)
        XCTAssertEqual(indexBefore.path.last?.node.value, sut.max?.1)
        
        // when i != endIndex && i != startIndex,
        // then returns index pointing to element before
        let reversed = sut.reversed()
        var reversedIterator = reversed.makeIterator()
        while let prevElement = reversedIterator.next() {
            XCTAssertEqual(indexBefore.path.last?.node.key, prevElement.0)
            XCTAssertEqual(indexBefore.path.last?.node.value, prevElement.1)
            i = indexBefore
            indexBefore = sut.index(before: i)
        }
        XCTAssertEqual(indexBefore, sut.endIndex)
    }
    
    // MARK: - formIndex(before:) tests
    func testFormIndexBefore() {
        // when i == startIndex, then returns endIndex
        var i = sut.startIndex
        sut.formIndex(before: &i)
        XCTAssertEqual(i, sut.endIndex)
        
        // when i == endIndex, then returns index pointing to
        // last element
        i = sut.endIndex
        sut.formIndex(before: &i)
        XCTAssertEqual(i.path.last?.node.key, sut.max?.key)
        XCTAssertEqual(i.path.last?.node.value, sut.max?.value)
        
        // when i != endIndex && i != startIndex,
        // then returns index pointing to element before
        let reversed = sut.reversed()
        var reversedIterator = reversed.makeIterator()
        while let prevElement = reversedIterator.next() {
            XCTAssertEqual(i.path.last?.node.key, prevElement.key)
            XCTAssertEqual(i.path.last?.node.value, prevElement.value)
            sut.formIndex(before: &i)
        }
        XCTAssertEqual(i, sut.endIndex)
    }
    
    // MARK: - subscript tests
    func testSubscript() {
        var iterator = sut.makeIterator()
        var i = sut.startIndex
        while i < sut.endIndex {
            let expectedElement = iterator.next()
            let result = sut[i]
            XCTAssertEqual(result.key, expectedElement?.key)
            XCTAssertEqual(result.value, expectedElement?.value)
            sut.formIndex(after: &i)
        }
    }
    
    // MARK: - remove(at:) tests
    func testRemoveAtIndex() {
        whenRootContainsAllGivenElements()
        for key in givenKeys.shuffled() {
            let copy = sut
            weak var prevID = sut.id
            weak var prevRoot = sut.root
            let prevCount = sut.count
            let expectedValue = sut.getValue(forKey: key)
            let idx = LLRBTree<String, Int>.Index(asIndexOfKey: key, for: sut)
            
            let result = sut.remove(at: idx)
            XCTAssertEqual(result.key, key)
            XCTAssertEqual(result.value, expectedValue)
            XCTAssertNil(sut[key])
            XCTAssertEqual(sut.count, prevCount - 1)
            XCTAssertFalse(sut.id === prevID, "has not updated ID")
            if sut.root != nil {
                assertLeftLeaningRedBlackTreeInvariants(root: sut.root!)
            }
            // value semantics test
            XCTAssertFalse(sut.root === prevRoot, "has not done copy on write")
            XCTAssertTrue(copy?.id === prevID, "has updated id on copy")
            XCTAssertTrue(copy?.root === prevRoot, "has changed root reference on copy while it was supposed to stay the same")
        }
    }
    
    // MARK: - index(forKey:) tests
    func testIndexForKey() {
        // when is empty, then always returns nil
        sut = LLRBTree()
        for _ in 0..<10 {
            XCTAssertNil(sut.index(forKey: givenKeys.randomElement()!))
        }
        
        // when is not empty and key is contained,
        // then returns correct index for key
        whenRootContainsAllGivenElements()
        for k in givenKeys.shuffled() {
            let idx = sut.index(forKey: k)
            XCTAssertNotNil(idx)
            if let idx = idx {
                let element = sut[idx]
                XCTAssertEqual(element.key, k)
                XCTAssertEqual(element.value, sut[k])
            }
        }
        // otherwise when key is not contained, then returns nil
        whenRootContainsHalfGivenElements()
        for key in sutNotIncludedKeys {
            XCTAssertNil(sut[key])
            XCTAssertNil(sut.index(forKey: key))
        }
    }
    
    // MARK: - keys tests
    func testKeys() {
        // when is empty, then keys is empty too
        sut = LLRBTree()
        XCTAssertTrue(sut.keys.isEmpty)
        
        // when is not empty, then keys is not empty and contains
        // all keys in same order
        whenRootContainsHalfGivenElements()
        XCTAssertFalse(sut.keys.isEmpty)
        XCTAssertTrue(sut.keys.indices.elementsEqual(sut.indices, by: { sut.keys[$0] == sut[$1].key }), "keys doesn't contains same keys in the same order")
    }
    
    func testKeys_copyOnWrite() {
        // when storing keys and then changing hash table keys,
        // then stored keys is different
        whenRootContainsHalfGivenElements()
        let storedKeys = sut.keys
        for key in sutNotIncludedKeys {
            sut[key] = givenRandomValue()
            XCTAssertNotEqual(storedKeys, sut.keys)
        }
    }
    
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
