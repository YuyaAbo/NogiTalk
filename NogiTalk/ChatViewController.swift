import UIKit
import RxSwift
import RxCocoa

final class ChatViewController: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var bottomBarViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var textViewPlaceholderLabel: UILabel!
    @IBOutlet private weak var inputBarView: UIView!

    // Rx
    private let disposeBag = DisposeBag()
    private let viewModel = ChatViewModel()

    private let maxTextCharacterCount = 500
    private let maxTextViewHeight: CGFloat = 100

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "妄想トーク"

        // TableViewの設定
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 64/255, alpha: 1)
//        tableView.register(UINib(nibName: "MessageCell", bundle: Bundle(for: MessageCell.self)), forCellReuseIdentifier: "MessageCell")
        tableView.transform = __CGAffineTransformMake(1, 0, 0, -1, 0, 0)

        textView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - TableViewDelegate, TableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        textView.resignFirstResponder()
    }

    @objc private func keyboardWillShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        if let duration = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double, let height = rect?.size.height {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: -height)
                self.view.transform = transform
            }
        }
    }
    @objc private func keyboardWillHide(notification: Notification?) {
        if let duration = notification?.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Double {
            UIView.animate(withDuration: duration) {
                self.view.transform = CGAffineTransform.identity
            }
        }
    }
    @objc private func keyboardDidShow(notification: Notification?) {
        let rect = (notification?.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        if let duration = notification?.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double, let height = rect?.size.height {
            UIView.animate(withDuration: duration) {
                let transform = CGAffineTransform(translationX: 0, y: -height)
                self.view.transform = transform
            }
        }
    }

    // MARK: - TextViewDelegate

    func textViewDidBeginEditing(_ textView: UITextView) {
        textViewPlaceholderLabel.isHidden = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textViewPlaceholderLabel.isHidden = !textView.text.isEmpty
    }
    func textViewDidChange(_ textView: UITextView) {
        if let text = textView.text, text.characters.count > maxTextCharacterCount {
            textView.text = text.substring(to: text.index(text.startIndex, offsetBy: maxTextCharacterCount))
        }
        let height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(Float.greatestFiniteMagnitude))).height
        if height < maxTextViewHeight {
            bottomBarViewHeightConstraint.constant = height
        }
    }

    // MARK: - IBAction func

    @IBAction func send(_ sender: UIButton) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        textView.text = ""
        tableView.reloadData()
        let height = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat(Float.greatestFiniteMagnitude))).height
        bottomBarViewHeightConstraint.constant = height
    }


}

