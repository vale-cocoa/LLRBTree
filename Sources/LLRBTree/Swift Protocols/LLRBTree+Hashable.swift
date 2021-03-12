//
//  LLRBTree+Hashable.swift
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

// MARK: - Hashable conformance
extension LLRBTree: Hashable where Key: Hashable, Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(count)
        root?.forEach {
            hasher.combine($0.0)
            hasher.combine($0.1)
        }
    }
    
    public var hashValue: Int {
        var hasher = Hasher()
        self.hash(into: &hasher)
            
        return hasher.finalize()
    }
    
}

// MARK: - Equatable conformance
extension LLRBTree: Equatable where Value: Equatable {
    public static func == (lhs: LLRBTree<Key, Value>, rhs: LLRBTree<Key, Value>) -> Bool {
        guard lhs.root !== rhs.root else { return true }
        
        switch (lhs.root, rhs.root) {
        case (nil, nil): return true
        case (nil, .some(_)): return false
        case (.some(_), nil): return false
        case (.some(let lRoot), .some(let rRoot)):
            
            return lRoot.elementsEqual(rRoot, by: { $0.0 == $1.0 && $0.1 == $1.1 })
        }
    }
    
}
