# KILabel

A fork of [Krelborn/KILabel](https://github.com/Krelborn/KILabel) that replaces auto link detection with swift

<img width=320 src="https://raw.github.com/Krelborn/KILabel/master/IKLabelDemoScreenshot.png" alt="KILabel Screenshot">

## Installation
<b>Manual:</b>
<pre>
Copy <i>KILabel</i> folder to your project.
</pre>

<b>Swift Package Manager:</b>

You can use [The Swift Package Manager](https://swift.org/package-manager) to install `KILabel` by adding the proper description to your `Package.swift` file:

```swift

let package = Package(
    name: "YOUR_PROJECT_NAME",
    dependencies: [
        .package(url: "https://github.com/bugkingK/KILabel.git", from: "1.0.0"),
    ]
)
```
Then run `swift build` whenever you get prepared.
