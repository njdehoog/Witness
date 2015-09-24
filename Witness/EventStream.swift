//
//  EventStream.swift
//  Witness
//
//  Created by Niels de Hoog on 23/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

/**
* The type of event stream to be used. For more information, please refer to the File System Events Programming Guide: https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html#//apple_ref/doc/uid/TP40005289-CH4-SW6
*/

public enum StreamType {
    case HostBased // default
    case DiskBased
}

class EventStream {
    let paths: [String]

    // use explicitly unwrapped optional so we can pass self as context to stream
    private var stream: FSEventStreamRef!
    private let changeHandler: FileEventHandler
    static let latency = 1.0
    
    init(paths: [String], type: StreamType = .HostBased, flags: EventStreamCreateFlags = .None, deviceToWatch: dev_t = 0, changeHandler: FileEventHandler) {
        self.paths = paths
        self.changeHandler = changeHandler
        
        func callBack (stream: ConstFSEventStreamRef, clientCallbackInfo: UnsafeMutablePointer<Void>, numEvents: Int, eventPaths: UnsafeMutablePointer<Void>, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIDs: UnsafePointer<FSEventStreamEventId>) -> Void {
            let eventStream = unsafeBitCast(clientCallbackInfo, EventStream.self)
            let paths = unsafeBitCast(eventPaths, NSArray.self)
            
            var events = [FileEvent]()
            for i in 0..<Int(numEvents) {
                let event = FileEvent(path: paths[i] as! String, flags: FileEventFlags(rawValue: eventFlags[i]))
                events.append(event)
            }
            
            eventStream.changeHandler(events: events)
        }
        
        var context = FSEventStreamContext()
        context.info = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        
        let combinedFlags = flags.union(.UseCFTypes)
        
        switch type {
        case .HostBased:
            stream = FSEventStreamCreate(nil, callBack, &context, paths, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), EventStream.latency, combinedFlags.rawValue)
        case .DiskBased:
            stream = FSEventStreamCreateRelativeToDevice(nil, callBack, &context, deviceToWatch, paths, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), EventStream.latency, combinedFlags.rawValue)
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

public struct EventStreamCreateFlags: OptionSetType {
    public let rawValue: FSEventStreamCreateFlags
    public init(rawValue: FSEventStreamCreateFlags) { self.rawValue = rawValue }
    init(_ value: Int) { self.rawValue = FSEventStreamCreateFlags(value) }
    
    public static let None = EventStreamCreateFlags(kFSEventStreamCreateFlagNone)

    // setting the UseCFTypes flag has no consequences, because Witness will always enable it
    public static let UseCFTypes = EventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes)
    public static let NoDefer = EventStreamCreateFlags(kFSEventStreamCreateFlagNoDefer)
    public static let WatchRoot = EventStreamCreateFlags(kFSEventStreamCreateFlagWatchRoot)
    public static let IgnoreSelf = EventStreamCreateFlags(kFSEventStreamCreateFlagIgnoreSelf)
    public static let FileEvents = EventStreamCreateFlags(kFSEventStreamCreateFlagFileEvents)
    public static let MarkSelf = EventStreamCreateFlags(kFSEventStreamCreateFlagMarkSelf)
}
