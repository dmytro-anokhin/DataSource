//
//  TableViewDataSource.swift
//
//  Created by Dmytro Anokhin on 24/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


public class TableViewDataSource: NSObject, TableViewDataSourceType, TableViewReusableViewsRegistering,
    UpdateObservable, ContentLoading, ContentLoadingControllerDelegate {

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

    // MARK: - Data Source

    public func object(at indexPath: IndexPath) -> Any? {
        return nil
    }
    
    public func indexPaths(for object: Any) -> [IndexPath] {
        return []
    }
    
    // MARK: - TableViewReusableViewsRegistering
    
    public func registerReusableViews(with tableView: UITableView) {
    }
    
    // MARK: - ContentLoading
    
    public var loadingState: ContentLoadingState {
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
