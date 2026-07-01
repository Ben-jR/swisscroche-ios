// Software Name: Saracroche iOS
// SPDX-FileCopyrightText: Copyright (c) Camille Bouvat
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license,
// the text of which is available at https://www.gnu.org/licenses/gpl-3.0.en.html#license-text
// or see the "LICENSE" file for more details.

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
