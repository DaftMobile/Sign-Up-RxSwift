import RxSwift
import Foundation

protocol SignUpRequest {
  func signUp(credentials: Credentials) -> Single<Bool>
}

class SignUpRequestStub: SignUpRequest {
  func signUp(credentials: Credentials) -> Single<Bool> {
    Single.create { observer in
      DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
        observer(.success(Bool.random()))
      }
      return Disposables.create()
    }
  }
}
