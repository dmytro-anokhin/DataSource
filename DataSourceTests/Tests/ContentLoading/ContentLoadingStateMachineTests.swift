//
//  ContentLoadingStateMachineTests.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 25/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import XCTest
@testable import DataSource


class ContentLoadingStateMachineTests: XCTestCase {

    func testValidTransitions() {

        // First create list of all paths in the content loading graph
        
        let transitions = ContentLoadingStateMachine().transitions
        
        /**
            The function generates list of all transitions from a state. Basically, a list of spanning trees in the content loading transitions graph with starting state as a root.
            
            - Parameter state: Starting state.
            - Parameter visited: Set of visited state.
            
            - Returns: Array of arrays, each containing list of states on a route.
        */
        func routes(state: ContentLoadingState, visited: Set<ContentLoadingState> = []) -> [[ContentLoadingState]] {
            
            // All possible states to transition to, excluding visited states.
            guard let directions = transitions[state]?.filter({ !visited.contains($0) }), !directions.isEmpty else {
                return [[state]]
            }
            
            // Mark state as visited.
            var visited = visited
            visited.insert(state)
            
            // For each direction generate subtrees with direction in a root.
            return directions.reduce([[ContentLoadingState]]()) {
                $0 + routes(state: $1, visited: visited).map { [state] + $0 }
            }
        }

        // Test if state machine can transition in all states on a route.
        
        // Counting state transitions to validate callbacks.
        struct TransitionsCounter {
            
            /// Number of willTransition callbacks
            var will = 0
            
            /// Number of didTransition callbacks
            var did = 0
            
            /// Total number of transitions
            var total = 0
        }
        
        for route in routes(state: .initial) {
            
            let stateMachine = ContentLoadingStateMachine()
            
            var counter = TransitionsCounter()
        
            for state in route {
                guard state != .initial else { continue }
            
                let currentState = stateMachine.currentState
            
                stateMachine.willTransition = { to in
                    XCTAssertEqual(to, state)
                    counter.will += 1
                }
            
                stateMachine.didTransition = { from in
                    XCTAssertEqual(from, currentState)
                    counter.did += 1
                }
            
                stateMachine.currentState = state
                XCTAssertEqual(stateMachine.currentState, state)
                
                counter.total += 1
            }
        
            XCTAssertEqual(counter.will, counter.did)
            
            XCTAssertEqual(counter.will, counter.total)
            XCTAssertEqual(counter.did, counter.total)
            
            XCTAssertEqual(counter.total, route.count - 1)
        }
    }
}
