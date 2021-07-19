import RxSwift
import RxCocoa
import UIKit

class ViewController: UIViewController {

  private var nameRequest: NameRequest!
  private var signUpRequest: SignUpRequest!

  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var nameFetchingIndicator: UIActivityIndicatorView!

  private var username: BehaviorRelay<String> = .init(value: "")
  private var password: BehaviorRelay<String> = .init(value: "")
  private var passwordAgain: BehaviorRelay<String> = .init(value: "")

  private var disposeBag: DisposeBag = .init()

  override func viewDidLoad() {
    super.viewDidLoad()
    nameRequest = NameRequestStub()
    signUpRequest = SignUpRequestStub()

    validatedCredentials
      .map { $0 != nil }
      .bind(to: submitButton.rx.isEnabled)
      .disposed(by: disposeBag)

  }

  private var validatedCredentials: Observable<Credentials?> {
    Observable
      .combineLatest(validatedUsername, validatedPassword)
      .map { username, password in
        guard let username = username, let password = password else { return nil }
        return Credentials(username: username, password: password)
      }
      .share()
  }

  private var validatedUsername: Observable<String?> {
    username
      .skip(1)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMap { [unowned self] username in
        self.nameRequest.validate(name: username)
          .asObservable()
          .startWith(nil)
          .observe(on: MainScheduler.instance)
          .do(
            onCompleted: { [weak nameFetchingIndicator] () in
            nameFetchingIndicator?.stopAnimating()
          }, onSubscribe: { [weak nameFetchingIndicator] () in
            nameFetchingIndicator?.startAnimating()
          }, onDispose: { [weak nameFetchingIndicator] () in
            nameFetchingIndicator?.stopAnimating()
          })
      }
      .share()
  }

  private var validatedPassword: Observable<String?> {
    Observable
      .combineLatest(password, passwordAgain)
      .map { (p1, p2) -> String? in
        guard p1 == p2, p1.count >= 8 else { return nil }  // This is the password validation logic. It should be moved to a separate Publisher (just like NameValidator)
        return p1
      }
      .share()
  }

  @IBAction func submitButtonPressed(_ sender: Any) {
    print("Submit credentials")
  }

  @IBAction func usernameDidChange(_ sender: UITextField) {
    username.accept(sender.text ?? "")
  }

  @IBAction func passwordDidChange(_ sender: UITextField) {
    password.accept(sender.text ?? "")
  }

  @IBAction func passwordAgainDidChange(_ sender: UITextField) {
    passwordAgain.accept(sender.text ?? "")
  }
}
