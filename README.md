<p align="center">
    <img src="Logo.png" width="500" max-width="90%" alt="Sweep" />
</p>
<p align="center">
    <img src="https://img.shields.io/badge/Swift-6.2-orange.svg" />
    <a href="https://swift.org/package-manager">
        <img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" />
    </a>
    <img src="https://img.shields.io/badge/platforms-mac+linux-brightgreen.svg?style=flat" alt="Mac + Linux" />
    <a href="https://x.com/alan_deguzman">
        <img src="https://img.shields.io/badge/twitter-@alan_deguzman-blue.svg?style=flat" alt="Twitter: @alan_deguzman" />
    </a>
</p>

Welcome to **Sweep** — a powerful and fast, yet easy to use, Swift string scanning library. Scan any string for substrings appearing between two sets of characters — for example to parse out identifiers or metadata from a string of user-defined text.

Sweep can be dropped into a project as a general-purpose string scanning algorithm, or act as the base for custom, more high-level scanning implementations. It aims to complement the Swift standard library’s built-in string handling APIs, both in terms of its design, and also how its implemented in an efficient way in line with Swift’s various string conventions.

## Examples

The easiest way to start using Sweep is to call the `substrings` method that it adds on top of `StringProtocol` — meaning that you can use it on both “normal” strings and `Substring` values.

Here’s an example in which we scan a string for HTML tags, and both identify the names of all tags that appear in the string, and also any text that should be rendered in bold:

```swift
import Sweep

let html = "<p>Hello, <b>this is bold</b>, right?</p>"
let tags = html.substrings(between: "<", and: ">")
print(tags) // ["p", "b", "/b", "/p"]

let boldText = html.substrings(between: "<b>", and: "</b>")
print(boldText) // ["this is bold"]
```

Sweep can also scan for different patterns, such as a prefix appearing at the start of the scanned string, or its end. Here we’re using those capabilities to identify headings in a string of Markdown-formatted text:

```swift
import Sweep

let markdown = """
## Section 1

Text

## Section 2
"""

let headings = markdown.substrings(between: [.prefix("## "), "\n## "],
                                   and: [.end, "\n"])

print(headings) // ["Section 1", "Section 2"]
```

Since Sweep was designed to fit right in alongside Swift’s built-in string APIs, it lets us compose more powerful string scanning algorithms using both built-in functionality and the APIs that Sweep adds — such as here where we’re parsing out an array of tags from a string written using a custom syntax:

```swift
import Sweep

let text = "{{tags: swift, programming, xcode}}"
let tagStrings = text.substrings(between: "{{tags: ", and: "}}")
let tags = tagStrings.flatMap { $0.components(separatedBy: ", ") }
print(tags) // ["swift", "programming", "xcode"]
```

Sweep was also designed to be highly efficient, and only makes a single pass through each string that it scans — regardless of how many different patterns you wish to scan for. In this example, we’re using two custom matchers to parse two pieces of metadata from a string:

```swift
import Sweep

let text = """
url: https://www.ay-nako.net/who/aland/
title: Alan's Homepage
"""

var urls = [URL]()
var titles = [String]()

text.scan(using: [
    Matcher(identifiers: ["url: "], terminators: ["\n", .end]) { match, range in
        let string = String(match)
        let url = URL(string: string)
        url.flatMap { urls.append($0) }
    },
    Matcher(identifiers: ["title: "], terminators: ["\n", .end]) { match, range in
        let string = String(match)
        titles.append(string)
    }
])

print(urls) // [https://www.ay-nako.net/who/aland/]
print(titles) // ["Alan's Homepage"]
```

Sweep is not only efficient in terms of complexity, it also has a very low memory overhead, thanks to it being built according to Swift’s modern string conventions — making full use of types like `Substring` and `String.Index`, and avoiding unnecessary copying and mutations when performing its scanning.

## Installation

Sweep is distributed as a Swift package, and it’s recommended to install it using [the Swift Package Manager](https://github.com/apple/swift-package-manager), by declaring it as a dependency in your project’s `Package.swift` file:

```
.package(url: "https://github.com/alandeguz/Sweep", from: "0.5.0")
```

For more information, please see the [Swift Package Manager documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).


Hope you enjoy using Sweep! 😀
