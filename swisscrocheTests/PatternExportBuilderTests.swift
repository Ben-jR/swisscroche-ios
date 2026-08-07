import XCTest

@testable import swisscroche

final class PatternExportBuilderTests: XCTestCase {

  /// Midday local time, so the rendered day is stable whatever the time zone.
  private let referenceDate: Date = {
    var components = DateComponents()
    components.year = 2026
    components.month = 8
    components.day = 7
    components.hour = 12
    return Calendar.current.date(from: components)!
  }()

  private func item(_ pattern: String, _ name: String?, _ action: String = "block")
    -> PatternExportBuilder.Item
  {
    PatternExportBuilder.Item(pattern: pattern, name: name, action: action)
  }

  // MARK: - Format

  func testAddsTheLeadingPlusPatternsAreStoredWithout() {
    let text = PatternExportBuilder.build(from: [item("41791234567", "Démarchage")])

    XCTAssertTrue(text.contains("+41791234567"))
    XCTAssertFalse(text.contains("\n41791234567"))
  }

  func testWritesNameAndAction() {
    let text = PatternExportBuilder.build(from: [item("41791234567", "Démarchage", "identify")])

    XCTAssertTrue(text.contains("+41791234567, Démarchage, identify"))
  }

  func testKeepsTheNameFieldEvenWhenEmpty() {
    // Otherwise the action would slide into second position and be read as a name.
    let text = PatternExportBuilder.build(from: [item("41791234567", nil)])

    XCTAssertTrue(text.contains("+41791234567, , block"))
  }

  func testStartsWithACommentHeader() {
    let text = PatternExportBuilder.build(from: [item("41791234567", "X")], date: referenceDate)
    let firstLine = text.split(separator: "\n").first.map(String.init)

    XCTAssertEqual(firstLine?.hasPrefix("//"), true)
  }

  func testFilenameCarriesTheDate() {
    XCTAssertEqual(
      PatternExportBuilder.filename(date: referenceDate),
      "swisscroche-liste-2026-08-07.txt"
    )
  }

  func testAnEmptyListStillProducesAValidFile() {
    let text = PatternExportBuilder.build(from: [])

    XCTAssertTrue(PatternImportParser.parse(text).isEmpty)
  }

  // MARK: - Round trip

  /// The reason both sides exist: a shared list must come back unchanged.
  func testExportThenImportRoundTripsEveryField() {
    let items = [
      item("41791234567", "Démarchage", "block"),
      item("41791234####", "Sondage téléphonique", "identify"),
      item("41221234567", nil, "block"),
    ]

    let entries = PatternImportParser.parse(PatternExportBuilder.build(from: items))

    XCTAssertEqual(entries.count, 3)

    XCTAssertEqual(entries[0].pattern, "+41791234567")
    XCTAssertEqual(entries[0].name, "Démarchage")
    XCTAssertEqual(entries[0].action, "block")

    XCTAssertEqual(entries[1].pattern, "+41791234####")
    XCTAssertEqual(entries[1].name, "Sondage téléphonique")
    XCTAssertEqual(entries[1].action, "identify")

    XCTAssertEqual(entries[2].pattern, "+41221234567")
    XCTAssertNil(entries[2].name, "an absent name must not become an empty string")
    XCTAssertEqual(entries[2].action, "block")
  }

  func testRoundTripsANameContainingAComma() {
    let items = [item("41791234567", "Assurance, vente", "block")]

    let entries = PatternImportParser.parse(PatternExportBuilder.build(from: items))

    XCTAssertEqual(entries.first?.name, "Assurance, vente")
    XCTAssertEqual(entries.first?.action, "block")
  }

  func testTheHeaderIsSkippedOnImport() {
    let text = PatternExportBuilder.build(from: [item("41791234567", "X")])

    XCTAssertEqual(PatternImportParser.parse(text).count, 1)
  }
}

/// Behaviour of the optional third field, which carries the action.
final class PatternImportActionTests: XCTestCase {

  func testReadsAnActionInThirdPosition() {
    let entry = PatternImportParser.parse("+41791234567, Sondage, identify").first

    XCTAssertEqual(entry?.name, "Sondage")
    XCTAssertEqual(entry?.action, "identify")
  }

  func testAcceptsAnActionInAnyCase() {
    XCTAssertEqual(
      PatternImportParser.parse("+41791234567, Sondage, IDENTIFY").first?.action, "identify")
  }

  func testHasNoActionWhenTheLineOmitsIt() {
    // The caller then applies the action chosen in the import screen.
    XCTAssertNil(PatternImportParser.parse("+41791234567, Démarchage").first?.action)
  }

  func testAnUnknownThirdFieldStaysPartOfTheName() {
    let entry = PatternImportParser.parse("+41791234567, Assurance, vente").first

    XCTAssertEqual(entry?.name, "Assurance, vente")
    XCTAssertNil(entry?.action)
  }

  func testReadsTheActionWhenTheNameIsEmpty() {
    let entry = PatternImportParser.parse("+41791234567, , block").first

    XCTAssertNil(entry?.name)
    XCTAssertEqual(entry?.action, "block")
  }

  func testASecondFieldNamingAnActionIsTreatedAsAName() {
    // Documented rule: the action is only recognised in third position, so a
    // two-field line stays unambiguous.
    let entry = PatternImportParser.parse("+41791234567, block").first

    XCTAssertEqual(entry?.name, "block")
    XCTAssertNil(entry?.action)
  }
}
