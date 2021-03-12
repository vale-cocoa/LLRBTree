//
//  LLRBTreeCOWTests.swift
//  LLRBTreeTests
//
//  Created by Valeriano Della Longa on 2021/02/03.
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

final class LLRBTReeCOWTests: BaseLLRBTreeTestCase {
    // MARK: - makeUnique() tests
    func testMakeUnique_whenRootIsNil_thenDoesNothing() {
        XCTAssertNil(sut.root)
        sut.makeUnique()
        XCTAssertNil(sut.root)
    }
    
    func testMakeUnique_whenRootIsNotNilAndIsUniqueStrongReference_thenDoesNothing() {
        whenRootContainsAllGivenElements()
        weak var otherWeakReference = sut.root
        sut.makeUnique()
        XCTAssertTrue(sut.root === otherWeakReference, "sut is not the same instance as before")
    }
    
    func testMakeUnique_whenRootIsNotNilAndIsNotUniqueReference_thenClonesRoot() {
        whenRootContainsAllGivenElements()
        let otherStrongReference = sut.root
        sut.makeUnique()
        XCTAssertFalse(sut.root === otherStrongReference, "sut.root should be a different instance")
        XCTAssertEqual(sut.root, otherStrongReference)
    }
    
    // MARK: - invalidateIndicies() tests
    func testInvalidateIndicies_changesID() {
        let prevID = sut.id
        sut.invalidateIndices()
        XCTAssertFalse(sut.id === prevID, "has not changed id reference")
    }
    
    func testInvalidateIndicies_makesPreviouslyStoredIndicesInvalidForThisTree() {
        whenRootContainsAllGivenElements()
        let previousIndices = sut.indices
        let previousEndIndex = sut.endIndex
        
        sut.invalidateIndices()
        XCTAssertFalse(previousEndIndex.isValidFor(tree: sut))
        for idx in previousIndices {
            XCTAssertFalse(idx.isValidFor(tree: sut))
        }
    }
    
    // MARK: - Mutating methods Copy On Write tests
    func testSetValueForKey() {
        // when root is nil, then clone's root stills nil:
        XCTAssertNil(sut.root)
        var clone = sut!
        sut["A"] = 10
        XCTAssertNil(clone.root)
        
        // when root is not nil, then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut[givenKeys.randomElement()!] = 1000
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
    func testUpdateValueForKey() {
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
    
    func testRemoveValueForMinKey() {
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
    
    func testRemoveValueForKey() {
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
    
    func testMerge() {
        // when root is nil and merge adds elements, then clone's root stills nil
        XCTAssertNil(sut.root)
        var clone = sut!
        sut.merge(givenElements(), uniquingKeysWith: {_, next in
            return next
        })
        XCTAssertNil(clone.root)
        
        // when root is not nil and merge doesn't
        // add new elements, then sut.root doesn't change
        whenRootContainsHalfGivenElements()
        clone = sut!
        weak var prevCloneRoot = clone.root
        sut.merge([], uniquingKeysWith: {_, next in next})
        XCTAssertTrue(sut.root === clone.root, "sut.root should be the same instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // when root is not nil and merge adds new elements,
        // then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        prevCloneRoot = clone.root
        sut.merge(givenElements(), uniquingKeysWith: {_, next in return next })
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
}


