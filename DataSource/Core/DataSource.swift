//
//  DataSource.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 09/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/** The `DataSource` is an abstract base class for creating data sources.

    Base class implements updates functionality.
*/
open class DataSource : NSObject, UpdateObservable {

    /** Computed property that determines if an update should be postponed for future.

        Common reason for delaying an update is content loading process. If update is notified when loading is in progress, such update is postponed till loading completes.

        Base implementation returns true if the data source is loading content.
    */
    open var shouldPostponeUpdate: Bool {
        
        if let contentLoading = self as? ContentLoading {
            return contentLoading.loadingState.isLoading
        }
        
        return false
    }
    
    /// Postpones the update.
    public final func enqueueUpdate(_ update: Update) {
        
        let batchUpdate = BatchUpdate()
        
        if let pendingUpdate = self.pendingUpdate {
            batchUpdate.enqueueUpdate(pendingUpdate)
        }

        batchUpdate.enqueueUpdate(update)
        self.pendingUpdate = batchUpdate
    }
    
    /// Notifies observer about pending update.
    public final func performPendingUpdate() {
        guard let update = pendingUpdate else { return }
        pendingUpdate = nil
        notifyUpdate(update)
    }
    
    private var pendingUpdate: Update?

    // MARK: - UpdateObservable

    public weak var updateObserver: UpdateObserver?

    public final func notifyUpdate(_ update: Update) {

        assertMainThread()

        if shouldPostponeUpdate {
            enqueueUpdate(update)
        }
        else {
            updateObserver?.perform(update: update, from: self)
        }
    }
}
