//
//  ContentLoadingDataSource.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 10/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/** The `ContentLoadingDataSource` is an abstract base class for creating data sources that load content.

    Base class implements content loading functionality.
*/
open class ContentLoadingDataSource : DataSource, ContentLoading, ContentLoadingControllerDelegate {
    
    // MARK: - ContentLoadingObservable
    
    public weak var contentLoadingObserver: ContentLoadingObserver?
    
    // MARK: - ContentLoading

    private var _contentLoadingController: ContentLoadingController?
    
    public var contentLoadingController: ContentLoadingController {
        if nil == _contentLoadingController {
            _contentLoadingController = ContentLoadingController()
            _contentLoadingController?.delegate = self
        }

        return _contentLoadingController!
    }

    private var _loadingState: ContentLoadingState?
    
    public var loadingState: ContentLoadingState {
        
        // Do not create content loading controller only for state introspection
        if nil == _contentLoadingController {
            
            // Data source may be in a loading state from previous content loading operation
            if let loadingState = _loadingState {
                return loadingState
            }
            
            return .initial
        }
        
        return contentLoadingController.loadingState
    }
    
    private var _loadingError: Error?
    
    public var loadingError: Error? {
        return _loadingError
    }
    
    open func loadContent() {
    }
    
    // MARK: - ContentLoadingControllerDelegate

    public func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController) {
        contentLoadingObserver?.willLoadContent(self)
    }
    
    public func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: @escaping () -> Void) {

        _loadingState = _contentLoadingController?.loadingState
        _loadingError = _contentLoadingController?.loadingError
        
        _contentLoadingController = nil
        
        enqueueUpdate(ArbitraryUpdate(update))
        performPendingUpdate()
        
        contentLoadingObserver?.didLoadContent(self, with: controller.loadingError)
    }
}
