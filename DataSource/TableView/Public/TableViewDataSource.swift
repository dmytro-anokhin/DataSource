//
//  TableViewDataSource.swift
//
//  Created by Dmytro Anokhin on 24/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


public class TableViewDataSource: NSObject, TableViewDataSourceType, UpdateObservable,
    ContentLoading, ContentLoadingControllerDelegate {

    // MARK: - Public
    
    private var _contentLoadingController: ContentLoadingController?
    
    public var contentLoadingController: ContentLoadingController {
        if nil == _contentLoadingController {
            _contentLoadingController = ContentLoadingController()
            _contentLoadingController?.delegate = self
        }

        return _contentLoadingController!
    }
    
    // MARK: - TableViewDataSourceType

    public var numberOfSections: Int {
        return 1
    }

    // MARK: - ContentLoading
    
    private var _loadingState: ContentLoadingState?
    
    public var loadingState: ContentLoadingState {
        
        // Do not create content loading controller only for introspection
        if nil == _contentLoadingController {
            
            // Data source may be in a loading state from previous content loading operation
            if let loadingState = _loadingState {
                return loadingState
            }
            
            return .initial
        }
        
        return contentLoadingController.loadingState
    }
    
    public func loadContent() {
    }
    
    // MARK: - ContentLoadingObservable
    
    public weak var contentLoadingObserver: ContentLoadingObserver?
    
    // MARK: - ContentLoadingControllerDelegate

    public func contentLoadingControllerWillBeginLoading(_ controller: ContentLoadingController) {
        contentLoadingObserver?.willLoadContent(self)
    }
    
    public func contentLoadingController(_ controller: ContentLoadingController, didFinishLoadingWithUpdate update: () -> Void) {
        notify(update: .arbitraryUpdate(update))
        contentLoadingObserver?.didLoadContent(self, with: controller.loadingError)
        
        _loadingState = _contentLoadingController?.loadingState
        _contentLoadingController = nil
    }
    
    // MARK: - UpdateObservable
    
    public weak var updateObserver: UpdateObserver?

    public func notify(update: Update) {

        assertMainThread()

        switch loadingState {
            case .loadingContent:
            
                let batchUpdate = BatchUpdate()
        
                if let pendingUpdate = self.pendingUpdate {
                    batchUpdate.enqueueUpdate(pendingUpdate)
                }

                batchUpdate.enqueueUpdate(update)
                self.pendingUpdate = batchUpdate

            default:
                updateObserver?.perform(update: update, from: self)
        }
    }
    
    // MARK: - Private
    
    private var pendingUpdate: Update?
    
    // MARK: - UITableViewDataSource
    
    // required
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Not implemented")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Not implemented")
    }
    
    // optional
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
}
