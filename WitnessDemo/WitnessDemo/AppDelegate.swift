//
//  AppDelegate.swift
//  WitnessDemo
//
//  Created by Niels de Hoog on 07/06/16.
//  Copyright © 2016 Invisible Pixel. All rights reserved.
//

import Cocoa
import Witness

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    var witness: Witness?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first {
            self.witness = Witness(paths: [desktopPath], flags: .FileEvents, latency: 0.3) { events in
                // create/delete or modify a file on the Desktop to see this event triggered
                print("file system events received: \(events)")
            }
        }
    }
}

