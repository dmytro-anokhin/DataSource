//
//  ContentLoadingObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 28/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

import Foundation


public protocol ContentLoadingObservable : class {
    
    weak var contentLoadingObserver: ContentLoadingObserver? { get set }
}


public protocol ContentLoadingObserver : class {

    func willLoadContent(_ sender: ContentLoadingObservable)
    
    func didLoadContent(_ sender: ContentLoadingObservable, with error: NSError?)
}
