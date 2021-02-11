//
//  LLRBTreeNodeTests.swift
//  LLRBTreeTests
//
//  Created by Valeriano Della Longa on 2021/01/26.
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

final class LLRBTreeNodeTests: XCTestCase {
    var sut: LLRBTree<String, Int>.Node!
    
    override func setUp() {
        super.setUp()
        
        setUpSUT()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func setUpSUT() {
        let key = givenKeys
            .dropFirst(4)
            .dropLast(4)
            .shuffled()[(givenKeys.count - 8) / 2]
        let value = givenRandomValue()
        sut = LLRBTree.Node(key: key, value: value, color: .black)
    }
    
    // GIVEN
    func givenAllSmallerKeysThanSutKey() -> [String] {
        givenKeys.filter { $0 < sut.key }
    }
    
    func givenAllLargerKeysThanSutKey() -> [String] {
        givenKeys.filter { $0 > sut.key}
    }
    
    // MARK: - WHEN
    func whenBalancedTree() {
        setUpSUT()
        let smallerKeys = givenAllSmallerKeysThanSutKey().prefix(3)
        sut.left = LLRBTree.Node(key: smallerKeys[1], value: givenRandomValue(), color: .black)
        sut.left!.left = LLRBTree.Node(key: smallerKeys[0], value: givenRandomValue(), color: .black)
        sut.left!.right = LLRBTree.Node(key: smallerKeys[2], value: givenRandomValue(), color: .black)
        sut.left!.updateCount()
        sut.left!.updatePaths()
        
        let largerKeys = givenAllLargerKeysThanSutKey().prefix(3)
        sut.right = LLRBTree.Node(key: largerKeys[1], value: givenRandomValue(), color: .black)
        sut.right!.left = LLRBTree.Node(key: largerKeys[0], value: givenRandomValue(), color: .black)
        sut.right!.right = LLRBTree.Node(key: largerKeys[2], value: givenRandomValue(), color: .black)
        sut.right!.updateCount()
        sut.right!.updatePaths()
        
        sut.updateCount()
        sut.updatePaths()
    }
    
    func whenShouldRotateLeft() {
        setUpSUT()
        let leftTreeKeys = givenAllSmallerKeysThanSutKey().prefix(3)
        let rightTreeKeys = givenAllLargerKeysThanSutKey().prefix(3)
        
        sut.left = LLRBTree.Node(key: leftTreeKeys[1], value: givenRandomValue(), color: .black)
        sut.left!.left = LLRBTree.Node(key: leftTreeKeys[0], value: givenRandomValue(), color: .black)
        sut.left!.right = LLRBTree.Node(key: leftTreeKeys[2], value: givenRandomValue(), color: .black)
        sut.left!.updateCount()
        sut.left!.updatePaths()
        
        sut.right = LLRBTree.Node(key: rightTreeKeys[1], value: givenRandomValue())
        sut.right!.left = LLRBTree.Node(key: rightTreeKeys[0], value: givenRandomValue(), color: .black)
        sut.right!.right = LLRBTree.Node(key: rightTreeKeys[2], value: givenRandomValue(), color: .black)
        sut.right!.updateCount()
        sut.right!.updatePaths()
        
        sut.updateCount()
        sut.updatePaths()
    }
    
    func whenHasRedLeftChildAndHasRedLeftGrandChild() {
        setUpSUT()
        let smallerKeys = givenAllSmallerKeysThanSutKey().prefix(4)
        sut.left = LLRBTree.Node(key: smallerKeys[2], value: givenRandomValue())
        sut.left!.left = LLRBTree.Node(key: smallerKeys[1], value: givenRandomValue())
        sut.left!.right = LLRBTree.Node(key: smallerKeys[3], value: givenRandomValue(), color: .black)
        sut.left!.left!.left = LLRBTree.Node(key: smallerKeys[0], value: givenRandomValue(), color: .black)
        sut.left!.left!.updateCount()
        sut.left!.left!.updatePaths()
        sut.left!.updateCount()
        sut.left!.updatePaths()
        
        let largerKeys = givenAllLargerKeysThanSutKey().prefix(2)
        sut.right = LLRBTree.Node(key: largerKeys[1], value: givenRandomValue(), color: .black)
        sut.right!.left = LLRBTree.Node(key: largerKeys[0], value: givenRandomValue())
        sut.right!.updateCount()
        sut.right!.updatePaths()
        
        sut.updateCount()
        sut.updatePaths()
    }
    
    func whenShouldRotateLeftThenRightAndThenFlipColorsToBalance() {
        whenShouldRotateLeft()
        sut.left!.color = .red
    }
    
    func whenShoultRotateRight() {
        whenShouldRotateLeft()
        sut.right!.color = .red
        sut.left!.color = .red
        sut.left!.left!.color = .red
    }
    
    func whenShouldMoveRedLeft_RightLeftIsBlack() {
        setUpSUT()
        let smallKeys = givenAllSmallerKeysThanSutKey().prefix(4)
        let largerKeys = givenAllLargerKeysThanSutKey().prefix(4)
        
        sut.color = .red
        
        sut.left = LLRBTree.Node(key: smallKeys[2], value: givenRandomValue(), color: .black)
        sut.left!.left = LLRBTree.Node(key: smallKeys[1], value: givenRandomValue(), color: .black)
        sut.left!.right = LLRBTree.Node(key: smallKeys[3], value: givenRandomValue(), color: .black)
        sut.left!.left!.left = LLRBTree.Node(key: smallKeys[0], value: givenRandomValue(), color: .red)
        sut.left!.left!.updateCount()
        sut.left!.left!.updatePaths()
        sut.left!.updateCount()
        sut.left!.updatePaths()
        
        sut.right = LLRBTree.Node(key: largerKeys[2], value: givenRandomValue(), color: .black)
        sut.right!.left = LLRBTree.Node(key: largerKeys[01], value: givenRandomValue(), color: .black)
        sut.right!.left!.left = LLRBTree.Node(key: largerKeys[0], value: givenRandomValue(), color: .red)
        sut.right!.right = LLRBTree.Node(key: largerKeys[3], value: givenRandomValue(), color: .black)
        sut.right!.left!.updateCount()
        sut.right!.left!.updatePaths()
        sut.right!.updateCount()
        sut.right!.updatePaths()
        
        sut.updateCount()
        sut.updatePaths()
    }
    
    func whenShouldMoveRedLeft_RightLeftIsRed() {
        whenShouldMoveRedLeft_RightLeftIsBlack()
        sut.right!.left!.color = .red
        let tK = sut.right!.left!.key
        sut.right!.left!.key = sut.right!.left!.left!.key
        sut.right!.left!.left!.key = tK
        sut.right!.left!.left!.color = .black
        let tN = sut.right!.left!.left!
        sut.right!.left!.left = nil
        sut.right!.left!.right = tN
    }
    
    func whenShouldMoveRedRight_LeftGranChildIsBlack() {
        setUpSUT()
        
        let smallerKeys = givenAllSmallerKeysThanSutKey().prefix(4)
        let largerKeys = givenAllLargerKeysThanSutKey().prefix(4)
        
        sut.color = .red
        
        sut.left = LLRBTree.Node(key: smallerKeys[2], value: givenRandomValue(), color: .black)
        sut.left!.left = LLRBTree.Node(key: smallerKeys[1], value: givenRandomValue(), color: .black)
        sut.left!.left!.left = LLRBTree.Node(key: smallerKeys[0], value: givenRandomValue())
        sut.left!.right = LLRBTree.Node(key: smallerKeys[3], value: givenRandomValue(), color: .black)
        sut.left!.left!.updateCount()
        sut.left!.left!.updatePaths()
        sut.left!.updateCount()
        sut.left!.updatePaths()
        
        sut.right = LLRBTree.Node(key: largerKeys[2], value: givenRandomValue(), color: .black)
        sut.right!.left = LLRBTree.Node(key: largerKeys[1], value: givenRandomValue(), color: .black)
        sut.right!.left!.left = LLRBTree.Node(key: largerKeys[0], value: givenRandomValue(), color: .red)
        sut.right!.right = LLRBTree.Node(key: largerKeys[3], value: givenRandomValue(), color: .black)
        sut.right!.left!.updateCount()
        sut.right!.left!.updatePaths()
        sut.right!.updateCount()
        sut.right!.updatePaths()
        
        sut.updateCount()
        sut.updatePaths()
    }
    
    func whenShouldMoveRedRight_LeftGrandChildIsRed() {
        setUpSUT()
        
        let smallerKeys = givenAllSmallerKeysThanSutKey().prefix(4)
        let largerKeys = givenAllLargerKeysThanSutKey().prefix(4)
        
        sut.color = .red
        
        sut.left = LLRBTree.Node(key: smallerKeys[2], value: givenRandomValue(), color: .black)
        sut.left!.left = LLRBTree.Node(key: smallerKeys[1], value: givenRandomValue())
        sut.left!.left!.left = LLRBTree.Node(key: smallerKeys[0], value: givenRandomValue(), color: .black)
        sut.left!.right = LLRBTree.Node(key: smallerKeys[3], value: givenRandomValue(), color: .black)
        sut.left!.left!.updateCount()
        sut.left!.left!.updatePaths()
        sut.left!.updateCount()
        sut.left!.updatePaths()
        
        sut.right = LLRBTree.Node(key: largerKeys[2], value: givenRandomValue(), color: .black)
        sut.right!.left = LLRBTree.Node(key: largerKeys[1], value: givenRandomValue(), color: .black)
        sut.right!.left!.left = LLRBTree.Node(key: largerKeys[0], value: givenRandomValue(), color: .red)
        sut.right!.right = LLRBTree.Node(key: largerKeys[3], value: givenRandomValue(), color: .black)
        sut.right!.left!.updateCount()
        sut.right!.left!.updatePaths()
        sut.right!.updateCount()
        sut.right!.updatePaths()
        
        sut.updateCount()
        sut.updatePaths()
    }
    
    func whenBalancedTreeWithAllGivenKeys() {
        setUpSUT()
        for key in givenKeys.shuffled() {
            sut.setValue(givenRandomValue(), forKey: key)
            sut.color = .black
        }
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
        assertEachNodeCountIsCorrect(root: sut)
    }
    
    func whenBalancedTreeWithHalfGivenKeys() {
        let halfKeys = givenKeys.shuffled().prefix(givenKeys.count / 2)
        sut = LLRBTree.Node(key: halfKeys.first!, value: givenRandomValue(), color: .black)
        for key in halfKeys.dropFirst() {
            sut.setValue(givenRandomValue(), forKey: key)
            sut.color = .black
        }
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
        assertEachNodeCountIsCorrect(root: sut)
    }
    
    // MARK: - Tests
    func testInit() {
        for color in LLRBTree<String, Int>.Node.Color.allCases {
            sut = nil
            
            let key = givenKeys.shuffled()[givenKeys.count / 2]
            let value = givenRandomValue()
            sut = LLRBTree.Node(key: key, value: value, color: color)
            
            XCTAssertNotNil(sut)
            XCTAssertEqual(sut.key, key)
            XCTAssertEqual(sut.value, value)
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(sut.color, color)
            XCTAssertNil(sut.left)
            XCTAssertNil(sut.right)
        }
    }
    
    func testKey() {
        for key in givenKeys {
            sut.key = key
            XCTAssertEqual(sut.key, key)
        }
    }
    
    func testValue() {
        for _ in 0..<1000 {
            let value  = givenRandomValue()
            sut.value = value
            XCTAssertEqual(sut.value, value)
        }
    }
    
    func testColor() {
        for color in LLRBTree<String, Int>.Node.Color.allCases {
            sut.color = color
            XCTAssertEqual(sut.color, color)
        }
    }
    
    func testCount() {
        for _ in 0..<1000 {
            let count = Int.random(in: 1..<Int.max)
            sut.count = count
            XCTAssertEqual(sut.count, count)
        }
    }
    
    func testLeft() {
        let smallerKeys = givenKeys.filter { $0 < sut.key }
        for lKey in smallerKeys {
            var left: LLRBTree.Node? = LLRBTree.Node(key: lKey, value: givenRandomValue())
            
            sut.left = left
            XCTAssertTrue(sut.left === left, "sut.left instance was not set")
            
            left = nil
            XCTAssertNotNil(sut.left, "sut.left is not a strong reference")
            
            sut.left = nil
            XCTAssertNil(sut.left, "sut.left was not set to nil")
        }
    }
    
    func testRight() {
        let greaterKeys = givenKeys.filter { $0 > sut.key}
        for rKey in greaterKeys {
            var right: LLRBTree.Node? = LLRBTree.Node(key: rKey, value: givenRandomValue(), color: .black)
            
            sut.right = right
            XCTAssertTrue(sut.right === right, "sut.right instance was not set")
            right = nil
            XCTAssertNotNil(sut.right, "sut.right is not a strong reference")
            
            sut.right = nil
            XCTAssertNil(sut.right, "sut.right was not set to nil")
        }
    }
    
    func testNodeColorFlip() {
        for color in LLRBTree<String, Int>.Node.Color.allCases {
            let expectedResult: LLRBTree<String, Int>.Node.Color = color == .red ? .black : .red
            
            var result = color
            result.flip()
            
            XCTAssertEqual(result, expectedResult)
        }
    }
    
    // MARK: - copy(with:) tests
    func testCopyWithZone_whenKeyAndValueAreValueTypes() {
        let a = MYSKey(k: "a")
        let b = MYSKey(k: "b")
        let c = MYSKey(k: "c")
        let aV = MYSValue(v: 1)
        let bV = MYSValue(v: 3)
        let cV = MYSValue(v: 7)
        
        let original = LLRBTree<MYSKey, MYSValue>.Node(key: b, value: bV, color: .red)
        original.left = LLRBTree<MYSKey, MYSValue>.Node(key: a, value: aV, color: .black)
        original.right = LLRBTree<MYSKey, MYSValue>.Node(key: c, value: cV, color: .black)
        original.updateCount()
        
        let clone = original.copy() as? LLRBTree<MYSKey, MYSValue>.Node
        XCTAssertNotNil(clone)
        XCTAssertFalse(original === clone, "Copy is the same reference")
        XCTAssertEqual(clone?.key, original.key)
        XCTAssertEqual(clone?.value, original.value)
        XCTAssertEqual(clone?.color, original.color)
        XCTAssertEqual(clone?.count, original.count)
        
        XCTAssertNotNil(clone?.left)
        XCTAssertFalse(original.left === clone?.left, "sut.left copy wasn't a deep copy")
        XCTAssertEqual(original.left?.key, clone?.left?.key)
        XCTAssertEqual(original.left?.value, clone?.left?.value)
        XCTAssertEqual(original.left?.color, clone?.left?.color)
        XCTAssertEqual(original.left?.count, clone?.left?.count)
        XCTAssertNil(clone?.left?.left)
        XCTAssertNil(clone?.left?.right)
        
        XCTAssertNotNil(clone?.right)
        XCTAssertFalse(original.right === clone?.right, "sut.right copy wasn't a deep copy")
        XCTAssertEqual(original.right?.key, clone?.right?.key)
        XCTAssertEqual(original.right?.value, clone?.right?.value)
        XCTAssertEqual(original.right?.color, clone?.right?.color)
        XCTAssertEqual(original.right?.count, clone?.right?.count)
        XCTAssertNil(clone?.right?.left)
        XCTAssertNil(clone?.right?.right)
        
        clone?.left?.key = MYSKey(k: "f")
        clone?.left?.value = MYSValue(v: 11)
        clone?.key = MYSKey(k: "g")
        clone?.value = MYSValue(v: 14)
        clone?.right?.key = MYSKey(k: "h")
        clone?.right?.value = MYSValue(v: 19)
        XCTAssertNotEqual(original.key, clone?.key)
        XCTAssertNotEqual(original.value, clone?.value)
        XCTAssertNotEqual(original.left?.key, clone?.left?.key)
        XCTAssertNotEqual(original.left?.value, clone?.left?.value)
        XCTAssertNotEqual(original.right?.key, clone?.right?.key)
        XCTAssertNotEqual(original.right?.value, clone?.right?.value)
    }
    
    func testCopyWithZone_whenKeyAndValueAreNSCopying() {
        let a = MYKey("a")
        let b = MYKey("b")
        let c = MYKey("c")
        
        let aV = MyValue(1)
        let bV = MyValue(3)
        let cV = MyValue(7)
        
        let original = LLRBTree<MYKey, MyValue>.Node(key: b, value: bV, color: .red)
        original.left = LLRBTree<MYKey, MyValue>.Node(key: a, value: aV, color: .black)
        original.right = LLRBTree<MYKey, MyValue>.Node(key: c, value: cV, color: .black)
        original.updateCount()
        
        let clone = original.copy() as? LLRBTree<MYKey, MyValue>.Node
        XCTAssertNotNil(clone)
        XCTAssertFalse(original === clone, "Copy is the same reference")
        XCTAssertFalse(original.key === clone?.key, "key is not a deep copy")
        XCTAssertFalse(original.value === clone?.value, "value is not a deep copy")
        
        XCTAssertEqual(original.key, clone?.key)
        XCTAssertEqual(original.value, clone?.value)
        XCTAssertEqual(original.color, clone?.color)
        XCTAssertEqual(original.count, clone?.count)
        
        XCTAssertNotNil(clone?.left)
        XCTAssertFalse(original.left === clone?.left, "left is not a deep copy")
        XCTAssertEqual(original.left?.key, clone?.left?.key)
        XCTAssertEqual(original.left?.value, clone?.left?.value)
        XCTAssertEqual(original.left?.color, clone?.left?.color)
        XCTAssertEqual(original.left?.count, clone?.left?.count)
        XCTAssertNil(clone?.left?.left)
        XCTAssertNil(clone?.left?.right)
        
        XCTAssertNotNil(clone?.right)
        XCTAssertFalse(original.right === clone?.right, "right is not a deep copy")
        XCTAssertEqual(original.right?.key, clone?.right?.key)
        XCTAssertEqual(original.right?.value, clone?.right?.value)
        XCTAssertEqual(original.right?.color, clone?.right?.color)
        XCTAssertEqual(original.right?.count, clone?.right?.count)
        XCTAssertNil(clone?.right?.left)
        XCTAssertNil(clone?.right?.right)
    }
    
    // MARK: - Computed properties test
    // MARK: - min and minKey tests
    func testMin_whenLeftIsNil_thenReturnsSelf() {
        XCTAssertNil(sut.left)
        XCTAssertEqual(sut.min, sut)
        XCTAssertEqual(sut.minKey, sut.key)
    }
    
    func testMin_whenLeftIsLeaf_thenReturnsLeft() {
        let smallerKey = givenAllSmallerKeysThanSutKey()
            .randomElement()!
        
        sut.left = LLRBTree.Node(key: smallerKey, value: givenRandomValue(), color: .red)
        
        XCTAssertEqual(sut.min, sut.left)
        XCTAssertEqual(sut.minKey, sut.left?.key)
        XCTAssertLessThan(sut.minKey, sut.key)
    }
    
    func testMin_whenLeftIsTree_thenReturnsLeftMin() {
        let smallerKeys = givenAllSmallerKeysThanSutKey()
        let leftTree = LLRBTree.Node(key: smallerKeys[1], value: givenRandomValue(), color: .red)
        leftTree.left = LLRBTree.Node(key: smallerKeys[0], value: givenRandomValue(), color: .black)
        leftTree.right = LLRBTree.Node(key: smallerKeys[2], value: givenRandomValue(), color: .black)
        leftTree.updatePaths()
        
        let expectedResult = leftTree.min
        sut.left = leftTree
        sut.updatePaths()
        
        XCTAssertEqual(sut.min, expectedResult)
        XCTAssertEqual(sut.minKey, expectedResult.key)
        XCTAssertLessThan(sut.minKey, sut.key)
    }
    
    // MARK: - max and maxKey tests
    func testMax_whenRightIsNil_thenReturnsSelf() {
        XCTAssertNil(sut.right)
        XCTAssertEqual(sut.max, sut)
        XCTAssertEqual(sut.maxKey, sut.key)
    }
    
    func testMax_whenRightIsLeaf_thenReturnsRight() {
        let largerKey = givenAllLargerKeysThanSutKey()
            .randomElement()!
        
        sut.right = LLRBTree.Node(key: largerKey, value: givenRandomValue(), color: .black)
        
        XCTAssertEqual(sut.max, sut.right)
        XCTAssertEqual(sut.maxKey, sut.right?.key)
        XCTAssertGreaterThan(sut.maxKey, sut.key)
    }
    
    func testMax_whenRightIsTree_thenReturnsRightMax() {
        let largerKeys = givenAllLargerKeysThanSutKey()
        let rightTree = LLRBTree.Node(key: largerKeys[1], value: givenRandomValue(), color: .black)
        rightTree.left = LLRBTree.Node(key: largerKeys[0], value: givenRandomValue())
        rightTree.right = LLRBTree.Node(key: largerKeys[2], value: givenRandomValue(), color: .black)
        rightTree.updatePaths()
        
        let expectedResult = rightTree.max
        
        sut.right = rightTree
        sut.updatePaths()
        XCTAssertEqual(sut.max, expectedResult)
        XCTAssertEqual(sut.maxKey, expectedResult.key)
        XCTAssertGreaterThan(sut.maxKey, sut.key)
    }
    
    // MARK: - isRed, hasRedLeftChild, hasRedRightChild, tests
    func testIsRed() {
        XCTAssertEqual(sut.isRed, sut.color == .red)
        sut.color.flip()
        XCTAssertEqual(sut.isRed, sut.color == .red)
    }
    
    func testHasRedLeftChild() {
        XCTAssertNil(sut.left)
        XCTAssertFalse(sut.hasRedLeftChild)
        
        sut.left = LLRBTree.Node(key: givenAllSmallerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        XCTAssertTrue(sut.hasRedLeftChild)
        
        sut.left?.color.flip()
        XCTAssertFalse(sut.hasRedLeftChild)
    }
    
    func testHasRedRightChild() {
        XCTAssertNil(sut.right)
        XCTAssertFalse(sut.hasRedRightChild)
        
        sut.right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        XCTAssertTrue(sut.hasRedRightChild)
        
        sut.right?.color.flip()
        XCTAssertFalse(sut.hasRedRightChild)
    }
    
    // MARK: - hasRedBothChildren tests
    func testHasRedBothChildren_whenBothChildrenAreNil_thenReturnsFalse() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        XCTAssertFalse(sut.hasRedBothChildren)
    }
    
    func testHasRedBothChildren_whenHasJustOneChild_thenReturnsFalse() {
        sut.left = LLRBTree.Node(key: givenAllSmallerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        XCTAssertNil(sut.right)
        XCTAssertFalse(sut.hasRedBothChildren)
        sut.left?.color.flip()
        XCTAssertFalse(sut.hasRedBothChildren)
        
        sut.right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        sut.left = nil
        XCTAssertFalse(sut.hasRedBothChildren)
        sut.right?.color.flip()
        XCTAssertFalse(sut.hasRedBothChildren)
    }
    
    func testHasRedBothChildren_whenHasBothChildren_thenReturnsTrueIfBothAreRed() {
        sut.left = LLRBTree.Node(key: givenAllSmallerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        sut.right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        XCTAssertTrue(sut.hasRedBothChildren)
        
        sut.left?.color = .black
        sut.right?.color = .black
        XCTAssertFalse(sut.hasRedBothChildren)
        
        sut.right?.color = .red
        XCTAssertFalse(sut.hasRedBothChildren)
        
        sut.left?.color = .red
        sut.right?.color = .black
        XCTAssertFalse(sut.hasRedBothChildren)
    }
    
    // MARK: - hasRedLeftGrandChild tests
    func testHasRedLeftGrandChild_returnsTrueIfLeftGrandchildIsRed() {
        XCTAssertNil(sut.left)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        
        let smallerKeys = givenAllSmallerKeysThanSutKey()
        
        sut.left = LLRBTree.Node(key: smallerKeys[1], value: givenRandomValue(), color: .black)
        XCTAssertNil(sut.left?.left)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        
        sut.left?.left = LLRBTree.Node(key: smallerKeys[0], value: givenRandomValue(), color: .black)
        XCTAssertNotNil(sut.left?.left)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        
        sut.left?.left?.color = .red
        XCTAssertTrue(sut.hasRedLeftGrandChild)
        
        sut.left?.color = .red
        XCTAssertTrue(sut.hasRedLeftGrandChild)
    }
    
    // MARK: - rank(_:), floor(_:), ceiling(_:) and selection(rank:) methods tests
    // MARK: - rank(_:) tests
    func testRankWhenBothChildrenAreNil() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        // k < node.key then returns 0
        let smallerKey = givenAllSmallerKeysThanSutKey().randomElement()!
        XCTAssertEqual(sut.rank(smallerKey), 0)
        
        // k == node.key, then returns 0
        XCTAssertEqual(sut.rank(sut.key), 0)
        
        // k > node.key, then returns 1
        let largerKey = givenAllLargerKeysThanSutKey().randomElement()!
        XCTAssertEqual(sut.rank(largerKey), 1)
    }
    
    func testRankWhenEitherOrBothChildrenAreNotNil() {
        whenBalancedTreeWithHalfGivenKeys()
        let leftTree = sut.left!
        let rightTree = sut.right!
        
        // left is nil, right is not nil
        sut.left = nil
        
        // k < node.key, then returns 0
        for smallerKey in givenAllSmallerKeysThanSutKey() {
            XCTAssertEqual(sut.rank(smallerKey), 0)
        }
        // k == node.key, then returns 0
        XCTAssertEqual(sut.rank(sut.key), 0)
        // k > node.key, then returns 1 + node.right.rank(k)
        for greaterKey in givenAllLargerKeysThanSutKey() {
            let rRank = rightTree.rank(greaterKey)
            XCTAssertEqual(sut.rank(greaterKey), 1 + rRank)
        }
        
        // left is not nil, right is nil
        sut.left = leftTree
        sut.right = nil
        // k < node.key, then returns left.rank(k)
        for smallerKey in givenAllSmallerKeysThanSutKey() {
            let lRank = leftTree.rank(smallerKey)
            XCTAssertEqual(sut.rank(smallerKey), lRank)
        }
        // k == node.key, then returns node.left.count
        XCTAssertEqual(sut.rank(sut.key), leftTree.count)
        // k > node.key, then returns node.left.count + 1
        for greaterKey in givenAllLargerKeysThanSutKey() {
            XCTAssertEqual(sut.rank(greaterKey), 1 + leftTree.count)
        }
        
        // both left and right are not nil
        sut.right = rightTree
        // k < node.key, then returns left.rank(k)
        for smallerKey in givenAllSmallerKeysThanSutKey() {
            let lRank = leftTree.rank(smallerKey)
            XCTAssertEqual(sut.rank(smallerKey), lRank)
        }
        // k == node.key, then returns node.left.count
        XCTAssertEqual(sut.rank(sut.key), leftTree.count)
        // k > node.key, then returns node.left.count + 1 + right.rank(k)
        for greaterKey in givenAllLargerKeysThanSutKey() {
            XCTAssertEqual(sut.rank(greaterKey), 1 + leftTree.count + rightTree.rank(greaterKey))
        }
    }
    
    // MARK: - floor(_:) tests
    func testFloor_whenBothChildrenAreNil() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        // k == node.key, then returns node
        XCTAssertNotNil(sut.floor(sut.key))
        XCTAssertTrue(sut.floor(sut.key) === sut, "should have returned sut instance")
        // k < node.key, then returns nil
        for k in givenAllSmallerKeysThanSutKey() {
            XCTAssertNil(sut.floor(k))
        }
        // k > node.key, then returns node
        for k in givenAllLargerKeysThanSutKey() {
            XCTAssertNotNil(sut.floor(k))
            XCTAssertTrue(sut.floor(sut.key) === sut, "should have returned sut instance")
        }
    }
    
    func testFloorWhenEitherOrBothChildrenAreNotNil() {
        whenBalancedTreeWithHalfGivenKeys()
        let leftTree = sut.left!
        let rightTree = sut.right!
        
        // node.left is nil, node.right is not nil
        sut.left = nil
        
        // k == node.key, then returns node
        XCTAssertNotNil(sut.floor(sut.key))
        XCTAssertTrue(sut.floor(sut.key) === sut, "should have returned sut instance")
        // k < node.key, then returns nil
        for k in givenAllSmallerKeysThanSutKey() {
            XCTAssertNil(sut.floor(k))
        }
        // k > node.key, then returns either right.floor(k) or sut
        // if right.floor(k) was nil
        for k in givenAllLargerKeysThanSutKey() {
            let f = sut.floor(k)
            XCTAssertNotNil(f)
            if let rightFloor = rightTree.floor(k) {
                XCTAssertTrue(f === rightFloor, "should have returned sut.right.floor(k) returned node instance")
            } else {
                XCTAssertTrue(f === sut, "should have returned sut instance")
            }
        }
        
        // node.left is not nil, node.right is nil
        sut.left = leftTree
        sut.right = nil
        
        // k == node.key, then returns node
        XCTAssertNotNil(sut.floor(sut.key))
        XCTAssertTrue(sut.floor(sut.key) === sut, "should have returned sut instance")
        // k < node.key, then returns node.left.floor(k) result
        for k in givenAllSmallerKeysThanSutKey() {
            let f = sut.floor(k)
            if let leftFloor = leftTree.floor(k) {
                XCTAssertNotNil(f)
                XCTAssertTrue(f === leftFloor, "should have returned sut.left.floor(k) returned node instance")
            } else {
                XCTAssertNil(f)
            }
        }
        // k > node.key, then returns node
        for k in givenAllLargerKeysThanSutKey() {
            let f = sut.floor(k)
            XCTAssertNotNil(f)
            XCTAssertTrue(f === sut, "should have returned sut instance")
        }
        
        // both node.left and node.right are not nil
        sut.right = rightTree
        
        // k == node.key, then returns node
        XCTAssertNotNil(sut.floor(sut.key))
        XCTAssertTrue(sut.floor(sut.key) === sut, "should have returned sut instance")
        // k < node.key, then returns node.left.floor(k) result
        for k in givenAllSmallerKeysThanSutKey() {
            let f = sut.floor(k)
            if let leftFloor = leftTree.floor(k) {
                XCTAssertNotNil(f)
                XCTAssertTrue(f === leftFloor, "should have returned sut.left.floor(k) returned node instance")
            } else {
                XCTAssertNil(f)
            }
        }
        // k > node.key, then returns either right.floor(k) or sut
        // if right.floor(k) was nil
        for k in givenAllLargerKeysThanSutKey() {
            let f = sut.floor(k)
            XCTAssertNotNil(f)
            if let rightFloor = rightTree.floor(k) {
                XCTAssertTrue(f === rightFloor, "should have returned sut.right.floor(k) returned node instance")
            } else {
                XCTAssertTrue(f === sut, "should have returned sut instance")
            }
        }
    }
    
    // MARK: - ceiling(_:) tests
    func testCeiling_whenBothChildrenAreNil() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        // k == node.key, then returns node
        XCTAssertNotNil(sut.ceiling(sut.key))
        XCTAssertTrue(sut.ceiling(sut.key) === sut, "should have returned sut instance")
        // k > node.key, then returns nil
        for k in givenAllLargerKeysThanSutKey() {
            XCTAssertNil(sut.ceiling(k))
        }
        // k < node.key, then returns node
        for k in givenAllSmallerKeysThanSutKey() {
            XCTAssertNotNil(sut.ceiling(k))
            XCTAssertTrue(sut.ceiling(sut.key) === sut, "should have returned sut instance")
        }
    }
    
