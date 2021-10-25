import UIKit
import RealmSwift
import UserNotifications    // 追加

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let realm = try! Realm()
    var task: Task!

    // 背景をタップしたらキーボードを閉じる設定とタスクの内容をUIに設定する。
    override func viewDidLoad() {
        super.viewDidLoad()
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        // viewにUITapGestureRecognizerを登録
        self.view.addGestureRecognizer(tapGesture)
        // データベースにあるタスクのデータをUIに表示する
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        categoryTextField.text = task.category
    }

    //遷移元の画面に戻る前に処理される
    override func viewWillDisappear(_ animated: Bool) {
        // データベースを保存する領域がストレージにない場合はアプリを強制終了する
        try! realm.write {
            // UIに書かれた情報をデータベースに保存する
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.category = self.categoryTextField.text!
            self.realm.add(self.task, update: .modified)
        }
        // ローカル通知を設定する
        setNotification(task: task)
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task: Task) {
        // UNMutableNotificationContentとは通知の編集可能なコンテンツ
        let content = UNMutableNotificationContent()
        // タイトルが何もない時
        if task.title == "" {
            // 通知のタイトルにローカライズされた(タイトルなし)を提供
            content.title = "(タイトルなし)"
        } else {
            // タイトルがある時は、通知のタイトルにローカライズされたタイトルを提供
            content.title = task.title
        }
        // カテゴリーが何もない時
        if task.category == "" {
            // 通知のカテゴリーにローカライズされた(カテゴリーなし)を提供
            content.subtitle = "(カテゴリーなし )"
        } else {
            // カテゴリーがある時は、通知のタイトルにローカライすされたカテゴリーを提供
            content.subtitle = task.category
        }
        // 内容が何もない時
        if task.contents == "" {
            // 通知の本文にローカライズされた(内容なし)を提供
            content.body = "(内容なし)"
        } else {
            // 内容がある時は、通知の本文にローカライズされた内容を提供
            content.body = task.contents
        }
        // 通知の再生音はデフォルト
        content.sound = UNNotificationSound.default
        // 現在のカレンダーを取得
        let calendar = Calendar.current
        // カレンダーのタイムゾーンを使用して、日付のすべての日付コンポーネントをデータベースの日付データに返す
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        // デバイスでスケジュールした日付コンポーネントを基に通知する。繰り返さない。
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)
        // UNUserNotificationCenter.currentは、現在のアプリまたはアプリ拡張機能の通知関連のアクティビティを管理するための中心的なオブジェクト。
        let center = UNUserNotificationCenter.current()
        // ローカル通知を登録
        center.add(request) { (error) in
            // errorがnilならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
            print(error ?? "ローカル通知登録 OK")
        }
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
}
