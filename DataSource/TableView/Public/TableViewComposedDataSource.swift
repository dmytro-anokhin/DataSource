//
//  TableViewComposedDataSource.swift
//
//  Created by Dmytro Anokhin on 25/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


public class TableViewComposedDataSource : DataSource, Composable, TableViewDataSourceType,
    IndexPathIndexable, TableViewReusableViewsRegistering, ContentLoading,
    UpdateObserver, ContentLoadingObserver, ContentLoadingObservable {
    
    // MARK: - Composable

    public typealias Child = TableViewDataSourceType

    @discardableResult
    public func add(_ dataSource: Child) -> Bool {
    
        assertMainThread()

        guard composition.add(dataSource) else {
            return false
        }

        (dataSource as? UpdateObservable)?.updateObserver = self
        (dataSource as? ContentLoadingObservable)?.contentLoadingObserver = self

        _numberOfSections = composition.updateMappings()
        
        let sections = composition.sections(for: dataSource)
        notifyUpdate(TableViewUpdate.insertSections(sections))
        
        return true
    }
    
    @discardableResult
    public func remove(_ dataSource: Child)  -> Bool {
    
        assertMainThread()
        
        let sections = composition.sections(for: dataSource)
        
        guard composition.remove(dataSource) else {
            return false
        }

        (dataSource as? UpdateObservable)?.updateObserver = nil
        (dataSource as? ContentLoadingObservable)?.contentLoadingObserver = nil
        
        _numberOfSections = composition.updateMappings()
        notifyUpdate(TableViewUpdate.deleteSections(sections))
        
        return true
    }
    
    public var children: [Child] {
        return composition.children
    }
    
    // MARK: - TableViewDataSourceType

    private var _numberOfSections: Int = 0
    
    public var numberOfSections: Int {
        _numberOfSections = composition.updateMappings()
        return _numberOfSections
    }
    
    // MARK: - IndexPathIndexable
    
    public func object(at indexPath: IndexPath) -> Any? {
        
        guard let mapping = composition.mapping(for: indexPath.section),
              let localIndexPath = mapping.localIndexPath(for: indexPath)
        else {
            return nil
        }
        
        return (mapping.dataSource as? IndexPathIndexable)?.object(at: localIndexPath)
    }
    
    public func indexPaths(for object: Any) -> [IndexPath] {
        
        return children.reduce([]) { indexPaths, dataSource in
            let mapping = composition.mapping(for: dataSource)
            let localIndexPaths = (mapping.dataSource as? IndexPathIndexable)?.indexPaths(for: object) ?? []
            
            return indexPaths + localIndexPaths.flatMap { mapping.globalIndexPath(for: $0) }
        }
    }
    
    // MARK: - ContentLoading

    public var loadingError: NSError? { return nil }

    // MARK: - UpdateObserver
    
    public func perform(update: Update, from sender: UpdateObservable) {
        
        guard let dataSource = sender as? TableViewDataSourceType else { return }
        
        if let _ = update as? TableViewBatchUpdate {
            _numberOfSections = composition.updateMappings()
            notifyUpdate(update)
            return
        }
        
        if let _ = update as? TableViewReloadDataUpdate {
            _numberOfSections = composition.updateMappings()
            notifyUpdate(update)
            return
        }
    
        guard let structureUpdate = update as? TableViewStructureUpdate else {
            notifyUpdate(update)
            return
        }
    
        let mapping = composition.mapping(for: dataSource)
        
        notifyUpdate(type(of: structureUpdate).init(type: structureUpdate.type, animation: structureUpdate.animation,
            indexPaths: {
                guard let indexPaths = structureUpdate.indexPaths else { return nil }
                // Map local index paths to global
                return mapping.globalIndexPaths(for: indexPaths)
            }(),
            newIndexPaths: {
                guard let newIndexPaths = structureUpdate.newIndexPaths else { return nil }
                // Map local index path to global
                return mapping.globalIndexPaths(for: newIndexPaths)
            }(),
            sections: {
                guard let sections = structureUpdate.sections else { return nil }
                
                switch structureUpdate.type {
                    case .insert:
                        _numberOfSections = composition.updateMappings()
                        // Map local sections to global after mappings update
                        return composition.globalSections(for: sections, in: dataSource)
                    case .delete:
                        // Map local sections to global before mappings update
                        let globalSections = composition.globalSections(for: sections, in: dataSource)
                        _numberOfSections = composition.updateMappings()
                        return globalSections
                    case .reload:
                        // Map local sections to global without mappings update
                        return composition.globalSections(for: sections, in: dataSource)
                    case .move:
                        // Map local sections to global without mappings update, mappings update must happen in newSections
                        return composition.globalSections(for: sections, in: dataSource)
                }
            }(),
            newSections: {
                guard let newSections = structureUpdate.newSections else { return nil }
                _numberOfSections = composition.updateMappings()
                let globalNewSection = mapping.globalSections(for: newSections)
                
                return globalNewSection
            }()
        ))
    }
    
    // MARK: - ContentLoadingObservable
    
    public weak var contentLoadingObserver: ContentLoadingObserver?
    
    // MARK: - ContentLoadingObserver
    
    public func willLoadContent(_ sender: ContentLoadingObservable) {
    }

    public func didLoadContent(_ sender: ContentLoadingObservable, with error: NSError?) {
        
        assertMainThread()

        guard loadingState.isLoaded else {
            return
        }
        
        if loadingState.isLoaded {
            performPendingUpdate()
            contentLoadingObserver?.didLoadContent(self, with: error)
        }
    }

    // MARK: - UITableViewDataSource
    
    // required
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        _numberOfSections = composition.updateMappings()
        
        let local = composition.local(forSection: section, in: tableView)
        return local.dataSource.tableView(local.tableView, numberOfRowsInSection: local.section)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let local = composition.local(forIndexPath: indexPath, in: tableView)
        return local.dataSource.tableView(local.tableView, cellForRowAt: local.indexPath)
    }
    
    // optional
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    // MARK: - Private
    
    private var composition = TableViewDataSourceComposition()
}
