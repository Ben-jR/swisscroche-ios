import XCTest

@testable import swisscroche

final class PhoneNumberHelpersTests: XCTestCase {

  // MARK: - countPhoneNumbers

  func testCountPhoneNumbersWithoutWildcardCountsASingleNumber() {
    XCTAssertEqual(PhoneNumberHelpers.countPhoneNumbers(for: "33899123456"), 1)
  }

  func testCountPhoneNumbersGrowsByAFactorOfTenPerWildcard() {
    XCTAssertEqual(PhoneNumberHelpers.countPhoneNumbers(for: "33899#"), 10)
    XCTAssertEqual(PhoneNumberHelpers.countPhoneNumbers(for: "33899##"), 100)
    XCTAssertEqual(PhoneNumberHelpers.countPhoneNumbers(for: "33899######"), 1_000_000)
  }

  // MARK: - expandBlockingPattern

  func testExpandBlockingPatternWithoutWildcardReturnsThePatternItself() {
    XCTAssertEqual(PhoneNumberHelpers.expandBlockingPattern("33899123456"), ["33899123456"])
  }

  func testExpandBlockingPatternEnumeratesTheFullRangeInAscendingOrder() {
    let numbers = PhoneNumberHelpers.expandBlockingPattern("33899#")

    XCTAssertEqual(numbers.count, 10)
    XCTAssertEqual(numbers.first, "338990")
    XCTAssertEqual(numbers.last, "338999")
    XCTAssertEqual(numbers, numbers.sorted())
  }

  func testExpandBlockingPatternPreservesTheNumberLength() {
    let pattern = "33899##"
    let numbers = PhoneNumberHelpers.expandBlockingPattern(pattern)

    XCTAssertEqual(numbers.count, 100)
    XCTAssertEqual(numbers.first, "3389900")
    XCTAssertEqual(numbers.last, "3389999")
    XCTAssertTrue(numbers.allSatisfy { $0.count == pattern.count })
  }

  /// The Call Directory extension relies on both helpers agreeing: the progress reported to the
  /// user comes from `countPhoneNumbers`, while the entries actually pushed to CallKit come from
  /// `expandBlockingPattern`.
  func testExpandBlockingPatternYieldsAsManyNumbersAsCountPhoneNumbers() {
    for pattern in ["33899123456", "33899#", "33899##", "3389###"] {
      XCTAssertEqual(
        Int64(PhoneNumberHelpers.expandBlockingPattern(pattern).count),
        PhoneNumberHelpers.countPhoneNumbers(for: pattern),
        "Mismatch for pattern \(pattern)"
      )
    }
  }

  // MARK: - matches

  func testMatchesAcceptsAnExactNumber() {
    XCTAssertTrue(PhoneNumberHelpers.matches(number: "33899123456", pattern: "33899123456"))
  }

  func testMatchesAcceptsAnyDigitInPlaceOfAWildcard() {
    XCTAssertTrue(PhoneNumberHelpers.matches(number: "33899000000", pattern: "33899######"))
    XCTAssertTrue(PhoneNumberHelpers.matches(number: "33899999999", pattern: "33899######"))
    XCTAssertTrue(PhoneNumberHelpers.matches(number: "33899123456", pattern: "33899######"))
  }

  func testMatchesRejectsANonDigitInPlaceOfAWildcard() {
    XCTAssertFalse(PhoneNumberHelpers.matches(number: "33899ABCDEF", pattern: "33899######"))
  }

  func testMatchesRejectsADifferentPrefix() {
    XCTAssertFalse(PhoneNumberHelpers.matches(number: "33612345678", pattern: "33899######"))
  }

  /// Patterns are stored without their leading `+`, so a sender in E.164 form is one character
  /// longer and must not match.
  func testMatchesRejectsALengthMismatch() {
    XCTAssertFalse(PhoneNumberHelpers.matches(number: "+33899123456", pattern: "33899######"))
    XCTAssertFalse(PhoneNumberHelpers.matches(number: "3389912345", pattern: "33899######"))
  }
}
