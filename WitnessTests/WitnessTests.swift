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
    let fileManager = NSFileManager()
    var witness: Witness?
    let timeout = 2.0
    
    var temporaryDirectory: String {
        return NSTemporaryDirectory()
    }
    
    var testsDirectory: String {
        return (temporaryDirectory as NSString).stringByAppendingPathComponent("WitnessTests")
    }
    
    var filePath: String {
        return (testsDirectory as NSString).stringByAppendingPathComponent("file.temp")
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
    
    func testThatFileCreationIsObserved() {
        let expectation = expectationWithDescription("File creation")
        witness = Witness(paths: [testsDirectory]) {
            expectation.fulfill()
        }
        fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testThatFileRemovalIsObserved() {
        let expectation = expectationWithDescription("File removal")
        fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        sleep(1)
        witness = Witness(paths: [testsDirectory]) {
            expectation.fulfill()
        }
        try! fileManager.removeItemAtPath(filePath)
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
    
    func testThatFileChangesAreObserved() {
        let expectation = expectationWithDescription("File changes")
        fileManager.createFileAtPath(filePath, contents: nil, attributes: nil)
        sleep(1)
        witness = Witness(paths: [testsDirectory]) {
            expectation.fulfill()
        }
        try! "Hello changes".writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
}
