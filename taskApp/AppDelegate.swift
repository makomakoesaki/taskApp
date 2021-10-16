//
//  AppDelegate.swift
//  taskApp
//
//  Created by ESAKI MAKOTO on 2021/10/15.
//

import UIKit
import UserNotifications    // 追加

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    //起動プロセスがほぼ完了し、アプリを実行する準備がほぼ整ったことを代理人に通知するインスタンスメソッド
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //UNUserNotificationCenter.currentは、現在のアプリまたはアプリ拡張機能の通知関連のアクティビティを管理するための中心的なオブジェクト。
        let center = UNUserNotificationCenter.current()
        //現在のアプリまたはアプリ拡張機能の通知関連のアクティビティを警報と音とする。ただし、ユーザーに通知するには、ユーザー認証が必要です。
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // 承認に基づいて機能を有効または無効にします
        }
        //UNUserNotificationCenterDelegateプロトコルを自分のクラスに任せる
        center.delegate = self
        //アプリがURLリソースを処理できない場合、またはユーザーアクティビティを続行できない場合は、falseを返します。
        //それ以外の場合はtrueを返します。リモート通知の結果としてアプリが起動された場合、戻り値は無視されます。
        return true
    }

    // アプリがフォアグラウンドの時に通知を受け取ると呼ばれるメソッド --- ここから ---
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    } // --- ここまで追加 ---
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

