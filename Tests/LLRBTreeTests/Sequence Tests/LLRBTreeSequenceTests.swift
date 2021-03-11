//
//  LLRBTreeSequenceTests.swift
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

final class LLRBTreeSequenceTests: BaseLLRBTreeTestCase {
    // MARK: - underestimatedCount tests
    func testUnderestimatedCount() {
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
    
    // MARK: - makeIterator() tests
    func testMakeIterator() {
        // when root is nil, returns an empty iterator:
        XCTAssertNil(sut.root)
        var sutIter = sut.makeIterator()
        XCTAssertNil(sutIter.next())
        
        // when root is not nil,
        // then returns same root's iterator
        whenRootContainsAllGivenElements()
        sutIter = sut.makeIterator()
        var rootIter = sut.root!.makeIterator()
        while let sutElement = sutIter.next() {
            let rootElement = rootIter.next()
            XCTAssertEqual(sutElement.0, rootElement?.0)
            XCTAssertEqual(sutElement.1, rootElement?.1)
        }
        XCTAssertNil(rootIter.next(), "root iterator has more elements than sut iterator")
    }
    
    // MARK: - reversed() tests
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
            assertEqualsByElements(lhs: result, rhs: expectedResult)
        }
    }
    
    // MARK: - forEach(_:) tests
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
    
    // MARK: - filter(_:) tests
    func testFilter() {
        var result: [(key: String, value: Int)]? = nil
        
        // when root is nil never throws:
        XCTAssertNil(sut.root)
        XCTAssertNoThrow(result = try sut.filter(alwaysThrowingPredicate))
        XCTAssertNotNil(result)
        
        // when root is nil, then isIncluded never executes:
        result = nil
        var executed: Bool = false
        result = sut.filter { _ in
            executed = true
            return false
        }
        XCTAssertFalse(executed)
        XCTAssertNotNil(result)
        
        // when root is not nil and isIncluded throws, then rethrows
        whenRootContainsAllGivenElements()
        result = nil
        XCTAssertThrowsError(result = try sut.filter(alwaysThrowingPredicate))
        XCTAssertNil(result)
        
        // when root is not nil and isIncluded doesn't throw,
        // then doesn't throw
        XCTAssertNoThrow(result = try sut.filter(neverThrowingPredicate))
        XCTAssertNotNil(result)
        
        // Leverages on BinaryNode filter(_:) implementation
    }
    
    // MARK: - map(_:) tests
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
    
    // MARK: - compactMap(_:) tests
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
    
    // MARK: - flatMap(_:) tests
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
    
    // MARK: - reduce(into:_:) tests
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
    
    // MARK: - reduce(_:_:) tests
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
    
    // MARK: - first(where:) tests
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
    
    // MARK: - contains(where:) tests
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
    
    // MARK: - allSatisfy(_:) tests
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
    
}
