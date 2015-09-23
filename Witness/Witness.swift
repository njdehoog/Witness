//
//  Witness.swift
//  Witness
//
//  Created by Niels de Hoog on 23/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

public typealias WitnessEventHandler = () -> ()

public struct Witness {
    let paths: [String]
    let changeHandler: WitnessEventHandler
    private let stream: EventStream
    
    public init(paths: [String], changeHandler: WitnessEventHandler) {
        self.paths = paths
        self.changeHandler = changeHandler
        
        self.stream = EventStream(paths: paths, changeHandler: changeHandler)
    }
    
    public init(paths: [String], streamType: StreamType, deviceToWatch: dev_t,  changeHandler: WitnessEventHandler) {
        self.paths = paths
        self.changeHandler = changeHandler
        
        self.stream = EventStream(paths: paths, type: streamType, deviceToWatch: deviceToWatch, changeHandler: changeHandler)
    }
    
    public func flush() {
        self.stream.flush()
    }
}

/**
* The type of event stream to be used. For more information, please refer to the File System Events Programming Guide: https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html#//apple_ref/doc/uid/TP40005289-CH4-SW6
*/

public enum StreamType {
    case HostBased // default
    case DiskBased
}

private class EventStream {
    // use explicitly unwrapped optional so we can pass self as context to stream
    private var stream: FSEventStreamRef!
    private let changeHandler: WitnessEventHandler
    static let latency = 1.0
    
    init(paths: [String], type: StreamType = .HostBased, deviceToWatch: dev_t = 0, changeHandler: WitnessEventHandler) {
        self.changeHandler = changeHandler
        
        func callBack (stream: ConstFSEventStreamRef, clientCallbackInfo: UnsafeMutablePointer<Void>, numEvents: Int, eventPaths: UnsafeMutablePointer<Void>, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIDs: UnsafePointer<FSEventStreamEventId>) -> Void {
            let eventStream = unsafeBitCast(clientCallbackInfo, EventStream.self)
            eventStream.changeHandler()
        }
        
        var context = FSEventStreamContext()
        context.info = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        
        switch type {
        case .HostBased:
            stream = FSEventStreamCreate(nil, callBack, &context, paths, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), EventStream.latency, FSEventStreamCreateFlags(kFSEventStreamCreateFlagNone))
        case .DiskBased:
            stream = FSEventStreamCreateRelativeToDevice(nil, callBack, &context, deviceToWatch, paths, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), EventStream.latency, FSEventStreamCreateFlags(kFSEventStreamCreateFlagNone))
        }
        
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
        FSEventStreamStart(stream)
    }
    
    func flush() {
        FSEventStreamFlushSync(stream)
    }
    
    deinit {
        // stop stream
        FSEventStreamStop(stream)
        
        // unschedule from all run loops
        FSEventStreamInvalidate(stream)
        
        // release
        FSEventStreamRelease(stream)
    }
}




