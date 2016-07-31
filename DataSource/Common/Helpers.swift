//
//  Helpers.swift
//
//  Created by Dmytro Anokhin on 24/06/15.
//  Copyright © 2015 danokhin. All rights reserved.
//

import Foundation

func assertMainThread() {
    assert(Thread.isMainThread, "This routine must be executed on the main thread")
}
