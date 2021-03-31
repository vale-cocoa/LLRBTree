//
//  LLRBTree+Sequence.swift
//  LLRBTRee
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

import Foundation

extension LLRBTree: Sequence {
    public typealias Element = (key: Key, value: Value)
    
    /// An iterator over the members of a `LLRBTree<Key, Value>`.
    public struct Iterator: IteratorProtocol {
        private var root: LLRBTree.Node?
        
        private var rootIterator: LLRBTree.Node.Iterator?
        
        private var nextElement: Element?
        
        init(_ root: LLRBTree.Node?) {
            self.root = root
            self.rootIterator = root?.makeIterator()
            prepareNextElement()
        }
        
        public mutating func next() -> Element? {
            defer { prepareNextElement() }
            
            return nextElement
        }
        
        private mutating func prepareNextElement() {
            guard rootIterator != nil else { return }
            
            nextElement = rootIterator!.next()
            guard
                nextElement != nil
            else {
                rootIterator = nil
                root = nil
                
                return
            }
        }
        
    }
    
    public var underestimatedCount: Int { root?.underestimatedCount ?? 0
    }
    
    public func makeIterator() -> Iterator { Iterator(root) }
    
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try root?.forEach(body)
    }
    
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> [Element] {
        try root?.filter(isIncluded) ?? []
    }
    
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        try root?.map(transform) ?? []
    }
    
    public func compactMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try root?.compactMap(transform) ?? []
    }
    
    @available(swift, deprecated: 4.1, renamed: "compactMap(_:)", message: "Please use compactMap(_:) for the case where closure returns an optional value")
    public func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult] {
        try compactMap(transform)
    }
    
    public func flatMap<SegmentOfResult>(_ transform: (Element) throws -> SegmentOfResult) rethrows -> [SegmentOfResult.Element] where SegmentOfResult : Sequence {
        try root?.flatMap(transform) ?? []
    }
    
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        try root?.reduce(into: initialResult, updateAccumulatingResult) ?? initialResult
    }
    
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        try root?.reduce(initialResult, nextPartialResult) ?? initialResult
    }
    
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        try root?.first(where: predicate)
    }
    
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try root?.contains(where: predicate) ?? false
    }
    
    public func allSatisfy(_ predicate: (Element) throws -> Bool) rethrows -> Bool {
        try root?.allSatisfy(predicate) ?? true
    }
    
    public func reversed() -> [Element] {
        root?.reversed() ?? []
    }
    
}
