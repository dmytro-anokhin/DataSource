//
//  ClosureUpdateObserver.swift
//  DataSource
//
//  Created by Dmytro Anokhin on 06/08/16.
//  Copyright © 2016 Dmytro Anokhin. All rights reserved.
//

@testable import DataSource


/// The `ClosureUpdateObserver` encapsulates `UpdateObserver` callback in a closure.
class ClosureUpdateObserver : UpdateObserver {

    var perform: ((Update, UpdateObservable) -> Void)?
    
    init(_ perform: ((Update, UpdateObservable) -> Void)?) {
        self.perform = perform
    }

    func perform(update: Update, from sender: UpdateObservable) {
        perform?(update, sender)
    }
}
