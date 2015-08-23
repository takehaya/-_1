//
//  SecondViewController.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/10.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController,UITableViewDataSource,UIToolbarDelegate,UITableViewDelegate,UITextFieldDelegate,UIPickerViewDelegate {
    //どこの画面をタップしてもフォーカスを外すのが動く
    @IBAction func uptapevent(sender: AnyObject) {
        self.view.endEditing(true)
    }
    var setSignArray:Array<setSign> = []
    //ツール達
    var myToolBar:UIToolbar!
    var dataPic:UIDatePicker!
    var getdate:NSDate! = NSDate()
    var Segmentselect:Int! = 0
    var calltimeArr = ["1時間前","3時間前","6時間前","12時間前","1日前","3日前","１週間前"]
                    //["1時間前:1","3時間前:2","6時間前:3","12時間前:4","1日前:5","3日前:6","１週間前:7"]
    var calltime_ToolBar:UIToolbar!
    var calltime_Picker: UIPickerView!
    //変数たち
    private var indicator:MBProgressHUD! = nil
    @IBOutlet weak var setname_textfield: UITextField!
    @IBOutlet weak var sellby_textfield: UITextField!
    @IBOutlet weak var TimeSelc_Segment: UISegmentedControl!
    @IBOutlet weak var Al_sel_tim_textfield: UITextField!
    @IBOutlet weak var conti_button: UIButton!
    @IBOutlet weak var end_button: UIButton!
    @IBOutlet weak var setSignTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // アニメーションを開始する.
        self.indicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.indicator.dimBackground = true
        self.indicator.labelText = "Loading..."
        self.indicator.labelColor = UIColor.whiteColor()
      //createOFsqlite3
        SetCrateSqlite ()
        self.end_button.addTarget(self, action: "end_buttonEvent:", forControlEvents: UIControlEvents.TouchUpInside)
        end_button.layer.masksToBounds = true
        end_button.layer.cornerRadius = 12
        sellby_textfield.tag = 3
        self.conti_button.addTarget(self, action: "conti_buttonEvent:", forControlEvents: UIControlEvents.TouchUpInside)
        conti_button.layer.masksToBounds = true
        conti_button.layer.cornerRadius = 12
        
        TimeSelc_Segment.addTarget(self, action: "TimeSelc_SegmentEvent:", forControlEvents: UIControlEvents.ValueChanged)
        //datapicの設置
        calltime_Picker = UIPickerView()
        calltime_Picker.tag = 1
        calltime_Picker.delegate = self
        calltime_Picker.showsSelectionIndicator = true
        //Tool_perend
        calltime_ToolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.width, 40))
        calltime_ToolBar.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.size.height-20)
        let calltime_PickerButton = UIBarButtonItem(title: "次へ", style: UIBarButtonItemStyle.Done, target: self, action: "calltime_PickerButtonEvent_nextClick:")
        calltime_PickerButton.tintColor = UIColor.whiteColor()
        calltime_ToolBar.items = [calltime_PickerButton]
        calltime_ToolBar.backgroundColor = UIColor.blackColor()
        calltime_ToolBar.barStyle = UIBarStyle.Black
        calltime_ToolBar.tintColor = UIColor.blackColor()
        calltime_ToolBar.delegate = self
        Al_sel_tim_textfield.inputView = calltime_Picker
        Al_sel_tim_textfield.inputAccessoryView = calltime_ToolBar
        
        //閉じるボタンを追加など
        let myToolBarButton = UIBarButtonItem(title: "close", style: UIBarButtonItemStyle.Done, target: self, action: "onClick:")
        myToolBarButton.tag = 1
        myToolBarButton.tintColor = UIColor.whiteColor()
        //toolbarについて
        myToolBar = UIToolbar(frame: CGRectMake(0, self.view.frame.size.height/6, self.view.frame.width, 40))
        myToolBar.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.size.height-20)
        myToolBar.items = [myToolBarButton]
        dataPic = UIDatePicker()
        dataPic.datePickerMode = UIDatePickerMode.Date//モード年月日
        let df = NSDateFormatter()
        df.dateFormat = "yyyy/MM/dd"
        let nowdate = NSDate()
        dataPic.minimumDate = nowdate
        dataPic.maximumDate = df.dateFromString("2018/01/01")
        myToolBar.backgroundColor = UIColor.blackColor()
        myToolBar.barStyle = UIBarStyle.Black
        myToolBar.tintColor = UIColor.blackColor()
        sellby_textfield.inputView = dataPic
        sellby_textfield.inputAccessoryView = myToolBar
        dataPic.addTarget(self, action: "pickerValueChange:", forControlEvents: UIControlEvents.ValueChanged)
     MBProgressHUD.hideHUDForView(self.view, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
//UITabelView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: SecondTableViewCell = self.setSignTableView.dequeueReusableCellWithIdentifier("SecondTableViewCell",forIndexPath: indexPath) as! SecondTableViewCell
        cell.Sign_up_Label.text = setSignArray[indexPath.row].sign_up
        //let sell = setSignArray[indexPath.row].Sell_by
        let datefom = NSDateFormatter()
         datefom.setLocalizedDateFormatFromTemplate("yyyy年M月dd日")
        if setSignArray[indexPath.row].Sell_bytimeType == 0{
            datefom.setLocalizedDateFormatFromTemplate("yyyy年M月dd日")
            cell.Sell_by_Label.text = datefom.stringFromDate(setSignArray[indexPath.row].Sell_by)
        }else if setSignArray[indexPath.row].Sell_bytimeType == 1{
            datefom.setLocalizedDateFormatFromTemplate("yyyy年M月dd日　HH時mm分")
            cell.Sell_by_Label.text = datefom.stringFromDate(setSignArray[indexPath.row].Sell_by)
        }
        cell.Sell_by_time_Label.text = setSignArray[indexPath.row].Sell_bytime
        
        return cell
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.setSignArray.count
    }
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
            let alert = UIAlertController(title: "確認", message: "この登録を削除しますか？", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: {alert in
                self.setSignArray.removeAtIndex(indexPath.row)
                self.setSignTableView.reloadData()
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: {alert in
                //何もしない
                tableView.deselectRowAtIndexPath(indexPath, animated: false)
            }))
            //表示。UIAlertControllerはUIViewControllerを継承している。
            presentViewController(alert, animated: true, completion: nil)

    }
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int {
        
         return calltimeArr.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      
         return calltimeArr[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
            self.Al_sel_tim_textfield.text = self.calltimeArr[row]
    }
//textfield
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.tag == 1 {
            Al_sel_tim_textfield.becomeFirstResponder()
        }
        return true
    }

