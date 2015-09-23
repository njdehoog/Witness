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
    let timeout = 3.0
    
    var desktopPath: String {
        // TODO: change to some kind of temp directory
        return ("~/Desktop" as NSString).stringByExpandingTildeInPath
    }
    
    var filePath: String {
        return (desktopPath as NSString).stringByAppendingPathComponent("file.temp")
    }
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        try! self.fileManager.removeItemAtPath(filePath)
        super.tearDown()
    }
    
    func testCreateWitness() {
        let expectation = expectationWithDescription("Directory change")
        
        witness = Witness(paths: [desktopPath]) {
            print("directory changed")
            expectation.fulfill()
        }
        witness?.start()
        
        try! "".writeToFile(filePath, atomically: true, encoding: NSUTF8StringEncoding)
        
        waitForExpectationsWithTimeout(timeout, handler: nil)
    }
}
