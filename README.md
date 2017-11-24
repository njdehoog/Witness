# Witness
Monitor file system changes using Swift. Witness provides a wrapper around the [File System Events](https://developer.apple.com/library/mac/documentation/Darwin/Conceptual/FSEvents_ProgGuide/Introduction/Introduction.html) API for OS X.

## Installation

The recommended way to include Witness in your project is by using [Carthage](https://github.com/Carthage/Carthage). Simply add this line to your `Cartfile`:

    github "njdehoog/Witness" ~> 0.1

## Usage

Import the framework
```swift
import Witness
```

### Monitor file system events

This will trigger an event when a file in the Desktop directory is created, deleted or modified.
```swift
if let desktopPath = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true).first {
    self.witness = Witness(paths: [desktopPath], flags: .FileEvents, latency: 0.3) { events in
        print("file system events received: \(events)")
    }
}
```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Credits

Witness was developed for use in [Spelt](http://spelt.io). If you like this library, please consider supporting development by purchasing the app.

## License

Witness is released under the MIT license. See LICENSE for details.
