import XCTest

@testable import swisscroche

/// `validatePatternFormat` guards every user-entered prefix before it reaches CoreData and,
/// ultimately, the Call Directory extension.
@MainActor
final class PatternValidationTests: XCTestCase {

  func testAcceptsAnInternationalPrefixWithTrailingWildcards() {
    XCTAssertNil(ListsViewModel.validatePatternFormat("+33612345####"))
    XCTAssertNil(ListsViewModel.validatePatternFormat("+33899######"))
  }

  func testTrimsSurroundingWhitespaceBeforeValidating() {
    XCTAssertNil(ListsViewModel.validatePatternFormat("  +33612345####\n"))
  }

  func testRejectsAnEmptyPrefix() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat(""))
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("   "))
  }

  func testRejectsInnerWhitespace() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+336 12345####"))
  }

  func testRejectsCharactersOtherThanDigitsPlusAndHash() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+33612345ab##"))
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+33-612345###"))
  }

  func testRejectsAPrefixNotInInternationalForm() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("0899######"))
  }

  func testRejectsAPrefixWithoutWildcard() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+33612345678"))
  }

  /// Wildcards must be trailing: `expandBlockingPattern` enumerates the range between the
  /// all-zero and all-nine forms, which only covers the pattern when the `#` sit at the end.
  func testRejectsWildcardsThatAreNotTrailing() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+336#1234###"))
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+33#99######"))
  }

  func testRejectsAPrefixShorterThanFourCharacters() {
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+##"))
  }

  func testRejectsMoreThanSixWildcards() {
    XCTAssertNil(ListsViewModel.validatePatternFormat("+33612345######"))
    XCTAssertNotNil(ListsViewModel.validatePatternFormat("+33612345#######"))
  }
}
