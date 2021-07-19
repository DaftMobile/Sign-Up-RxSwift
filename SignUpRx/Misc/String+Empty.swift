import Foundation

extension Optional where Wrapped == String {
  var orEmpty: String {
    switch self {
    case .none: return ""
    case .some(let value): return value
    }
  }
}
