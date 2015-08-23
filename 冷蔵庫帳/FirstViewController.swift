//
//  FirstViewController.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/10.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit
import QuartzCore

class FirstViewController: UIViewController,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate,UITableViewDelegate,UITableViewDataSource {
    
    
    let timeArr = []
    struct setSign {
        var id:Int!
        var sign_up:String!
        var Sell_by:NSDate!
        var Sell_bytime:String!
        var Sell_bytimeType:Int!
    }
    
    @IBOutlet weak var listtableView: UITableView!
    
    var listtableArray:Array<setSign> = []
    //どこの画面をタップしてもフォーカスを外すのが動く
    @IBAction func uptapevent(sender: AnyObject) {
        self.view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // self.listtableView.allowsSelection
        self.listtableView.emptyDataSetDelegate = self
        self.listtableView.emptyDataSetSource = self
      //  self.listtableView.tableFooterView = UIView()
        SetCrateSqlite()
       
    }
    override func viewDidAppear(animated: Bool) {
        listtableArray.removeAll()
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
        listtableView.reloadData()
         aptesel()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //UITabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: listtableCell = self.listtableView.dequeueReusableCellWithIdentifier("CellFirstList",forIndexPath: indexPath) as! listtableCell
        cell.name_LAbel.text = listtableArray[indexPath.row].sign_up
        let datefom = NSDateFormatter()
        
        if listtableArray[indexPath.row].Sell_bytimeType == 0{
        datefom.setLocalizedDateFormatFromTemplate("yyyy年M月dd日")
            cell.sellby_Label.text = datefom.stringFromDate(listtableArray[indexPath.row].Sell_by)
        }else if listtableArray[indexPath.row].Sell_bytimeType == 1{
            datefom.setLocalizedDateFormatFromTemplate("yyyy年M月dd日　HH時mm分")
            cell.sellby_Label.text = datefom.stringFromDate(listtableArray[indexPath.row].Sell_by)
        }
        cell.sellbytime_Label.text = listtableArray[indexPath.row].Sell_bytime
        
        
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listtableArray.count
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let alert = UIAlertController(title: "確認", message: "この登録を削除しますか？", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {alert in
            //リムーブ処理
            let db = FMDatabase(path:databaseUtilitys().setdatapath )
            let sql = "DELETE FROM dataofsell WHERE id = ?;"
            
            db.open()
            db.executeUpdate(sql, withArgumentsInArray: [self.listtableArray[indexPath.row].id])
            db.close()
            self.listtableArray.removeAtIndex(indexPath.row)
            self.listtableView.reloadData()
             tableView.deselectRowAtIndexPath(indexPath, animated: false)
            self.aptesel()
        }))
        alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: {alert in
            //何もしない
             tableView.deselectRowAtIndexPath(indexPath, animated: false)
        }))
        //表示。UIAlertControllerはUIViewControllerを継承している。
        presentViewController(alert, animated: true, completion: nil)
       
    }
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        if UIScreen.mainScreen().bounds.height <= 580{
//            return UIImage(named: "お腹すいた懇願からっぽ3c.png")
//        }
//        else if UIScreen.mainScreen().bounds.height <= 736{
//            return UIImage(named: "お腹すいた懇願からっぽ4c.png")
//        }
//        return UIImage(named: "お腹すいた懇願からっぽ6c.png")
        
        let image = UIImage(named: "れいぞうこ空.png")
        var afimage:UIImage!
        UIGraphicsBeginImageContext(self.view.frame.size)
        image?.drawInRect(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        afimage = UIGraphicsGetImageFromCurrentImageContext()
        return afimage

    }

    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "何も設定されてないよ。"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),NSForegroundColorAttributeName:UIColor.grayColor()]
        return NSAttributedString(string: text, attributes: dic)
    }
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
    func aptesel(){
        //今までのセット殺す
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        for timedate in listtableArray{
            
            //日付操作に必要なカレンダーを作成するよ。
            //let cale = NSCalendar.currentCalendar()
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
            
          //  nexttime = -10
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
    }

class listtableCell: UITableViewCell {
    
    @IBOutlet weak var name_LAbel: UILabel!
    @IBOutlet weak var sellby_Label: UILabel!
    @IBOutlet weak var sellbytime_Label: UILabel!
}