//Actions_sqlite3
        func SetCrateSqlite (){
            let sql = "CREATE TABLE IF NOT EXISTS dataofsell (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,Sell_by DATETIME,Sell_bytime TEXT,Sell_bytimeType INTEGER);"
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
//buttonEvent
    func end_buttonEvent(sender:UIButton!){
        
        let db = FMDatabase(path: databaseUtilitys().setdatapath)
        let sql = "INSERT INTO dataofsell ( name , Sell_by , Sell_bytime,Sell_bytimeType) VALUES (? ,?,?,?);"
        
        db.open()
        db.beginTransaction()
        var isSucceeded = true
        if db.goodConnection(){}
        for var i = 0;i<setSignArray.count;i++ {
            // ?で記述したパラメータの値を渡す場合
            if !db.executeUpdate(sql, withArgumentsInArray: [setSignArray[i].sign_up,setSignArray[i].Sell_by,setSignArray[i].Sell_bytime,setSignArray[i].Sell_bytimeType]) {
                isSucceeded = false
                break
            }
        }
        
        if isSucceeded {
            print("isSucceeded")
            db.commit()
            db.close()
        }else{
            print("not isSucceeded")
            db.rollback()
        }
        
        self.setSignArray.removeAll()
        self.setSignTableView.reloadData()
        
        
    }
    func calltime_PickerButtonEvent_nextClick(sender:UIBarButtonItem){
        Al_sel_tim_textfield.resignFirstResponder()
        sellby_textfield.becomeFirstResponder()
    }
    func onClick(sender: UIBarButtonItem) {
         sellby_textfield.resignFirstResponder()
    }
    func conti_buttonEvent(sender:UIButton!){
        self.sellby_textfield.resignFirstResponder()
        if sellby_textfield.text != "" && Al_sel_tim_textfield.text != ""  && setname_textfield.text != "" {
            //this addtion
            
            self.setSignArray.append(setSign(sign_up: setname_textfield.text!, Sell_by: getdate, Sell_bytime: Al_sel_tim_textfield.text, Sell_bytimeType: Segmentselect))
            self.setSignTableView.reloadData()
            
            //this remove
            setname_textfield.text = ""
            sellby_textfield.text = ""
            Al_sel_tim_textfield.text = ""
        }

    }
    func TimeSelc_SegmentEvent(sender:UISegmentedControl!){
       
        switch sender.selectedSegmentIndex {
        case 0:
            //モード年月日
            Segmentselect = 0
           self.dataPic.datePickerMode = UIDatePickerMode.Date
        case 1:
            Segmentselect = 1
            self.dataPic.datePickerMode = UIDatePickerMode.DateAndTime
        default:
            print("Error")
        }
    }
//datepic
    func pickerValueChange(sender:UIDatePicker){
        let fm = NSDateFormatter()
        if Segmentselect == 0 {
            fm.setLocalizedDateFormatFromTemplate("yyyy年M月dd日")
            getdate = sender.date//注意生データだからフォーマット指定してない。
            sellby_textfield.text = fm.stringFromDate(getdate)//ここで初めてフォーマット指定
        }else if Segmentselect == 1{
            fm.setLocalizedDateFormatFromTemplate("yyyy年M月dd日　HH時mm分")
            getdate = sender.date//注意生データだからフォーマット指定してない。
            sellby_textfield.text = fm.stringFromDate(getdate)//ここで初めてフォーマット指定
        }
       
    }
}

