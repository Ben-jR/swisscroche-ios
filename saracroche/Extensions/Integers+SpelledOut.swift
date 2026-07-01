import Foundation

extension Int64 {

  var spelledOut: String {
    let f = NumberFormatter()
    f.numberStyle = .spellOut
    f.locale = Locale(identifier: "fr_FR")
    return f.string(from: NSNumber(value: self)) ?? "\(self)"
  }
}

extension Int {

  var spelledOut: String {
    let f = NumberFormatter()
    f.numberStyle = .spellOut
    f.locale = Locale(identifier: "fr_FR")
    return f.string(from: NSNumber(value: self)) ?? "\(self)"
  }
}
