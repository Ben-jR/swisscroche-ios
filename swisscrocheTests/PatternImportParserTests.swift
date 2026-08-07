import XCTest

@testable import swisscroche

final class PatternImportParserTests: XCTestCase {

  func testParsesOneEntryPerLine() {
    let entries = PatternImportParser.parse("+41791234567\n+41441234567")

    XCTAssertEqual(
      entries,
      [
        .init(pattern: "+41791234567", name: nil),
        .init(pattern: "+41441234567", name: nil),
      ]
    )
  }

  func testSkipsBlankLinesAndComments() {
    let text = """
      // Ma liste de spam

      +41791234567

      // encore un commentaire
      +41441234567
      """

    let entries = PatternImportParser.parse(text)

    XCTAssertEqual(entries.map(\.pattern), ["+41791234567", "+41441234567"])
  }

  func testReadsAnOptionalNameAfterASeparator() {
    let entries = PatternImportParser.parse(
      "+41791234567,Démarchage\n+41441234567;Sondage\n+41221234567\tAssurance"
    )

    XCTAssertEqual(entries.map(\.name), ["Démarchage", "Sondage", "Assurance"])
    XCTAssertEqual(
      entries.map(\.pattern),
      ["+41791234567", "+41441234567", "+41221234567"]
    )
  }

  func testStripsWhitespaceInsideNumbers() {
    let entries = PatternImportParser.parse("+41 79 123 45 67, Démarchage")

    XCTAssertEqual(entries, [.init(pattern: "+41791234567", name: "Démarchage")])
  }

  func testTreatsAnEmptyNameAsAbsent() {
    let entries = PatternImportParser.parse("+41791234567,   ")

    XCTAssertEqual(entries, [.init(pattern: "+41791234567", name: nil)])
  }

  func testKeepsWildcardPatterns() {
    let entries = PatternImportParser.parse("+41791234####")

    XCTAssertEqual(entries, [.init(pattern: "+41791234####", name: nil)])
  }

  func testHandlesWindowsLineEndings() {
    let entries = PatternImportParser.parse("+41791234567\r\n+41441234567")

    XCTAssertEqual(entries.map(\.pattern), ["+41791234567", "+41441234567"])
  }

  func testReturnsNothingForEmptyOrCommentOnlyText() {
    XCTAssertTrue(PatternImportParser.parse("").isEmpty)
    XCTAssertTrue(PatternImportParser.parse("   \n\n  ").isEmpty)
    XCTAssertTrue(PatternImportParser.parse("// rien ici").isEmpty)
  }

  func testKeepsInvalidEntriesForTheCallerToReject() {
    // Parsing is purely syntactic — validation happens later.
    let entries = PatternImportParser.parse("pas-un-numero\n0791234567")

    XCTAssertEqual(entries.map(\.pattern), ["pas-un-numero", "0791234567"])
  }
}

@MainActor
final class ImportValidationTests: XCTestCase {

  func testImportAcceptsAnExactNumberWithoutWildcard() {
    XCTAssertNil(
      ListsViewModel.validatePatternFormat("+41791234567", requireWildcard: false)
    )
  }

  func testManualEntryStillRequiresAWildcard() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+41791234567"))
  }

  func testImportStillRejectsMalformedPatterns() {
    XCTAssertNotNil(
      ListsViewModel.validatePatternFormat("0791234567", requireWildcard: false),
      "a number without '+' is not in international form"
    )
    XCTAssertNotNil(
      ListsViewModel.validatePatternFormat("+4179##34567", requireWildcard: false),
      "wildcards must be trailing"
    )
  }
}

@MainActor
final class PatternOverlapTests: XCTestCase {

  func testDetectsAContainedRange() {
    // +4179123#### covers +41791234###
    let result = ListsViewModel.overlap(of: "41791234###", with: "4179123####")

    XCTAssertEqual(result, .coveredByExisting)
  }

  func testDetectsAContainingRange() {
    let result = ListsViewModel.overlap(of: "4179123####", with: "41791234###")

    XCTAssertEqual(result, .coversExisting)
  }

  func testIgnoresPatternsOfDifferentLength() {
    XCTAssertNil(ListsViewModel.overlap(of: "4179123###", with: "41791234####"))
  }

  func testIgnoresUnrelatedPatterns() {
    XCTAssertNil(ListsViewModel.overlap(of: "41791234567", with: "41441234567"))
  }

  func testDetectsIdenticalPatterns() {
    XCTAssertNotNil(ListsViewModel.overlap(of: "41791234567", with: "41791234567"))
  }
}