    func testCeilingWhenEitherOrBothChildrenAreNotNil() {
        whenBalancedTreeWithHalfGivenKeys()
        let leftTree = sut.left!
        let rightTree = sut.right!
        
        // node.left is not nil, node.right is nil
        sut.right = nil
        
        // k == node.key, then returns node
        XCTAssertNotNil(sut.ceiling(sut.key))
        XCTAssertTrue(sut.ceiling(sut.key) === sut, "should have returned sut instance")
        // k > node.key, then returns nil
        for k in givenAllLargerKeysThanSutKey() {
            XCTAssertNil(sut.ceiling(k))
        }
        // k < node.key, then returns either left.ceiling(k)
        // or sut if left.ceiling(k) was nil
        for k in givenAllSmallerKeysThanSutKey() {
            let c = sut.ceiling(k)
            XCTAssertNotNil(c)
            if let leftCeiling = leftTree.ceiling(k) {
                XCTAssertTrue(c === leftCeiling, "should have returned sut.left.ceiling(k) returned node instance")
            } else {
                XCTAssertTrue(c === sut, "should have returned sut instance")
            }
        }
        
        // node.left is nil, node.right not is nil
        sut.left = nil
        sut.right = rightTree
        
        // k == node.key, then returns node
        XCTAssertNotNil(sut.ceiling(sut.key))
        XCTAssertTrue(sut.ceiling(sut.key) === sut, "should have returned sut instance")
        // k > node.key, then returns
        // node.right.ceiling(k) result
        for k in givenAllLargerKeysThanSutKey() {
            let c = sut.ceiling(k)
            if let rightCeiling = rightTree.ceiling(k) {
                XCTAssertNotNil(c)
                XCTAssertTrue(c === rightCeiling, "should have returned sut.left.floor(k) returned node instance")
            } else {
                XCTAssertNil(c)
            }
        }
        // k < node.key, then returns node
        for k in givenAllSmallerKeysThanSutKey() {
            let c = sut.ceiling(k)
            XCTAssertNotNil(c)
            XCTAssertTrue(c === sut, "should have returned sut instance")
        }
        
        // both node.left and node.right are not nil
        sut.left = leftTree
        
        // k == node.key, then returns node
        XCTAssertNotNil(sut.ceiling(sut.key))
        XCTAssertTrue(sut.ceiling(sut.key) === sut, "should have returned sut instance")
        // k > node.key, then returns
        // node.right.ceiling(k) result
        for k in givenAllLargerKeysThanSutKey() {
            let c = sut.ceiling(k)
            if let rightCeiling = rightTree.ceiling(k) {
                XCTAssertNotNil(c)
                XCTAssertTrue(c === rightCeiling, "should have returned sut.left.floor(k) returned node instance")
            } else {
                XCTAssertNil(c)
            }
        }
        // k < node.key, then returns either left.ceiling(k)
        // or sut if left.ceiling(k) was nil
        for k in givenAllSmallerKeysThanSutKey() {
            let c = sut.ceiling(k)
            XCTAssertNotNil(c)
            if let leftCeiling = leftTree.ceiling(k) {
                XCTAssertTrue(c === leftCeiling, "should have returned sut.left.ceiling(k) returned node instance")
            } else {
                XCTAssertTrue(c === sut, "should have returned sut instance")
            }
        }
    }
    
