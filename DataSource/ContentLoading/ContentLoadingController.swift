//
//  ContentLoadingController.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 20/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


public protocol ContentLoadingControllerDelegate : class {

    func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController)
    
    func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: () -> Void)
}


public class ContentLoadingController {

    // MARK: - Public

    weak var delegate: ContentLoadingControllerDelegate?
    
    public var loadingState: ContentLoadingState {
        if let stateMachine = stateMachine {
            return stateMachine.currentState
        }
        
        return .initial
    }

    public var loadingError: NSError?
    
    public func loadContent(_ closure: (helper: ContentLoadingHelper) -> Void) {
    
        assertMainThread()
    
        // Begin loading
        beginLoading()
        
        // Replace current loading helper with new one
        currentLoadingHelper = ContentLoadingHelper { state, error, update in
            guard let state = state else { return } // Ignore

            self.endLoading(state, error: error) {
                update?()
            }
        }
        
        // Execute loading closure
        closure(helper: currentLoadingHelper!)
    }
    
    // MARK: - Private
    
    private var stateMachine: ContentLoadingStateMachine?
    
    private var currentLoadingHelper: ContentLoadingHelper? {
        willSet {
            currentLoadingHelper?.current = false
        }
    }

    private func updateLoadingState(_ state: ContentLoadingState) {
        if nil == stateMachine {
            stateMachine = ContentLoadingStateMachine()
        }
        
        stateMachine?.currentState = state
    }
    
    private func beginLoading() {
        updateLoadingState(.loadingContent)
        delegate?.contentLoadingControllerWillBeginLoading(self)
    }
    
    private func endLoading(_ state: ContentLoadingState, error: NSError?, update: () -> Void) {
        
        assertMainThread()

        loadingError = error
        updateLoadingState(state)
        
        delegate?.contentLoadingController(self, didFinishLoadingWithUpdate: update)
    }
}
