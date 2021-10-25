import RealmSwift

class Task: Object {
    // dynamicはプロパティの変更を監視する
    // プライマリーキーとは、データベースでそれぞれのデータを一意に識別するためのID
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // カテゴリー
    @objc dynamic var category = ""
    
    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
