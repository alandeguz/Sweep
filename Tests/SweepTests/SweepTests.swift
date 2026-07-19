/**
 *  Sweep
 *  Copyright (c) John Sundell 2019
 *  Licensed under the MIT license (see LICENSE.md)
 */

import Testing
import Sweep

struct SweepTests {
    @Test func `Basic scanning`() {
        let string = "Some text <Scanned> some other text."
        let matches = string.substrings(between: "<", and: ">")
        #expect(matches == ["Scanned"])
    }

    @Test func `Matching start of string`() {
        let string = "<Scanned> Some text."
        let matches = string.substrings(between: "<", and: ">")
        #expect(matches == ["Scanned"])
    }

    @Test func `Matching start of string with a start identifier`() {
        let string = "<Scanned> Some text."
        let matches = string.substrings(between: .start, and: ">")
        #expect(matches == ["<Scanned"])
    }

    @Test func `Matching end of string`() {
        let string = "Some text <Scanned>"
        let matches = string.substrings(between: "<", and: ">")
        #expect(matches == ["Scanned"])
    }

    @Test func `Matching end of string with an end terminator`() {
        let string = "Some text <Scanned>"
        let matches = string.substrings(between: "<", and: .end)
        #expect(matches == ["Scanned>"])
    }

    @Test func `Matching multiple segments`() {
        let string = "Some text <First> some other text <Second>."
        let matches = string.substrings(between: "<", and: ">")
        #expect(matches == ["First", "Second"])
    }

    @Test func `Matching back-to-back segments`() {
        let string = "Some text |First|Second| some other text."
        let matches = string.substrings(between: "|", and: "|")
        #expect(matches == ["First", "Second"])
    }

    @Test func `Multiple identifiers and terminators`() {
        let string = "Some text <First> some other text -[Second]-"
        let matches = string.substrings(between: ["<", "-["], and: [">", "]-"])
        #expect(matches == ["First", "Second"])
    }

    @Test func `Ignoring nested identifier`() {
        let string = "Some text <Par<Nested>sed> some other text."
        let matches = string.substrings(between: "<", and: ">")
        #expect(matches == ["Par<Nested"])
    }

    @Test func `Multiple nested identifiers`() {
        let string = "Some text <Par{First}<Second>sed> some other text."
        let matches = string.substrings(between: ["<", "{"], and: [">", "}"])
        #expect(matches == ["Par{First", "Second"])
    }

    @Test func `Ignoring unterminated match`() {
        let string = "Some text [(Match"
        let matches = string.substrings(between: "[(", and: ")]")
        #expect(matches == [])
    }

    @Test func `Ignoring empty match`() {
        let string = "Some text [()]"
        let matches = string.substrings(between: "[(", and: ")]")
        #expect(matches == [])
    }

    @Test func `HTML scanning`() {
        let html = "<p>Hello, <b>this text should be bold</b>, right?</p>"

        let tags = html.substrings(between: "<", and: ">")
        #expect(tags == ["p", "b", "/b", "/p"])

        let boldText = html.substrings(between: "<b>", and: "</b>")
        #expect(boldText == ["this text should be bold"])
    }

    @Test func `Markdown scanning`() {
        let markdown = """
        # Title

        Text

        ## Section 1

        More text

        ## Section 2
        """

        let h1s = markdown.substrings(between: [.prefix("# "), "\n# "], and: [.end, "\n"])
        #expect(h1s == ["Title"])

        let h2s = markdown.substrings(between: [.prefix("## "), "\n## "], and: [.end, "\n"])
        #expect(h2s == ["Section 1", "Section 2"])
    }

    @Test func `Multiple matchers`() {
        let string = "Some text <First> some other text [[Second]]."
        var matches = (a: [Substring](), b: [Substring]())
        var ranges = (a: [ClosedRange<String.Index>](), b: [ClosedRange<String.Index>]())

        string.scan(using: [
            Matcher(identifier: "<", terminator: ">") { match, range in
                matches.a.append(match)
                ranges.a.append(range)
            },
            Matcher(identifier: "[[", terminator: "]]") { match, range in
                matches.b.append(match)
                ranges.b.append(range)
            }
        ])

        #expect(matches.a == ["First"])
        #expect(ranges.a.map { string[$0] } == ["<First>"])
        #expect(matches.b == ["Second"])
        #expect(ranges.b.map { string[$0] } == ["[[Second]]"])
    }

    @Test func `Disallowing multiple matches`() {
        let string = "Some text <First> some other text <Second>, <Third>."
        var matches = [Substring]()

        string.scan(using: [
            Matcher(
                identifier: "<",
                terminator: ">",
                allowMultipleMatches: false,
                handler: { match, _ in
                    matches.append(match)
                }
            )
        ])

        #expect(matches == ["First"])
    }

    @Test func `Scanning for a single substring`() {
        let string = "Some text <First> some other text <Second>, <Third>."
        let match = string.firstSubstring(between: "<", and: ">")
        #expect(match == "First")
    }

    @Test func `Scanning for a single substring with multiple identifiers`() {
        let string = "Some text <First> some other text [Second], <Third>."
        let match = string.firstSubstring(between: ["<", "["], and: [">", "]"])
        #expect(match == "First")
    }
}
