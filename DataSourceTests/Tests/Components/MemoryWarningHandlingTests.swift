//
//  MemoryWarningHandlingTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 12/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class Component : MemoryWarningHandling {

    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func didReceiveMemoryWarning() {
        expectation.fulfill()
    }
}


class ComponentsComposition : Composable, MemoryWarningHandling {

    typealias Child = Component
    
    @discardableResult
    func add(_ child: Child) -> Bool {
        children.append(child)
        return true
    }
    
    @discardableResult
    func remove(_ child: Child) -> Bool {
        guard let index = children.index(where: { $0 === child }) else { return false }
        children.remove(at: index)
        
        return true
    }
    
    private(set) var children: [Child] = []
}


class MemoryWarningHandlingTests : XCTestCase {
    
    func testMemoryWarningHandling() {
        
        let composition = ComponentsComposition()

        composition.add(Component(expectation: expectation(description: "Memory warning handled in first comonent")))
        composition.add(Component(expectation: expectation(description: "Memory warning handled in second comonent")))

        composition.didReceiveMemoryWarning()

        waitForExpectations(timeout: 0.1) { error in
        }
    }
}