    // MARK: - select(rank:) tests
    func testSelectRank_whenBothChildrenAreNil() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        // only available rank value is 0 in these circumstances,
        // therefore: and when rank is 0, then returns node:
        XCTAssertTrue(sut.select(rank: 0) === sut, "should hacve returned sut instance")
    }
    
    func testSelectRank_whenEitherOrBothChildrenAreNotNil() {
        whenBalancedTreeWithHalfGivenKeys()
        let leftTree = sut.left!
        let rightTree = sut.right!
        
        // left is nil, right is not nil
        sut.left = nil
        sut.updateCount()
        
        // when rank is equal to 0, returns node
        XCTAssertTrue(sut.select(rank: 0) === sut, "should have returned sut instance")
        // when rank is greater than zero,
        // then returns node.right.select(rank - 1) result
        for rank in 1..<sut.count {
            let rightSelection = rightTree.select(rank: rank - 1)
            XCTAssertTrue(sut.select(rank: rank) === rightSelection, "should have returned instance from sut.right.select(rank: rank - 1)")
        }
        
        // left is not nil, right is nil
        sut.left = leftTree
        sut.right = nil
        sut.updateCount()
        
        // when rank is less than left.count,
        // then returns left.select(rank: rank) result
        for rank in 0..<leftTree.count {
            XCTAssertTrue(sut.select(rank: rank) === leftTree.select(rank: rank), "should have returned sut.left.select(rank: rank) result")
        }
        
        // when rank is equal to left.count,
        // then returns node
        XCTAssertTrue(sut.select(rank: leftTree.count) === sut, "should have returned sut instance")
        
        // both left and right are not nil
        sut.right = rightTree
        sut.updateCount()
        
        // when rank is less than left.count,
        // then returns result of left.select(rank: rank);
        // when rank is equal to left.count, then returns node;
        // when rank is greater than left.count,
        // then returns result from right.select(rank: rank - left.count - 1)
        for rank in 0..<sut.count {
            let result = sut.select(rank: rank)
            if rank < leftTree.count {
                XCTAssertTrue(result === leftTree.select(rank: rank), "should have returned result from sut.left.select(rank: rank)")
            } else if rank == leftTree.count {
                XCTAssertTrue(result === sut, "should have returned sut instance")
            } else {
                XCTAssertTrue(result === rightTree.select(rank: rank - leftTree.count - 1), "should have returned result from sut.right.select(rank: rank - sut.left.count - 1)")
            }
            for (i, expectedResult) in sut.enumerated() where i == rank {
                // element is i-th enumerated where i == rank
                XCTAssertEqual(result.key, expectedResult.0)
                XCTAssertEqual(result.value, expectedResult.1)
            }
        }
    }
    
    // MARK: - Functional Programming methods tests
    // MARK: - mapValues(_:) tests
    func testMapValues_whenTransformThrows() {
        let transform: (Int) throws -> String = { _ in throw err }
        
        whenBalancedTree()
        XCTAssertThrowsError(try sut.mapValues(transform))
    }
    
    func testMapValues_whenTransformDoesntThrow() {
        let transform: (Int) throws -> String = { "\($0)" }
        
        whenBalancedTree()
        let expectedResult = _transformNodeValue(sut, transform)
        
        XCTAssertNoThrow(try sut.mapValues(transform))
        let result = try? sut.mapValues(transform)
        XCTAssertEqual(result, expectedResult)
    }
    
    // MARK: - Sequence overrides tests
    func testUnderestimatedCount_returnsCount() {
        XCTAssertEqual(sut.underestimatedCount, sut.count)
        
        sut.count = 9
        XCTAssertEqual(sut.underestimatedCount, sut.count)
    }
    
    // MARK: - Equatable conformance tests
    func testEquatable_whenLHSAndRHSAreSameInstance_thenReturnsTrue() {
        let rhs = sut
        XCTAssertTrue(sut === rhs)
        XCTAssertTrue(sut == rhs)
    }
    
    func testEquatable_whenLHSAndRhsAreDifferentInstances_thenReturnsTrueIfNodesHaveSameKeyAndValueAndCountAndColorAndLeftAndRight() {
        var other = sut.copy() as! LLRBTree<String, Int>.Node
        XCTAssertFalse(sut === other)
        XCTAssertEqual(sut, other)
        
        other.color.flip()
        XCTAssertNotEqual(sut.color, other.color)
        XCTAssertNotEqual(sut, other)
        
        other = sut.copy() as! LLRBTree<String, Int>.Node
        other.key = "*"
        XCTAssertNotEqual(sut.key, other.key)
        XCTAssertNotEqual(sut, other)
        
        other = sut.copy() as! LLRBTree<String, Int>.Node
        other.value = 1000
        XCTAssertNotEqual(sut.value, other.value)
        XCTAssertNotEqual(sut, other)
        
        other = sut.copy() as! LLRBTree<String, Int>.Node
        other.count += 1
        XCTAssertNotEqual(sut.count, other.count)
        
        // equatable on left and right nodes:
        other = sut.copy() as! LLRBTree<String, Int>.Node
        
        let left = LLRBTree.Node(key: "A", value: 12, color: .black)
        let right = LLRBTree.Node(key: "F", value: 11, color: .black)
        sut.left = left
        XCTAssertNotEqual(sut, other)
        other.left = (left.copy() as! LLRBTree<String, Int>.Node)
        XCTAssertEqual(sut, other)
        sut.right = right
        XCTAssertNotEqual(sut, other)
        other.right = (right.copy() as! LLRBTree<String, Int>.Node)
        XCTAssertEqual(sut, other)
        
        sut.left = nil
        XCTAssertNotEqual(sut, other)
        other.left = nil
        XCTAssertEqual(sut, other)
        
        sut.right = nil
        XCTAssertNotEqual(sut, other)
        
        sut.left = left
        sut.right = right
        
        other.left = LLRBTree.Node(key: "A", value: 23, color: .red)
        other.right = (right.copy() as! LLRBTree<String, Int>.Node)
        
        XCTAssertNotEqual(sut.left, other.left)
        XCTAssertEqual(sut.right, other.right)
        XCTAssertNotEqual(sut, other)
        
        other.left = (left.copy() as! LLRBTree<String, Int>.Node)
        other.right = LLRBTree.Node(key: "Z", value: 11, color: .red)
        XCTAssertEqual(sut.left, other.left)
        XCTAssertNotEqual(sut.right, other.right)
        XCTAssertNotEqual(sut, other)
    }
    
    // MARK: - Tree manipulation utilites tests
    // MARK: - rotateLeft() tests
    func testRotateLeft() {
        whenShouldRotateLeft()
        let clone = sut.copy() as! LLRBTree<String, Int>.Node
        
        weak var oldRight = sut.right
        sut.rotateLeft()
        XCTAssertEqual(sut.key, clone.right!.key)
        XCTAssertEqual(sut.value, clone.right!.value)
        XCTAssertEqual(sut.color, clone.color)
        XCTAssertEqual(sut.count, clone.count)
        
        XCTAssertEqual(sut.left?.key, clone.key)
        XCTAssertEqual(sut.left?.value, clone.value)
        XCTAssertEqual(sut.left?.color, .red)
        XCTAssertEqual(sut.left?.left, clone.left!)
        XCTAssertEqual(sut.left?.right, clone.right!.left!)
        XCTAssertEqual(sut.left?.count, 1 + clone.left!.count + clone.right!.left!.count)
        
        XCTAssertEqual(sut.right, clone.right!.right)
        
        XCTAssertNil(oldRight, "rotateLeft() leaks memory")
        
    }
    
    // MARK: - rotateRight() tests
    func testRotateRight() {
        whenShoultRotateRight()
        let clone = sut.copy() as! LLRBTree<String, Int>.Node
        
        weak var oldLeft = sut.left
        sut.rotateRight()
        XCTAssertEqual(sut.key, clone.left!.key)
        XCTAssertEqual(sut.value, clone.left!.value)
        XCTAssertEqual(sut.count, clone.count)
        XCTAssertEqual(sut.color, clone.color)
        
        XCTAssertEqual(sut.right?.key, clone.key)
        XCTAssertEqual(sut.right?.value, clone.value)
        XCTAssertEqual(sut.right?.color, .red)
        XCTAssertEqual(sut.right?.left, clone.left!.right!)
        XCTAssertEqual(sut.right?.right, clone.right)
        XCTAssertEqual(sut.right?.count, 1 + clone.left!.right!.count + clone.right!.count)
        
        XCTAssertEqual(sut.left, clone.left!.left!)
        
        XCTAssertNil(oldLeft, "rotateLeft leaks memory")
    }
    
    // MARK: - moveRedLeft() tests
    func testMoveRedLeft_whenRightLeftChildIsBlack() {
        whenShouldMoveRedLeft_RightLeftIsBlack()
        XCTAssertFalse(sut.hasRedLeftChild)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        XCTAssertFalse(sut.right!.hasRedLeftChild)
        
        let clone = sut.copy() as! LLRBTree<String, Int>.Node
        
        sut.moveRedLeft()
        XCTAssertEqual(sut.color, .black)
        XCTAssertEqual(sut.left!.color, .red)
        XCTAssertEqual(sut.right!.color, .red)
        
        XCTAssertEqual(sut.key, clone.key)
        XCTAssertEqual(sut.value, clone.value)
        XCTAssertEqual(sut.count, clone.count)
        
        XCTAssertEqual(sut.left?.key, clone.left!.key)
        XCTAssertEqual(sut.left?.value, clone.left!.value)
        XCTAssertEqual(sut.left?.count, clone.left!.count)
        XCTAssertEqual(sut.left?.left, clone.left!.left!)
        XCTAssertEqual(sut.left?.right, clone.left!.right!)
        
        XCTAssertEqual(sut.right?.left, clone.right!.left!)
        XCTAssertEqual(sut.right?.right, clone.right?.right!)
    }
    
    func testMoveRedLeft_whenRightLeftChildIsRed() {
        whenShouldMoveRedLeft_RightLeftIsRed()
        XCTAssertFalse(sut.hasRedLeftChild)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        XCTAssertTrue(sut.right!.hasRedLeftChild)
        
        let expectedResult = sut.copy() as! LLRBTree<String, Int>.Node
        expectedResult.flipColors()
        expectedResult.right!.rotateRight()
        expectedResult.rotateLeft()
        expectedResult.flipColors()
        
        sut.moveRedLeft()
        
        XCTAssertEqual(sut, expectedResult)
        XCTAssertEqual(sut.color, .red)
        XCTAssertFalse(sut.hasRedLeftChild)
        XCTAssertFalse(sut.hasRedLeftChild)
        XCTAssertTrue(sut.hasRedLeftGrandChild)
    }
    
    // MARK: - moveRedRight() tests
    func testMoveRedRight_whenLeftLeftIsBlack() {
        whenShouldMoveRedRight_LeftGranChildIsBlack()
        XCTAssertFalse(sut.left!.isRed)
        XCTAssertFalse(sut.right!.left!.isRed)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        
        let clone = sut.copy() as! LLRBTree<String, Int>.Node
        
        sut.moveRedRight()
        XCTAssertEqual(sut.color, .black)
        XCTAssertEqual(sut.key, clone.key)
        XCTAssertEqual(sut.value, clone.value)
        XCTAssertEqual(sut.count, clone.count)
        
        XCTAssertEqual(sut.left?.color, .red)
        XCTAssertEqual(sut.left?.key, clone.left!.key)
        XCTAssertEqual(sut.left?.value, clone.left!.value)
        XCTAssertEqual(sut.left?.count, clone.left!.count)
        XCTAssertEqual(sut.left?.left, clone.left!.left!)
        XCTAssertEqual(sut.left?.right, clone.left!.right!)
        
        XCTAssertEqual(sut.right?.color, .red)
        XCTAssertEqual(sut.right?.key, clone.right!.key)
        XCTAssertEqual(sut.right?.value, clone.right!.value)
        XCTAssertEqual(sut.right?.count, clone.right!.count)
        XCTAssertEqual(sut.right?.left, clone.right!.left!)
        XCTAssertEqual(sut.right?.right, clone.right!.right!)
    }
    
    
    func testMoveRedRight_whenLeftLeftIsRed() {
        whenShouldMoveRedRight_LeftGrandChildIsRed()
        XCTAssertFalse(sut.left!.isRed)
        XCTAssertFalse(sut.right!.left!.isRed)
        XCTAssertTrue(sut.hasRedLeftGrandChild)
        
        let expectedResult = sut.copy() as! LLRBTree<String, Int>.Node
        expectedResult.flipColors()
        expectedResult.rotateRight()
        expectedResult.flipColors()
        
        sut.moveRedRight()
        
        XCTAssertEqual(sut, expectedResult)
        XCTAssertTrue(sut.isRed)
        XCTAssertFalse(sut.hasRedLeftChild)
        XCTAssertFalse(sut.hasRedRightChild)
        XCTAssertFalse(sut.hasRedLeftGrandChild)
        XCTAssertTrue(sut.right?.hasRedRightChild ?? false)
    }
    
    
    
    // MARK: - fixUp() tests
    func testFixUp_whenIsBlackAndHasRedRightChild_thenRotateLeftOnly() {
        sut.right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue())
        sut.updateCount()
        
        XCTAssertFalse(sut.isRed)
        XCTAssertTrue(sut.hasRedRightChild)
        
        var expectedResult = sut.copy() as! LLRBTree<String, Int>.Node
        expectedResult.rotateLeft()
        
        sut.fixUp()
        XCTAssertEqual(sut, expectedResult)
        
        // let's also test when it has a left (leaf) child
        setUpSUT()
        sut.left = LLRBTree.Node(key: givenAllSmallerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .black)
        sut.right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue())
        sut.updateCount()
        
        XCTAssertFalse(sut.isRed)
        XCTAssertTrue(sut.hasRedRightChild)
        
        expectedResult = sut.copy() as! LLRBTree<String, Int>.Node
        expectedResult.rotateLeft()
        
        sut.fixUp()
        XCTAssertEqual(sut, expectedResult)
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
    }
    
    func testFixUp_whenHasRedLeftChildAndHasRedLeftGrandChild_thenRotateRightAndFlipColors() {
        whenHasRedLeftChildAndHasRedLeftGrandChild()
        let expectedResult = sut.copy() as! LLRBTree<String, Int>.Node
        expectedResult.rotateRight()
        expectedResult.flipColors()
        
        sut.fixUp()
        XCTAssertEqual(sut, expectedResult)
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
    }
    
    func testFixUp_whenHasRedRightChildAndAfterRotatingLefttHasRedLeftChildAndHasRedLeftGrandchild_thenAfterRotatingLeftRotatesRightAndFlipColors() {
        whenShouldRotateLeftThenRightAndThenFlipColorsToBalance()
        let expectedResult = sut.copy() as! LLRBTree<String, Int>.Node
        expectedResult.rotateLeft()
        expectedResult.rotateRight()
        expectedResult.flipColors()
        
        sut.fixUp()
        XCTAssertEqual(sut, expectedResult)
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
    }
    
    func testFixUp_rebalanceAfterMoveRedLeft() {
        whenShouldMoveRedLeft_RightLeftIsRed()
        sut.moveRedLeft()
        
        sut.left!.fixUp()
        sut.fixUp()
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
        
        whenShouldMoveRedLeft_RightLeftIsBlack()
        sut.moveRedLeft()
        
        sut.left!.fixUp()
        sut.fixUp()
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
    }
    
    func testFixUp_rebalanceAfterMoveRedRight() {
        whenShouldMoveRedRight_LeftGrandChildIsRed()
        sut.moveRedRight()
        
        sut.right!.fixUp()
        sut.fixUp()
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
        
        whenShouldMoveRedRight_LeftGranChildIsBlack()
        sut.moveRedRight()
        
        sut.right!.fixUp()
        sut.fixUp()
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
    }
    
    // MARK: - updateCount() tests
    func testUpdateCount_whenBothChildrenAreNil_thenSetsCountToOne() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        sut.count = 3
        sut.updateCount()
        XCTAssertEqual(sut.count, 1)
    }
    
    func testUpdateCount_whenEitherOrBothChildrenAreNotNil_thenSetsCountToSumOfChildrenCountAndOne() {
        let left = LLRBTree.Node(key: givenAllSmallerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .black)
        left.count = 2
        sut.left = left
        sut.count = 10
        XCTAssertNil(sut.right)
        
        sut.updateCount()
        XCTAssertEqual(sut.count, 1 + left.count)
        
        left.count = 1
        sut.updateCount()
        XCTAssertEqual(sut.count, 1 + left.count)
        
        let right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .black)
        right.count = 3
        sut.right = right
        
        sut.updateCount()
        XCTAssertEqual(sut.count, 1 + left.count + right.count)
        
        right.count = 1
        sut.updateCount()
        XCTAssertEqual(sut.count, 1 + left.count + right.count)
        
        sut.left = nil
        right.count = 3
        sut.updateCount()
        XCTAssertEqual(sut.count, 1 + right.count)
        
        right.count = 1
        sut.updateCount()
        XCTAssertEqual(sut.count, 1 + right.count)
    }
    
    // MARK: - flipColors() tests
    func testFlipColors_whenBothChildrenAreNil_thenNodeColorIsFlipped() {
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        var expectedResult = sut.color
        expectedResult.flip()
        
        sut.flipColors()
        XCTAssertEqual(sut.color, expectedResult)
        
        expectedResult.flip()
        sut.flipColors()
        XCTAssertEqual(sut.color, expectedResult)
    }
    
    func testFlipColors_whenBothChildrenAreNotNil_thenNodeAndChildrenColorsAreFlipped() {
        sut.left = LLRBTree.Node(key: givenAllSmallerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        sut.right = LLRBTree.Node(key: givenAllLargerKeysThanSutKey().randomElement()!, value: givenRandomValue(), color: .red)
        var nodeExpectedColor = sut.color
        nodeExpectedColor.flip()
        var leftExpectedColor = sut.left!.color
        leftExpectedColor.flip()
        var rightExpectedColor = sut.right!.color
        rightExpectedColor.flip()
        
        sut.flipColors()
        XCTAssertEqual(sut.color, nodeExpectedColor)
        XCTAssertEqual(sut.left?.color, leftExpectedColor)
        XCTAssertEqual(sut.right?.color, rightExpectedColor)
        
        nodeExpectedColor.flip()
        leftExpectedColor.flip()
        rightExpectedColor.flip()
        
        sut.flipColors()
        XCTAssertEqual(sut.color, nodeExpectedColor)
        XCTAssertEqual(sut.left?.color, leftExpectedColor)
        XCTAssertEqual(sut.right?.color, rightExpectedColor)
    }
    
    // MARK: - C.R.U.D. tests
    // MARK: - get/set value for key tests
    func testGetValueForKey_whenKeyIsInTree_thenReturnsAssociatedValue() {
        whenBalancedTree()
        let elements: [(key: String, value: Int)] = sut!.map { $0 }
        for element in elements {
            XCTAssertEqual(sut.value(forKey: element.key), element.value)
        }
    }
    
    func testGetValueForKey_whenKeyIsNotInTree_thenReturnsNil() {
        whenBalancedTree()
        let containedKeys = Set(sut.map {$0.0} )
        let notContainedKeys = givenKeys
            .filter({ !containedKeys.contains($0) })
        for key in notContainedKeys {
            XCTAssertNil(sut.value(forKey: key))
        }
    }
    
    func testSetValueForKey_whenKeyExistsInTree_thenSetsValueForKeyCountStaysSameAndAllInvariantsHoldTrueAndEachNodeCountIsCorrect() {
        whenBalancedTree()
        let expectedCount = sut.count
        let prevElements: [(key: String, value: Int)] = sut!.map { $0 }
        for element in prevElements {
            sut.setValue(element.value * 10, forKey: element.key)
            XCTAssertEqual(sut.count, expectedCount)
            let newValueForKey = sut.value(forKey: element.key)
            XCTAssertNotEqual(newValueForKey, element.value)
            XCTAssertEqual(newValueForKey, element.value * 10)
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
        }
    }
    
    func testSetValueForKey_whenKeyDoesntExistInTree_thenAddsNewNodeInTreeWithNewKeyValuePairAndCountIsUpdatedAndAllInvariantsHoldTrue() {
        whenBalancedTree()
        let containedKeys = Set(sut.map { $0.0 } )
        let notContainedKeys = givenKeys
            .filter { !containedKeys.contains($0) }
        
        for newKey in notContainedKeys {
            let prevCount = sut.count
            let newValue = givenRandomValue()
            sut.setValue(newValue, forKey: newKey)
            XCTAssertEqual(sut.count, prevCount + 1)
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
            XCTAssertEqual(sut.value(forKey: newKey), newValue)
        }
    }
    
    func testSetValueForKeyUniquingKeys_whenCombineThrows() {
        let combine: (Int, Int) throws -> Int = { _, _ in
            throw err
        }
        // node has no children:
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        // when forKey is not equal to node key,
        // then doesn't throw and adds new element
        for k in givenKeys.filter({ $0 != sut.key }).shuffled() {
            let newValue = givenRandomValue()
            let prevCount = sut.count
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.value(forKey: k), newValue)
            sut.color = .black
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
        }
        
        // when forKey is equal to node key,
        // then rethrows
        XCTAssertThrowsError(try sut.setValue(givenRandomValue(), forKey: sut.key, uniquingKeysWith: combine))
        
        // node is a tree
        whenBalancedTreeWithHalfGivenKeys()
        var containedKeys = Set(sut.map { $0.0 })
        let notContainedKeys = Set(givenKeys.filter { !containedKeys.contains($0) })
        // when forKey is not a key in tree, then doesn't throw
        // and adds to tree new element:
        for k in notContainedKeys.shuffled() {
            let newValue = givenRandomValue()
            let prevCount = sut.count
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.value(forKey: k), newValue)
            sut.color = .black
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
        }
        
        // when forKey is a key in the tree,
        // then rethrows
        containedKeys = Set(sut.map { $0.0 })
        for k in containedKeys.shuffled() {
            XCTAssertThrowsError(try sut.setValue(givenRandomValue(), forKey: k, uniquingKeysWith: combine))
        }
    }
    
    func testSetValueForKeyUniquingKeys_whenCombineDoesnThrow() {
        var executed: Bool = false
        let combine: (Int, Int) throws -> Int = { prev, next in
            executed = true
            return prev + next
        }
        // node has no children
        XCTAssertNil(sut.left)
        XCTAssertNil(sut.right)
        
        // when forKey is not equal to node key,
        // then combine doesn't get executed and adds new element
        for k in givenKeys.filter({ $0 != sut.key }).shuffled() {
            executed = false
            let prevCount = sut.count
            let newValue = givenRandomValue()
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertFalse(executed)
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.value(forKey: k), newValue)
            sut.color = .black
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
        }
        
        // when forKey is equal to node key, then combine gets
        // executed and node value changes to result of combine
        let prevCount = sut.count
        let newValue = givenRandomValue()
        let expectedValue = try? combine(sut.value, newValue)
        executed = false
        XCTAssertNoThrow(try sut.setValue(newValue, forKey: sut.key, uniquingKeysWith: combine))
        XCTAssertTrue(executed)
        XCTAssertEqual(sut.count, prevCount)
        XCTAssertEqual(sut.value(forKey: sut.key), expectedValue)
        assertLeftLeaningRedBlackTreeInvariants(root: sut)
        assertEachNodeCountIsCorrect(root: sut)
        
        // node is a tree
        whenBalancedTreeWithHalfGivenKeys()
        var containedKeys = Set(sut.map { $0.0 })
        let notContainedKeys = Set(givenKeys.filter({ !containedKeys.contains($0) }))
        // when forKey is not contained in tree,
        // then combine doesn't execute and new element is added
        // to tree
        for k in notContainedKeys.shuffled() {
            executed = false
            let prevCount = sut.count
            let newValue = givenRandomValue()
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertFalse(executed)
            XCTAssertEqual(sut.count, prevCount + 1)
            XCTAssertEqual(sut.value(forKey: k), newValue)
            sut.color = .black
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
        }
        
        // when forKey is in tree, then combine gets executed
        // and element's value in tree with key == forKey is
        // updated using combine
        containedKeys = Set(sut.map { $0.0 })
        for k in containedKeys {
            let prevCount = sut.count
            let prevValue = sut.value(forKey: k)!
            let newValue = givenRandomValue()
            let expectedValue = try? combine(prevValue, newValue)
            executed = false
            XCTAssertNoThrow(try sut.setValue(newValue, forKey: k, uniquingKeysWith: combine))
            XCTAssertTrue(executed)
            XCTAssertEqual(sut.count, prevCount)
            XCTAssertEqual(sut.value(forKey: k), expectedValue)
            sut.color = .black
            assertLeftLeaningRedBlackTreeInvariants(root: sut)
            assertEachNodeCountIsCorrect(root: sut)
        }
    }
    
    // MARK: - remove value for key
    func testRemoveValueForKey_whenKeyIsInTree_thenRemovesNodeAndUpdatesCountAndAllInvariantsHoldTrue() {
        for _ in 0..<100 {
            whenBalancedTreeWithAllGivenKeys()
            for key in givenKeys.shuffled() {
                let prevCount = sut?.count ?? 0
                sut = sut?.removingValue(forKey: key)
                sut?.color = .black
                XCTAssertEqual((sut?.count ?? 0), prevCount - 1)
                XCTAssertNil(sut?.value(forKey: key))
                if sut != nil {
                    assertLeftLeaningRedBlackTreeInvariants(root: sut)
                    assertEachNodeCountIsCorrect(root: sut)
                }
            }
            XCTAssertNil(sut, "sut is not nil after having removed all keys")
        }
        
    }
    
    func testRemoveValueForKey_whenKeyIsNotInTree_thenCountIsSameAndAllInvariantsHoldsTrue() {
        for _ in 0..<100 {
            whenBalancedTreeWithHalfGivenKeys()
            let containedKeys = Set(sut.map { $0.0 })
            let notContainedKeys = givenKeys
                .filter { !containedKeys.contains($0) }
            for key in notContainedKeys {
                let prevCount = sut.count
                XCTAssertNil(sut.value(forKey: key))
                
                sut = sut.removingValue(forKey: key)
                XCTAssertEqual(sut.count, prevCount)
                assertLeftLeaningRedBlackTreeInvariants(root: sut)
                assertEachNodeCountIsCorrect(root: sut)
            }
        }
    }
    
    // MARK: - removingValueForMinKey() tests
    func testRemovingValueForMinKey() {
        for _ in 0..<100 {
            whenBalancedTreeWithAllGivenKeys()
            
            for minKey in givenKeys.dropLast() {
                let prevCount = sut.count
                sut = sut.removingValueForMinKey()
                sut.color = .black
                XCTAssertEqual(sut.count, prevCount - 1)
                XCTAssertNil(sut.value(forKey: minKey), "node with \(minKey) was not removed")
                assertLeftLeaningRedBlackTreeInvariants(root: sut)
                assertEachNodeCountIsCorrect(root: sut)
            }
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(sut.key, givenKeys.max())
            sut = sut.removingValueForMinKey()
            XCTAssertNil(sut, "not removed all nodes")
        }
    }
    
    // MARK: - removingValueForMaxKey() tests
    func testRemovingValueForMaxKey() {
        
        for _ in 0..<100 {
            whenBalancedTreeWithAllGivenKeys()
            
            for maxKey in givenKeys.dropFirst().sorted(by: >) {
                let prevCount = sut.count
                sut = sut.removingValueForMaxKey()
                sut.color = .black
                XCTAssertEqual(sut.count, prevCount - 1)
                XCTAssertNil(sut.value(forKey: maxKey), "node with key \(maxKey) was not removed")
                assertLeftLeaningRedBlackTreeInvariants(root: sut)
                assertEachNodeCountIsCorrect(root: sut)
            }
            XCTAssertEqual(sut.count, 1)
            XCTAssertEqual(sut.key, givenKeys.min())
            sut = sut.removingValueForMaxKey()
            XCTAssertNil(sut, "not removed all nodes")
        }
        
    }
    
}
