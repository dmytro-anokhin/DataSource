//
//  UpdateObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 28/07/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//


/// The `UpdateObservable` protocol defines interface for delegating updates.
public protocol UpdateObservable : class {
    
    weak var updateObserver: UpdateObserver? { get set }
    
    func notifyUpdate(_ update: UpdateType)
}


/// The `UpdateObserver` protocol defines interface of delegate for updates.
public protocol UpdateObserver : class {

    func perform(update: UpdateType, from sender: UpdateObservable)
}
