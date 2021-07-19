import RxSwift
import Foundation

protocol NameRequest {
  func validate(name: String) -> Single<String?>
}

class NameRequestStub: NameRequest {
  func validate(name: String) -> Single<String?> {
    Single.create { observer in
      DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
        if name.starts(with: "u") {
          observer(.success(name))
        } else {
          observer(.success(nil))
        }
      }
      return Disposables.create()
    }
  }
}
