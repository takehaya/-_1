//
//  AppDelegate.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/10.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    struct setSign {
        var id:Int!
        var sign_up:String!
        var Sell_by:NSDate!
        var Sell_bytime:String!
        var Sell_bytimeType:Int!
    }
    var listtableArray:Array<setSign>! = []
    func SetCrateSqlite (){
        let sql = "CREATE TABLE IF NOT EXISTS dataofsell (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,Sell_by DATETIME,Sell_bytime INTEGER,Sell_bytimeType INTEGER);"
        let database = FMDatabase(path: databaseUtilitys().setdatapath)
        database.open()
        
        // SQL文を実行
        let ret = database.executeUpdate(sql, withArgumentsInArray: nil)
        
        if ret {
            print("テーブルの作成に成功")
        }
        // データベースをクローズ
        database.close()
        
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: UIUserNotificationType.Sound , categories: nil))
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:  UIUserNotificationType.Alert , categories: nil))
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes:  UIUserNotificationType.Badge, categories: nil))
        //実行アプションがあるかどうか
        if  (launchOptions != nil) {
            
            let notification = launchOptions?[UIApplicationLaunchOptionsLocalNotificationKey] as! UILocalNotification!
            if (notification != nil) {
                //notificationを実行します
                //キャンセルしないと残ってしまいますのでキャンセルします
                UIApplication.sharedApplication().cancelLocalNotification(notification);
            }
        }

              return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SetCrateSqlite()
        //今までのセット殺す
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        let database = FMDatabase(path: databaseUtilitys().setdatapath)
        //select
        let sqlq = "SELECT * FROM dataofsell"
        database.open()
        
        let rest = database.executeQuery(sqlq, withArgumentsInArray: nil)
        while rest.next(){
            let PID = Int(rest.stringForColumn("id"))
            let sign_up = rest.stringForColumn("name") as String
            let Sell_by = rest.dateForColumn("Sell_by")
            let Sell_bytime = rest.stringForColumn("Sell_bytime") as String
            let TypedateTime = Int(rest.intForColumn("Sell_bytimeType"))
            listtableArray.append(setSign(id: PID, sign_up: sign_up, Sell_by: Sell_by, Sell_bytime: Sell_bytime, Sell_bytimeType: TypedateTime))
        }
        database.close()
        
        for timedate in listtableArray{
            
            //日付操作に必要なカレンダーを作成するよ。
            // let cale = NSCalendar.currentCalendar()
            //日付取り出しやすくするコンポーネント
            let comp = NSDateComponents()
            /*--指定の日付、時間に通知するロジック--*/
            //タイムゾーンを端末で指定したものに変更するよ
            comp.timeZone = NSTimeZone.systemTimeZone()
            //["1時間前:1","3時間前:2","6時間前:3","12時間前:4","1日前:5","3日前:6","１週間前:7"]
            var nexttime :NSTimeInterval = 0//設定による時間差
            let playtime = timedate.Sell_by
            switch timedate.Sell_bytime{
            case "1時間前":
                nexttime = -60*60
            case "3時間前":
                nexttime = -3*60*60
            case "6時間前":
                nexttime = -6*60*60
            case "12時間前":
                nexttime = -12*60*60
            case "1日前":
                nexttime = -24*60*60
            case "3日前":
                nexttime = -3*24*60*60
            case "１週間前":
                nexttime = -7*24*60*60
            default:
                print("error")
                
            }
            //     nexttime = -10
            let datesel = NSDate(timeInterval: nexttime, sinceDate: playtime)
            let dateif = NSDate().compare(datesel)
            if dateif == NSComparisonResult.OrderedAscending{//今日より時間が大きいとき
                let notificaion = UILocalNotification()
                notificaion.fireDate = datesel
                notificaion.timeZone = NSTimeZone.systemTimeZone()
                notificaion.alertBody = timedate.sign_up + "は設定賞味期限まで" + timedate.Sell_bytime + "です。"
                notificaion.alertAction = "OK"
                notificaion.soundName = "fallinlove.mp3"
                
                notificaion.applicationIconBadgeNumber = 1
                UIApplication.sharedApplication().scheduledLocalNotifications?.append(notificaion)
            }
        }
        
      
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let alert = UIAlertView();
        alert.title = "通知";
        alert.message = notification.alertBody;
        alert.addButtonWithTitle(notification.alertAction!);
        alert.show();
    }

}

