//
//  ContentLoadingStateMachine.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 21/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public class ContentLoadingStateMachine {

    public var willTransition: ((to: ContentLoadingState) -> Void)?
    
    public var didTransition: ((from: ContentLoadingState) -> Void)?
    
    public enum Error: ErrorProtocol {
        case illegalStateTransition(from: ContentLoadingState, to: ContentLoadingState)
    }

    public let transitions: [ContentLoadingState : [ContentLoadingState]] = [

        .initial : [
            .loadingContent
        ],
        
        .loadingContent : [
            .contentLoaded,
            .noContent,
            .error
        ],

        .contentLoaded : [
            .noContent,
            .error
        ],
        
        .noContent : [
            .contentLoaded,
            .error
        ],
        
        .error : [
            .loadingContent,
            .noContent,
            .contentLoaded
        ]
    ]

    private let lock = Lock()
    
    private var _currentState: ContentLoadingState = .initial
    
    public var currentState: ContentLoadingState {
        get {
            defer {
                lock.unlock()
            }
        
            lock.lock()
            return _currentState
        }
        
        set {
            let from = currentState
            let to: ContentLoadingState

            do {
                if let validState = try validateTransition(from: from, to: newValue) {
                    to = validState
                }
                else {
                    return
                }
            }
            catch {
                assertionFailure("IllegalStateTransition: cannot transition from \(from) to \(newValue)")
                return
            }

            willTransition?(to: to)
            
            lock.lock()
            _currentState = to
            lock.unlock()
            
            didTransition?(from: from)
        }
    }
    
    private func validateTransition(from: ContentLoadingState, to: ContentLoadingState) throws -> ContentLoadingState? {
        guard from != to else { return nil }
        
        guard let transitions = self.transitions[from], transitions.contains(to) else {
            throw Error.illegalStateTransition(from: from, to: to)
        }
        
        return to
    }
}
