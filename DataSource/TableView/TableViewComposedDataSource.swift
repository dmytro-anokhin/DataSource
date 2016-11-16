//
//  TableViewComposedDataSource.swift
//
//  Created by Dmytro Anokhin on 25/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//


open class TableViewComposedDataSource : DataSource, Composition, TableViewDataSourceType,
    IndexPathIndexable, TableViewReusableViewsRegistering, ContentLoading,
    UpdateObserver, ContentLoadingObserver, ContentLoadingObservable {
    
    // MARK: - Composition

    public typealias Child = TableViewDataSourceType

    @discardableResult
    public final func add(_ dataSource: Child) -> Bool {
    
        assertMainThread()

        guard composition.add(dataSource) else {
            return false
        }

        (dataSource as? UpdateObservable)?.updateObserver = self
        (dataSource as? ContentLoadingObservable)?.contentLoadingObserver = self

        _numberOfSections = composition.updateMappings()
        
        let sections = composition.sections(for: dataSource)
        let update = TableViewSectionsUpdate(insert: sections)
        notifyUpdate(update)
        
        return true
    }
    
    @discardableResult
    public final func remove(_ dataSource: Child)  -> Bool {
    
        assertMainThread()
        
        let sections = composition.sections(for: dataSource)
        
        guard composition.remove(dataSource) else {
            return false
        }

        (dataSource as? UpdateObservable)?.updateObserver = nil
        (dataSource as? ContentLoadingObservable)?.contentLoadingObserver = nil
        
        _numberOfSections = composition.updateMappings()

        let update = TableViewSectionsUpdate(delete: sections)
        notifyUpdate(update)
        
        return true
    }
    
    public final var children: [Child] {
        return composition.children
    }
    
    // MARK: - TableViewDataSourceType

    private var _numberOfSections: Int = 0
    
    public final var numberOfSections: Int {
        _numberOfSections = composition.updateMappings()
        return _numberOfSections
    }
    
    // MARK: - IndexPathIndexable
    
    public final func object(at indexPath: IndexPath) -> Any? {
        
        guard let mapping = composition.mapping(for: indexPath.section),
              let localIndexPath = mapping.localIndexPath(for: indexPath)
        else {
            return nil
        }
        
        return (mapping.dataSource as? IndexPathIndexable)?.object(at: localIndexPath)
    }
    
    public final func indexPaths(for object: Any) -> [IndexPath] {
        
        return children.reduce([]) { indexPaths, dataSource in
            let mapping = composition.mapping(for: dataSource)
            let localIndexPaths = (mapping.dataSource as? IndexPathIndexable)?.indexPaths(for: object) ?? []
            
            return indexPaths + localIndexPaths.flatMap { mapping.globalIndexPath(for: $0) }
        }
    }
    
    // MARK: - ContentLoading

    public var loadingError: Error? { return nil }

    // MARK: - UpdateObserver
    
    public final func perform(update: UpdateType, from sender: UpdateObservable) {
        
        guard let dataSource = sender as? TableViewDataSourceType else { return }

        if let rowsUpdate = update as? TableViewRowsUpdate {

            let mapping = composition.mapping(for: dataSource)

            guard let globalUpdate = TableViewRowsUpdate(

                changeType: rowsUpdate.changeType,

                indexPaths: {
                    // Map local index paths to global
                    guard let indexPaths = rowsUpdate.elements else { return nil }
                    return mapping.globalIndexPaths(for: indexPaths)
                }(),

                newIndexPaths: {
                    // Map local index path to global
                    guard let newIndexPaths = rowsUpdate.newElements else { return nil }
                    return mapping.globalIndexPaths(for: newIndexPaths)
                }(),

                animation: rowsUpdate.animation
            )
            else {
                return
            }

            notifyUpdate(globalUpdate)
            return
        }

        if let sectionsUpdate = update as? TableViewSectionsUpdate {

            let mapping = composition.mapping(for: dataSource)

            guard let globalUpdate = TableViewSectionsUpdate(

                changeType: sectionsUpdate.changeType,

                sections: {

                    guard let sections = sectionsUpdate.elements else { return nil }
                    
                    switch sectionsUpdate.changeType {
                        case .insert:
                            // Map local sections to global after mappings update
                            _numberOfSections = composition.updateMappings()
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
                    guard let newSections = sectionsUpdate.newElements else { return nil }
                    _numberOfSections = composition.updateMappings()
                    let globalNewSection = mapping.globalSections(for: newSections)

                    return globalNewSection
                }(),

                animation: sectionsUpdate.animation
            )
            else {
                return
            }

            notifyUpdate(globalUpdate)
            return
        }

        _numberOfSections = composition.updateMappings()
        notifyUpdate(update)
    }
    
    // MARK: - ContentLoadingObservable
    
    public weak var contentLoadingObserver: ContentLoadingObserver?
    
    // MARK: - ContentLoadingObserver
    
    public func willLoadContent(_ sender: ContentLoadingObservable) {
    }

    public func didLoadContent(_ sender: ContentLoadingObservable, with error: Error?) {
        
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
    
    public final func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        _numberOfSections = composition.updateMappings()
        
        let local = composition.local(forSection: section, in: tableView)
        return local.dataSource.tableView(local.tableView, numberOfRowsInSection: local.section)
    }
    
    public final func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let local = composition.local(forIndexPath: indexPath, in: tableView)
        return local.dataSource.tableView(local.tableView, cellForRowAt: local.indexPath)
    }
    
    // optional
    
    public final func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    // MARK: - Private
    
    private var composition = TableViewDataSourceComposition()
}
