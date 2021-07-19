import RxSwift
import RxCocoa
import UIKit

class ViewController: UIViewController {

  private var nameRequest: NameRequest!

  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var nameFetchingIndicator: UIActivityIndicatorView!

  private let username: BehaviorRelay<String> = .init(value: "")
  private let password: BehaviorRelay<String> = .init(value: "")
  private let passwordAgain: BehaviorRelay<String> = .init(value: "")

  private var disposeBag: DisposeBag = .init()

  override func viewDidLoad() {
    super.viewDidLoad()
    nameRequest = NameRequestStub()

    validatedCredentials
      .map { $0 != nil }
      .bind(to: submitButton.rx.isEnabled)
      .disposed(by: disposeBag)
  }

  private var validatedCredentials: Observable<Credentials?> {
    Observable
      .combineLatest(validatedUsername, validatedPassword)
      .map { username, password in
        guard let username = username,
              let password = password else {
          return nil
        }
        return Credentials(username: username, password: password)
      }
  }

  private var validatedUsername: Observable<String?> {
    username
      .skip(1)
      .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
      .distinctUntilChanged()
      .flatMapLatest { [unowned self] proposedUsername in
        self
          .nameRequest
          .validate(name: proposedUsername)
          .observe(on: MainScheduler.instance)
          .do(
            onSubscribe: { () in
              self.nameFetchingIndicator.startAnimating()
            }, onDispose: { () in
              self.nameFetchingIndicator.stopAnimating()
            })
          .asObservable()
          .startWith(nil)
      }
  }

  private var validatedPassword: Observable<String?> {
    Observable
      .combineLatest(password, passwordAgain)
      .map { p1, p2 -> String? in
        if p1 == p2 && p1.count >= 8 { return p1 } // TODO: Extract validation
        return nil
      }
  }

  @IBAction func submitButtonPressed(_ sender: Any) {
    print("Submit credentials")
  }

  @IBAction func usernameDidChange(_ sender: UITextField) {
    username.accept(sender.text.orEmpty)
  }

  @IBAction func passwordDidChange(_ sender: UITextField) {
    password.accept(sender.text.orEmpty)
  }

  @IBAction func passwordAgainDidChange(_ sender: UITextField) {
    passwordAgain.accept(sender.text.orEmpty)
  }
}
