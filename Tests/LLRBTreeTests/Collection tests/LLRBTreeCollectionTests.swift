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

final class LLRBTreeCollectionTests: XCTestCase {
    typealias _Tree = LLRBTree<String, Int>
    
    typealias _Index = _Tree.Index
    
    typealias _Node = _Tree.Node
    
    typealias _WrappedNode = WrappedNode<_Node>
    
    var sut: LLRBTree<String, Int>!
    
    override func setUp() {
        super.setUp()
        
        sut = givenFullTree()
    }
    
    override class func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - Given
    func givenFullTree() -> _Tree {
        var tree = _Tree()
        givenKeys
            .shuffled()
            .forEach { tree.setValue(givenRandomValue(), forKey: $0) }
        
        return tree
    }
    
    // MARK: - Tests
    // MARK: - startIndex tests
    
    
}
