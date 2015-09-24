//
//  Witness.swift
//  Witness
//
//  Created by Niels de Hoog on 23/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

public typealias FileEventHandler = (events: [FileEvent]) -> ()

public struct Witness {
    let paths: [String]
    let changeHandler: FileEventHandler
    private let stream: EventStream
    
    public init(paths: [String], changeHandler: FileEventHandler) {
        self.paths = paths
        self.changeHandler = changeHandler
        
        self.stream = EventStream(paths: paths, changeHandler: changeHandler)
    }
    
    public init(paths: [String], streamType: StreamType, deviceToWatch: dev_t,  changeHandler: FileEventHandler) {
        self.paths = paths
        self.changeHandler = changeHandler
        
        self.stream = EventStream(paths: paths, type: streamType, deviceToWatch: deviceToWatch, changeHandler: changeHandler)
    }
    
    public func flush() {
        self.stream.flush()
    }
}

