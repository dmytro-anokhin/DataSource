//
//  TableViewDataSourceComposition.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 10/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


class TableViewDataSourceComposition : Composable {
    
    // MARK: - Composable
    
    typealias Child = TableViewDataSourceType
    
    func add(_ dataSource: Child) -> Bool {
        
        guard nil == dataSourceToMappings.object(forKey: dataSource) else {
            assertionFailure("Tried to add data source more than once: \(dataSource)")
            return false
        }
    
        let mapping = ComposedTableViewMapping(dataSource: dataSource)
        mappings.append(mapping)
        dataSourceToMappings.setObject(mapping, forKey: dataSource)
        
        return true
    }
    
    func remove(_ dataSource: Child) -> Bool {
        
        guard let mapping = dataSourceToMappings.object(forKey: dataSource),
              let index = mappings.index(where: { $0 === mapping })
        else {
            assertionFailure("Data source not found in mapping: \(dataSource)")
            return false
        }
    
        dataSourceToMappings.removeObject(forKey: dataSource)
        mappings.remove(at: index)
        
        return true
    }
    
    var children: [Child] {
        return mappings.map { $0.dataSource }
    }
    
    // MARK: - General
    
    private(set) var mappings: [ComposedTableViewMapping] = []
    
    private(set) var dataSourceToMappings = NSMapTable<AnyObject, ComposedTableViewMapping>(
        keyOptions: .objectPointerPersonality, valueOptions: NSPointerFunctions.Options(), capacity: 1)

    private(set) var globalSectionToMappings: [Int: ComposedTableViewMapping] = [:]
    
    /// Updates map of table view sections to data sources. Returns number of global sections.
    func updateMappings() -> Int {
        var numberOfSections = 0
        globalSectionToMappings.removeAll()
        
        for mapping in mappings {
            let newNumberOfSections = mapping.updateMappings(startingWith: numberOfSections)
            while numberOfSections < newNumberOfSections {
                globalSectionToMappings[numberOfSections] = mapping
                numberOfSections += 1
            }
        }
        
        return numberOfSections
    }

    func sections(for dataSource: Child) -> IndexSet {
    
        let mapping = self.mapping(for: dataSource)
        let sections = NSMutableIndexSet()
        
        if 0 == dataSource.numberOfSections {
            return sections as IndexSet
        }
        
        for section in 0..<dataSource.numberOfSections {
            if let globalSection = mapping.globalSection(for: section) {
                sections.add(globalSection)
            }
        }
        
        return sections as IndexSet
    }
    
    func section(for dataSource: Child) -> Int? {
        return mapping(for: dataSource).globalSection(for: 0)
    }
    
    func localIndexPath(for globalIndexPath: IndexPath) -> IndexPath? {
        return mapping(for: globalIndexPath.section)?.localIndexPath(for: globalIndexPath)
    }
    
    func mapping(for section: Int) -> ComposedTableViewMapping? {
        return globalSectionToMappings[section]
    }

    func mapping(for dataSource: Child) -> ComposedTableViewMapping {
    
        guard let mapping = dataSourceToMappings.object(forKey: dataSource) else {
            fatalError("Mapping for data source not found: \(dataSource)")
        }
        
        return mapping
    }
    
    func globalSections(for localSections: IndexSet, in dataSource: Child) -> IndexSet {

        let mapping = self.mapping(for: dataSource)
        return mapping.globalSections(for: localSections)
    }
    
    func globalIndexPaths(for localIndexPaths: [IndexPath], in dataSource: Child) -> [IndexPath] {
        let mapping = self.mapping(for: dataSource)
        return localIndexPaths.flatMap { mapping.globalIndexPath(for: $0) }
    }
    
    // MARK: - Convenience methods
    
    /// Returns local objects for section in table view
    func local(forSection section: Int, in tableView: UITableView) -> (dataSource: Child, tableView: UITableView, section: Int) {
        
        guard let mapping = self.mapping(for: section) else {
            fatalError("Mapping for section not found: \(section)")
        }
        
        guard let localSection = mapping.localSection(for: section) else {
            fatalError("Local section for section not found: \(section)")
        }
        
        let wrapper = ComposedTableViewWrapper.wrapper(for: tableView, mapping: mapping)
        let dataSource = mapping.dataSource
        
        return (dataSource, wrapper, localSection)
    }
    
    /// Returns local objects for index path in table view
    func local(forIndexPath indexPath: IndexPath, in tableView: UITableView) -> (dataSource: Child, tableView: UITableView, indexPath: IndexPath) {
        
        guard let mapping = self.mapping(for: indexPath.section) else {
            fatalError("Mapping for index path not found: \(indexPath)")
        }
        
        guard let localIndexPath = mapping.localIndexPath(for: indexPath) else {
            fatalError("Local index path for index path not found: \(indexPath)")
        }
        
        let wrapper = ComposedTableViewWrapper.wrapper(for: tableView, mapping: mapping)
        let dataSource = mapping.dataSource
        
        return (dataSource, wrapper, localIndexPath)
    }
}
