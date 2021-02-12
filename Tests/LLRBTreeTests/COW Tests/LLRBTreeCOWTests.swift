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

final class LLRBTReeCOWTests: XCTestCase {
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
    // MARK: - makeUnique() tests
    func testMakeUnique_whenRootIsNil_thenDoesNothing() {
        XCTAssertNil(sut.root)
        sut.makeUnique()
        XCTAssertNil(sut.root)
    }
    
    func testMakeUnique_whenRootIsNotNilAndIsUniqueStrongReference_thenDoesNothing() {
        whenRootContainsAllGivenElements()
        weak var otherWeakReference = sut.root
        XCTAssertTrue(isKnownUniquelyReferenced(&sut.root))
        sut.makeUnique()
        XCTAssertTrue(sut.root === otherWeakReference, "sut is not the same instance as before")
    }
    
    func testMakeUnique_whenRootIsNotNilAndIsNotUniqueReference_thenClonesRoot() {
        whenRootContainsAllGivenElements()
        let otherStrongReference = sut.root
       XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
        sut.makeUnique()
        XCTAssertFalse(sut.root === otherStrongReference, "sut.root should be a different instance")
        XCTAssertEqual(sut.root, otherStrongReference)
    }
    
    // MARK: - Mutating methods are Copy On Write capable tests
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
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
        sut[givenKeys.randomElement()!] = 1000
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
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
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
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
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
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
        sut.removeValue(forKey: sutNotIncludedKeys.randomElement()!)
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // when root is not nil and forKey is included
        // then sut.root gets copied
        clone = sut!
        prevCloneRoot = clone.root
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
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
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
        sut.merge([], uniquingKeysWith: {_, next in next})
        XCTAssertTrue(sut.root === clone.root, "sut.root should be the same instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
        
        // when root is not nil and merge adds new elements,
        // then sut.root gets copied
        whenRootContainsHalfGivenElements()
        clone = sut!
        prevCloneRoot = clone.root
        XCTAssertFalse(isKnownUniquelyReferenced(&sut.root))
        sut.merge(givenElements(), uniquingKeysWith: {_, next in return next })
        XCTAssertFalse(sut.root === clone.root, "sut.root should be a different instance")
        XCTAssertTrue(clone.root === prevCloneRoot, "clone.root should have stayed the same")
    }
    
}


