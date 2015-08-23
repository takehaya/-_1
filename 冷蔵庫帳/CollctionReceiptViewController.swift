//
//  CollctionReceiptViewController.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/16.CollctionReceiptView_to_ImagePview
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit

class CollctionReceiptViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {

    
    @IBOutlet weak var myCollectionView: UICollectionView!
    struct imagedata{
        var image:UIImage!
        var ID:Int!
        var resImage:UIImage!
        var time:NSDate!
    }
    private var indicator:MBProgressHUD! = nil
    
    var imagelist:Array<imagedata> = []
    var gePic:Int! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        SetCrateSqlite ()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillAppear(animated: Bool) {
        // アニメーションを開始する.
        self.indicator = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        self.indicator.dimBackground = true
        self.indicator.labelText = "Loading..."
        self.indicator.labelColor = UIColor.whiteColor()
    }
    override func viewDidAppear(animated: Bool) {
      
        imagelist.removeAll()
        gePic = 0
        let database = FMDatabase(path: databaseUtilitys().setdatapath)
        //select
        let sqlq = "SELECT * FROM imageTabel"
        database.open()
        
        let rest = database.executeQuery(sqlq, withArgumentsInArray: nil)
        while rest.next(){
            let _image = UIImage(data: rest.dataForColumn("image"))
            let _ID = Int(rest.stringForColumn("id"))
            let time = rest.dateForColumn("now_Datetime")
            //向き変える
             let tleimage = UIImage(CGImage: (_image?.CGImage)!, scale: (_image?.scale)!, orientation: UIImageOrientation.Right)
            let newSize:CGSize! = CGSize(width: 80, height: 170)
            UIGraphicsBeginImageContext(newSize)
            tleimage.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
            
            let newimage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            imagelist.append(imagedata(image: tleimage, ID: _ID, resImage: newimage, time: time))
        }
        database.close()
        myCollectionView.reloadData()
         MBProgressHUD.hideHUDForView(self.view, animated: true)
    }

    /*
    Cellの総数を返す
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagelist.count
    }
    
    /*
    Cellに値を設定する
    */
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : ReceiptCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cellres", forIndexPath: indexPath) as! ReceiptCollectionViewCell
       
        let datefm = NSDateFormatter()
        
        datefm.setLocalizedDateFormatFromTemplate("M月dd日")
         let time_now = imagelist[indexPath.row].time
        cell.NumbarLabel?.text = String(datefm.stringFromDate(time_now!))
        cell.Receupt_ImageView.image = imagelist[indexPath.row].resImage
        
        return cell
    }
    /*
    Cellが選択された際に呼び出される
    */
    //returnCollctionReceiptView_to_ImagePview
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         gePic  = imagelist[indexPath.row].ID
        performSegueWithIdentifier("CollctionReceiptView_to_ImagePview", sender: self)
        
        print("Num: \(indexPath.row)")
        
    }
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var size = CGSizeZero
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            size = CGSize(width: self.view.frame.width/3, height: self.view.frame.height/3) // Rect
        }else{
            size = CGSize(width: self.view.frame.width/5, height: self.view.frame.height/4) // Rect
        }
        return size
    }
    @IBAction func returntoCollctionReceipt(sender:UIStoryboardSegue){
    
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
//        if UIScreen.mainScreen().bounds.height <= 580{
//            return UIImage(named: "お腹すいた懇願からっぽ3c.png")
//        }
//        else if UIScreen.mainScreen().bounds.height <= 736{
//            return UIImage(named: "お腹すいた懇願からっぽ4c.png")
//        }/
//        return UIImage(named: "お腹すいた懇願からっぽ6c.png")
//        if (arc4random_buf(<#T##UnsafeMutablePointer<Void>#>, <#T##Int#>)/2) == true{
        let image = UIImage(named: "フラットなレシート.png")
        var afimage:UIImage!
        UIGraphicsBeginImageContext(self.view.frame.size)
        image?.drawInRect(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
        afimage = UIGraphicsGetImageFromCurrentImageContext()
        return afimage
//        }
//         let image = UIImage(named: "スーパーのレシート.png")
//        var afimage:UIImage!
//        UIGraphicsBeginImageContext(self.view.frame.size)
//        image?.drawInRect(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
//        afimage = UIGraphicsGetImageFromCurrentImageContext()
//        return afimage
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "何も設定されてないよ。"
        let dic = [NSFontAttributeName:UIFont.boldSystemFontOfSize(18.0),NSForegroundColorAttributeName:UIColor.grayColor()]
        return NSAttributedString(string: text, attributes: dic)
    }
    func SetCrateSqlite (){
        let sql = "CREATE TABLE IF NOT EXISTS imageTabel(id INTEGER PRIMARY KEY AUTOINCREMENT, image BLOB,createtTime REAL,now_Datetime DATETIME);"
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
    //値渡しできるやつ
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "CollctionReceiptView_to_ImagePview") {
            let nextviewController:imagePViewController = segue.destinationViewController as! imagePViewController
                nextviewController.selectId = gePic
            
        }
    }
}


class ReceiptCollectionViewCell : UICollectionViewCell{
    
    @IBOutlet weak var NumbarLabel: UILabel!
    
    @IBOutlet weak var Receupt_ImageView: UIImageView!
    
}
