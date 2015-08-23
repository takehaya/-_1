//
//  SelectIOImageViewContoroller.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/19.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit

class SelectIOImageViewContoroller: UIViewController {
    
    @IBOutlet weak var imageIOView: UIImageView!
    
    @IBOutlet weak var ok_button: UIButton!
    @IBOutlet weak var cancel_button: UIButton!
     
    var imageID:Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ok_button.addTarget(self, action: "ok_buttonEvent:", forControlEvents: UIControlEvents.TouchUpInside)
        self.cancel_button.addTarget(self, action: "cancel_buttonEvent:", forControlEvents: UIControlEvents.TouchUpInside)
        let database = FMDatabase(path: databaseUtilitys().setdatapath)
        //select
        let sqlq = "SELECT MAX(imageTabel.id) as id,image FROM imageTabel"
        database.open()
        var arrimage :NSData!
        let resultSet = database.executeQuery(sqlq, withArgumentsInArray: nil)
        while resultSet.next(){
            imageID = Int(resultSet.stringForColumn("id"))
            arrimage = resultSet.dataForColumn("image")
        }
        database.close()
        
        
       let imageOriginal = UIImage(data: arrimage!)
        // 回転ほいほい
//        let imagesize = CGSize(width: (imageOriginal?.size.width)!, height: (imageOriginal?.size.height)!)
//        UIGraphicsBeginImageContext(imagesize)
//        let context:CGContextRef = UIGraphicsGetCurrentContext()!
//        CGContextTranslateCTM(context, imageOriginal!.size.width/2, imageOriginal!.size.height/2); // 回転の中心点を移動
//        CGContextScaleCTM(context, 1.0, -1.0); // Y軸方向を補正
//        let radian = 90 * M_PI / 180; // 90°回転させたい場合
//       
//        CGContextRotateCTM(context, CGFloat(radian))
//        CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(-imageOriginal!.size.width/2, -imageOriginal!.size.height/2, imageOriginal!.size.width, imageOriginal!.size.height), imageOriginal!.CGImage);
//        
//        let rotatedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
       let tleimage = UIImage(CGImage: (imageOriginal?.CGImage)!, scale: (imageOriginal?.scale)!, orientation: UIImageOrientation.Right)
        imageIOView.image =  tleimage
        imageIOView.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
       // imageIOView.sizeToFit()
    }
    func ok_buttonEvent(sender:UIButton){
        
         self.performSegueWithIdentifier("returntoCollction", sender: self)
    }
    func cancel_buttonEvent(sender:UIButton){
        
        //リムーブ処理
        let db = FMDatabase(path:databaseUtilitys().setdatapath )
        let sql = "DELETE FROM imageTabel WHERE id = ?;"
        
        db.open()
       db.executeUpdate(sql, withArgumentsInArray: [imageID])
        db.close()

         self.performSegueWithIdentifier("ReturntoCollctionReceiptView_to_ImagePview", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
}