class SecondTableViewCell: UITableViewCell {
    
    @IBOutlet weak var Sign_up_Label: UILabel!
    @IBOutlet weak var Sell_by_Label: UILabel!
    @IBOutlet weak var Sell_by_time_Label: UILabel!
    
}
struct setSign {
    var sign_up:String!
    var Sell_by:NSDate!
    var Sell_bytime:String!
    var Sell_bytimeType:Int!
}
//stringの文字列操作のテンプレ
extension String {
    
    subscript (i: Int) -> String {
        return String(Array(arrayLiteral: self)[i])
    }
    subscript (r: Range<Int>) -> String {
        let start = advance(startIndex, r.startIndex)
        let end = advance(startIndex, r.endIndex)
        return substringWithRange(Range(start: start, end: end))
    }
    var length:Int{return Int(self)!}
}


////sqldataCreate
//    func SetCrateSqlite (){
//        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
//        //let dir = paths[0].stringByAppendingPathComponent("app.db")
//       // let dir = paths[0].stringByAppendingPathComponent("app.db")
//      //  FMDatabase.databasePath(dir)
//            let database = FMDatabase(path: setPath())
//            database.open()
//            let sql = "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,Sell_by REAL);"
//            // SQL文を実行
//            let ret = database.executeUpdate(sql, withArgumentsInArray: nil)
//
//            if ret {
//                print("テーブルの作成に成功")
//            }
//            // データベースをクローズ
//            database.close()
//
//    }
//    func setPath ()->(String){
//
//        // /Documentsまでのパスを取得
//        let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
//        let _path = documentsFolder[0].stringByAppendingString("app.db")
//
//        return _path
//    }

//  //終了でDBに入れ込む
//        let db = FMDatabase(path: setPath())
//        let sql = "INSERT INTO data (user_id, user_name , Sell_by) VALUES (?, ? , ?);"
//        let countsql = "select count(*) from id;"
//        db.open()
//        db.beginTransaction()
//        var isSucceeded = true
//        let cntrs = db.executeQuery(countsql, withArgumentsInArray: nil)
//        var iocount = 0
//        print(cntrs.next())
//        while cntrs.next(){
//            iocount++
//        }
//        for var i = setSignArray.count;i<iocount;i++ {
//            // ?で記述したパラメータの値を渡す場合
//            if !db.executeUpdate(sql, withArgumentsInArray: [i, setSignArray[i].sign_up,setSignArray[i].Sell_by]) {
//                isSucceeded = false
//                break
//            }
//        }
//
//        if isSucceeded {
//            db.close()
//        }else{
//            db.rollback()
//        }

