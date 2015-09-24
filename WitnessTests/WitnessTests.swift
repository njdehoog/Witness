//
//  WitnessTests.swift
//  WitnessTests
//
//  Created by Niels de Hoog on 23/09/15.
//  Copyright © 2015 Invisible Pixel. All rights reserved.
//

import XCTest
@testable import Witness

class WitnessTests: XCTestCase {
    static let expectationTimeout = 2.0
    static let latency: NSTimeInterval = 0.1
    
    let fileManager = NSFileManager()
    var witness: Witness?
  
    var temporaryDirectory: String {
        return NSTemporaryDirectory()
    }
    
    var testsDirectory: String {
        return (temporaryDirectory as NSString).stringByAppendingPathComponent("WitnessTests")
    }
    
    var filePath: String {
        return (testsDirectory as NSString).stringByAppendingPathComponent("file.txt")
    }
    
    override func setUp() {
        super.setUp()
        
        // create tests directory
        try! fileManager.createDirectoryAtPath(testsDirectory, withIntermediateDirectories: true, attributes: nil)
    }
    
    override func tearDown() {
        witness?.flush()
        witness = nil
        
        do {
            // remove tests directory
            try fileManager.removeItemAtPath(testsDirectory)
        }
        catch {}
        
        super.tearDown()
    }
    
    func waitForPendingEvents() {
        print("wait for pending changes...")

        var didArrive = false
        witness = Witness(paths: [testsDirectory], flags: [.NoDefer, .WatchRoot], latency: WitnessTests.latency) { events in
            print("pending changes arrived")
            didArrive = true
        }
        
        while !didArrive {
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0.02, true);
        }
    }
    
    func delay(interval: NSTimeInterval, block: () -> ()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
    }
    
    func testThatFileCreationIsObserved() {
        var expectation: XCTestExpectation? = expectationWithDescription("File creation should trigger event")
        witness = Witness(paths: [testsDirectory]) { events in
            for event in events {
                if event.flags.contains(.ItemCreated) {
                    expectation?.fulfill()
                    expectation = nil
                }
            }
        }
        fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        waitForExpectationsWithTimeout(WitnessTests.expectationTimeout, handler: nil)
    }
    
    func testThatFileRemovalIsObserved() {
        let expectation = expectationWithDescription("File removal should trigger event")
        fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        waitForPendingEvents()
        witness = Witness(paths: [testsDirectory]) { events in
            expectation.fulfill()
        }
        try! fileManager.removeItemAtPath(filePath)
        waitForExpectationsWithTimeout(WitnessTests.expectationTimeout, handler: nil)
    }
    
    func testThatFileChangesAreObserved() {
        let expectation = expectationWithDescription("File changes should trigger event")
        fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        waitForPendingEvents()
        witness = Witness(paths: [testsDirectory]) { events in
            expectation.fulfill()
        }
        try! "Hello changes".writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        waitForExpectationsWithTimeout(WitnessTests.expectationTimeout, handler: nil)
    }
    
    func testThatRootDirectoryIsNotObserved() {
        let expectation = expectationWithDescription("Removing root directory should not trigger event if .WatchRoot flag is not set")
        var didReceiveEvent = false
        witness = Witness(paths: [testsDirectory], flags: .NoDefer) { events in
            didReceiveEvent = true
        }
        
        delay(WitnessTests.latency * 2) {
            if didReceiveEvent == false {
                expectation.fulfill()
            }
        }

        try! fileManager.removeItemAtPath(testsDirectory)
        waitForExpectationsWithTimeout(WitnessTests.expectationTimeout, handler: nil)
    }
    
    func testThatRootDirectoryIsObserved() {
        let expectation = expectationWithDescription("Removing root directory should trigger event if .WatchRoot flag is set")
        witness = Witness(paths: [testsDirectory], flags: .WatchRoot) { events in
            expectation.fulfill()
        }
        try! fileManager.removeItemAtPath(testsDirectory)
        waitForExpectationsWithTimeout(WitnessTests.expectationTimeout, handler: nil)
    }

}
