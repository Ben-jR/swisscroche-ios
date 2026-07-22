import Foundation

/// Helper functions for phone number patterns
public enum PhoneNumberHelpers {
  public static func countPhoneNumbers(for pattern: String) -> Int64 {
    guard !pattern.isEmpty else { return 0 }
    let hashCount = pattern.filter { $0 == "#" }.count
    return Int64(pow(10, Double(hashCount)))
  }

  public static func expandBlockingPattern(_ pattern: String) -> [String] {
    if !pattern.contains("#") {
      return [pattern]
    }

    let minNumberInPrefix =
      Int64(pattern.replacingOccurrences(of: "#", with: "0")) ?? 0
    let maxNumberInPrefix =
      Int64(pattern.replacingOccurrences(of: "#", with: "9")) ?? 0

    var results: [String] = []

    for number in minNumberInPrefix...maxNumberInPrefix {
      results.append(String(number))
    }

    return results
  }

  /// Checks if a phone number matches a blocking pattern character by character
  /// - `#` in the pattern matches any digit
  /// - Any other character must match exactly
  /// - Parameters:
  ///   - number: The phone number to check
  ///   - pattern: The blocking pattern (e.g. `33899######`)
  /// - Returns: `true` if the number matches the pattern
  public static func matches(number: String, pattern: String) -> Bool {
    guard number.count == pattern.count else { return false }
    return zip(number, pattern).allSatisfy { candidate, expected in
      expected == "#" ? (candidate.isASCII && candidate.isNumber) : candidate == expected
    }
  }
}
