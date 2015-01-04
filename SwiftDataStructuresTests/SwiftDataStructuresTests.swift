//
//  SwiftDataStructuresTests.swift
//  SwiftDataStructuresTests
//
//  Created by Tim Ekl on 6/2/14.
//  Copyright (c) 2014 Tim Ekl. All rights reserved.
//

import XCTest

class OrderedDictionaryTest: XCTestCase {
    func test() {
        var d = OrderedDictionary<String, String>()
        d.append(key: "a", value: "Hello")
        d.append(key: "c", value: "World")
        d.append(key: "b", value: "dear")
        
        XCTAssertEqual(d.filter { $0.key == "b" }.map { $0.value }, ["dear"], "Filter, map")
        
        d.sort { $0.key < $1.key }
        XCTAssertEqual(d.map { $0.value }, ["Hello", "dear", "World"], "In-place sort")
        
        XCTAssertEqual(d[0].key, "a", "Indexed lookup")
        
        var count = 0
        for element in d { count++ }
        XCTAssertEqual(count, 3, "Generator, count")
        
        d["a"] = "Hey"
        XCTAssertEqual(d.count, 3, "Did a replace")
        
        d.append(key: "a", value: "Hello")
        XCTAssertEqual(d.count, 3, "Did a replace")
        
        d.removeAtIndex(1)
        XCTAssertEqual(d.count, 2, "Remove at index")
        XCTAssertEqual(d[0].key, "a", "")
        XCTAssertEqual(d[1].key, "c", "")
        
        d.removeLast()
        XCTAssertEqual(d.count, 1, "Remove last")
        XCTAssertEqual(d[0].key, "a", "")
        
        d["a"] = nil
        XCTAssertEqual(d.count, 0, "Remove by nil assignment")
    }
}
