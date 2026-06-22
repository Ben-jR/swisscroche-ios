// Software Name: Saracroche iOS
// SPDX-FileCopyrightText: Copyright (c) Camille Bouvat
// SPDX-License-Identifier: GPL-3.0-or-later
//
// This software is distributed under the GNU General Public License v3.0 or later license,
// the text of which is available at https://www.gnu.org/licenses/gpl-3.0.en.html#license-text
// or see the "LICENSE" file for more details.

import Foundation

/// Allows to store inside `NSCache` some objects which won't be removed when the application goes to background
final class Cache<Key: Hashable, Value>: NSObject, NSCacheDelegate {

  // MARK: - Properties

  private let cache = NSCache<KeyWrapper, Entry>()

  // MARK: - Lifecycle

  override init() {
    super.init()
    cache.delegate = self
  }

  deinit {
    cache.delegate = nil
  }

  // MARK: - Service

  subscript(key: Key) -> Value? {
    get {
      return value(forKey: key)
    }
    set {
      if let value = newValue {
        setValue(value, forKey: key)
      } else {
        removeValue(forKey: key)
      }
    }
  }

  func setValue(_ value: Value, forKey key: Key) {
    let entry = Entry(value)
    cache.setObject(entry, forKey: KeyWrapper(key))
  }

  func value(forKey key: Key) -> Value? {
    return cache.object(forKey: KeyWrapper(key))?.value as? Value
  }

  func removeValue(forKey key: Key) {
    cache.removeObject(forKey: KeyWrapper(key))
  }

  func removeAllValues() {
    cache.removeAllObjects()
  }

  // MARK: - Key Wrapper

  final class KeyWrapper: NSObject {
    let key: Key

    init(_ key: Key) {
      self.key = key
    }

    override var hash: Int {
      return key.hashValue
    }

    override func isEqual(_ object: Any?) -> Bool {
      guard let wrapper = object as? KeyWrapper else {
        return false
      }

      return wrapper.key == key
    }
  }

  // MARK: - Entry

  final class Entry: NSDiscardableContent {
    let value: Value

    init(_ value: Value) {
      self.value = value
    }

    func beginContentAccess() -> Bool {
      return true
    }

    func endContentAccess() {}

    func discardContentIfPossible() {}

    func isContentDiscarded() -> Bool {
      return false
    }
  }
}
