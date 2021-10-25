//
//  ViewController.swift
//  taskApp
//
//  Created by ESAKI MAKOTO on 2021/10/15.
//

import UIKit
import RealmSwift

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var serch: UITextField!
    
    // Realmインスタンスを取得する
    // try!は、エラーが発生したらアプリを停止する
    let realm = try! Realm()
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        //iPhoneがタップされるのを認識すると、そのタップをキャンセルするをfalseにしました
        tapGesture.cancelsTouchesInView = false
        // viewにUITapGestureRecognizerを登録
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // UITableViewDataSourceプロトコルのメソッドで、データの数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }

    // UITableViewDataSourceプロトコルのメソッドで、セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        // Cellに値を設定する
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // セルを返す
        return cell
    }

    // UITableViewDelegateプロトコルのメソッドで、セルをタップした時にタスク入力画面に遷移させる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil)
    }

    // UITableViewDelegateプロトコルのメソッドで、セルが削除可能なことを伝える
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // UITableViewDelegateプロトコルのメソッドで、Deleteボタンが押されたときにローカル通知をキャンセルし、データベースからタスクを削除する
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]
            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
    }
    
    // タスク入力画面から戻ってきた時にTableViewの情報を更新する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func serchButton(_ sender: Any) {
        let predicate = NSPredicate(format: "category = %@", serch.text!)
        let result = realm.objects(Task.self).filter(predicate)
        print(result)
        if result.isEmpty == true {
            taskArray = result
            tableView.reloadData()
        } else if result.isEmpty == false {
            taskArray = result
            tableView.reloadData()
        }
    }
    
    // タスク入力画面に遷移する際にデータを渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController
        //　もしタスクが選択されたら
        if segue.identifier == "cellSegue" {
            // 選択したタスクのindexPathを取得する
            let indexPath = self.tableView.indexPathForSelectedRow
            // indexPathのプライマリーキーからTaskのデータ情報を取得し、inputViewController.taskに渡す
            inputViewController.task = taskArray[indexPath!.row]
        } else { //＋が選択されたら
            let task = Task()
            // データの一覧を取得する
            let allTasks = realm.objects(Task.self)
            // もしデータが存在するなら
            if allTasks.count != 0 {
                // idの最大値に+1したidをタスクのidに割り振る
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            // 新規idの情報をinputViewController.taskに渡す
            inputViewController.task = task
        }
    }
}

