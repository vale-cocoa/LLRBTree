//
//  LLRBTreeBSTTests.swift
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

final class LLRBTreeBSTTests: BaseLLRBTreeTestCase {
    // MARK: - min tests
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
    
    // MARK: - max tests
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
    
    // MARK: - minKey tests
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
    
    // MARK: - maxKey tests
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
    
    // MARK: - select(position:) tests
    func testSelect() {
        // returns i-th element of enumerated where i is equal to rank
        whenRootContainsHalfGivenElements()
        for rank in 0..<sut.count {
            for (i, expectedResult) in sut.enumerated() where i == rank {
                let result = sut.select(position: rank)
                XCTAssertEqual(result.0, expectedResult.0)
                XCTAssertEqual(result.1, expectedResult.1)
            }
        }
    }
    
    // MARK: - inOrderTraverse(_:) tests
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
    
    // MARK: - reverseInOrderTraverse(_:) tests
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
    
    // MARK: - preOrderTraverse(_:)
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
    
    // MARK: - postOrderTraverse(_:)
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
    
    // MARK: - levelOrderTraverse(_:)
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
    
}
