//
//  Witness.swift
//  Witness
//
//  Created by Niels de Hoog on 23/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import Foundation

public class Witness {
    let paths: [NSString]
    let changeHandler: () -> ()
    private var stream: FSEventStreamRef?
    
    deinit {
        if let stream = stream {
            // stop stream
            FSEventStreamStop(stream)
            
            // unschedule from all run loops
            FSEventStreamInvalidate(stream)
            
            // release
            FSEventStreamRelease(stream)
        }
    }
    
    public init(paths: [NSString], changeHandler: () -> ()) {
        self.paths = paths
        self.changeHandler = changeHandler
    }
    
    public func start() {
        func callBack (stream: ConstFSEventStreamRef, clientCallbackInfo: UnsafeMutablePointer<Void>, numEvents: Int, eventPaths: UnsafeMutablePointer<Void>, eventFlags: UnsafePointer<FSEventStreamEventFlags>, eventIDs: UnsafePointer<FSEventStreamEventId>) -> Void {
            let witness: Witness = unsafeBitCast(clientCallbackInfo, Witness.self)
            witness.changeHandler()
        }
        
        var context = FSEventStreamContext()
        context.info = unsafeBitCast(self, UnsafeMutablePointer<Void>.self)
        
        let stream = FSEventStreamCreate(nil, callBack, &context, paths, FSEventStreamEventId(kFSEventStreamEventIdSinceNow), 1.0, FSEventStreamCreateFlags(kFSEventStreamCreateFlagNone))
        FSEventStreamScheduleWithRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)
        FSEventStreamStart(stream)
        self.stream = stream
    }
}

/**
* The type of event stream to be used. For more information, please refer to the File System Events Programming Guide: https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/FSEvents_ProgGuide/UsingtheFSEventsFramework/UsingtheFSEventsFramework.html#//apple_ref/doc/uid/TP40005289-CH4-SW6
*/

public enum StreamType {
    case HostBased
    case DiskBased
}

class CallbackProxy {
    func helloWorld() {
        print("Hello world. This is a proxy object")
    }
}

class EventStream {
    
}