import Foundation

var witness: Witness?

if let desktopPath = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true).first {
    witness = Witness(paths: [desktopPath], flags: .FileEvents, latency: 0.3) { events in
        // create/delete or modify a file on the Desktop to see this event triggered
        print("file system events received: \(events)")
    }
}
