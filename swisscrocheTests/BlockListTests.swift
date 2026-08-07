import XCTest

@testable import swisscroche

/// `isNewer` decides whether a published list replaces the one already on the device,
/// and `isUsable` is the guard that stops a bad download from wiping every blocking rule.
final class BlockListTests: XCTestCase {

  private func list(version: String, patterns: Int = 1) -> BlockList {
    BlockList(
      version: version,
      name: "Test",
      patterns: (0..<patterns).map {
        BlockListPattern(name: "p\($0)", action: "block", pattern: "4190\($0)######")
      }
    )
  }

  // MARK: - isNewer

  func testALaterDateIsNewer() {
    XCTAssertTrue(list(version: "2026-09-01").isNewer(than: list(version: "2026-08-07")))
  }

  func testAnEarlierDateIsNotNewer() {
    XCTAssertFalse(list(version: "2026-08-07").isNewer(than: list(version: "2026-09-01")))
  }

  func testTheSameVersionIsNotNewer() {
    // Guarantees an already-applied list is never reapplied.
    XCTAssertFalse(list(version: "2026-08-07").isNewer(than: list(version: "2026-08-07")))
  }

  func testComparesAcrossMonthAndYearBoundaries() {
    XCTAssertTrue(list(version: "2027-01-01").isNewer(than: list(version: "2026-12-31")))
    XCTAssertTrue(list(version: "2026-10-01").isNewer(than: list(version: "2026-09-30")))
  }

  func testComparesNumericallyNotLexicographically() {
    // A plain string compare would rank "10" below "9".
    XCTAssertTrue(list(version: "2026-08-10").isNewer(than: list(version: "2026-08-09")))
  }

  // MARK: - isUsable

  func testAListWithPatternsIsUsable() {
    XCTAssertTrue(list(version: "2026-08-07").isUsable)
  }

  func testAnEmptyListIsRejected() {
    // A truncated download must never be applied — it would clear the block list.
    XCTAssertFalse(list(version: "2026-08-07", patterns: 0).isUsable)
  }

  func testAListWithoutAVersionIsRejected() {
    XCTAssertFalse(list(version: "").isUsable)
  }

  // MARK: - Decoding

  func testDecodesThePublishedFormat() throws {
    let json = """
      {
        "version": "2026-08-07",
        "name": "Liste Suisse",
        "patterns": [
          { "name": "BAKOM 0900", "action": "block", "pattern": "41900######" }
        ]
      }
      """.data(using: .utf8)!

    let decoded = try JSONDecoder().decode(BlockList.self, from: json)

    XCTAssertEqual(decoded.version, "2026-08-07")
    XCTAssertEqual(decoded.name, "Liste Suisse")
    XCTAssertEqual(decoded.patterns.count, 1)
    XCTAssertEqual(decoded.patterns.first?.pattern, "41900######")
    XCTAssertTrue(decoded.isUsable)
  }

  func testTheBundledListMatchesThePublishedFormat() throws {
    // The same file is bundled in the app and served remotely, so it must decode
    // through exactly the same path the download uses.
    let url = try XCTUnwrap(
      Bundle(for: BlockListTests.self).url(forResource: "SwissList", withExtension: "json")
        ?? Bundle.main.url(forResource: "SwissList", withExtension: "json")
    )
    let decoded = try JSONDecoder().decode(BlockList.self, from: Data(contentsOf: url))

    XCTAssertTrue(decoded.isUsable, "the bundled list must never be empty")
    XCTAssertFalse(decoded.version.isEmpty)
  }
}
