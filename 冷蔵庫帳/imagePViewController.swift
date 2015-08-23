//
//  imagePViewController.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/16.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit
protocol imagereload{
    func imageReload()
}
class imagePViewController: UIViewController,UIScrollViewDelegate {

    var selectId:Int! = 0
    
    @IBOutlet weak var Del_button: UIButton!
    @IBOutlet weak var IOImageView: GestureUIImageView!
   // @IBOutlet weak var myscrollview_ScrollView: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //var _image :UIImage!
        var tleimage :UIImage!
        let database = FMDatabase(path: databaseUtilitys().setdatapath)
        Del_button.addTarget(self, action: "Del_button_Event:", forControlEvents: UIControlEvents.TouchUpInside)
        //select
        let sqlq = "SELECT image,id FROM imageTabel where id = "+String(selectId)
        database.open()
        let resultSet = database.executeQuery(sqlq, withArgumentsInArray: nil)
        while resultSet.next(){
            let image = UIImage(data:  resultSet.dataForColumn("image"))
         tleimage = UIImage(CGImage: (image?.CGImage)!, scale: (image?.scale)!, orientation: UIImageOrientation.Right)
        }
        database.close()
        IOImageView.image = tleimage
        IOImageView.frame = CGRectMake(0, 0, tleimage.size.height, tleimage.size.width)
      //  myscrollview_ScrollView.maximumZoomScale = 5.0
       // myscrollview_ScrollView.minimumZoomScale = 0.3
        //IOImageView.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func Del_button_Event(sender:UIButton){
        //リムーブ処理
        let db = FMDatabase(path:databaseUtilitys().setdatapath )
        let sql = "DELETE FROM imageTabel WHERE id = ?;"
        
        db.open()
        db.executeUpdate(sql, withArgumentsInArray: [self.selectId])
        db.close()
        self.performSegueWithIdentifier("returnCollctionReceiptView_to_ImagePview", sender: self)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}

class GestureUIImageView: UIImageView {
    //* Gesture Enabled Whether or not */
    var gestureEnabled = true
    
    // private variables
    private var beforePoint = CGPointMake(0.0, 0.0)
    private var currentScale:CGFloat = 1.0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.userInteractionEnabled = true
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(pinchGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(tapGesture)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(longPressGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: "handleGesture:")
        self.addGestureRecognizer(panGesture)
    }
    
    func handleGesture(gesture: UIGestureRecognizer){
        if let tapGesture = gesture as? UITapGestureRecognizer{
            tap(tapGesture)
        }else if let pinchGesture = gesture as? UIPinchGestureRecognizer{
            pinch(pinchGesture)
        }else if let panGesture = gesture as? UIPanGestureRecognizer{
            pan(panGesture)
        }
    }
    
    private func pan(gesture:UIPanGestureRecognizer){
        if self.gestureEnabled{
            
            if let gestureView = gesture.view{
                
                var translation = gesture.translationInView(gestureView)
                
                if abs(self.beforePoint.x) > 0.0 || abs(self.beforePoint.y) > 0.0{
                    translation = CGPointMake(self.beforePoint.x + translation.x, self.beforePoint.y + translation.y)
                }
                
                switch gesture.state{
                case .Changed:
                    let scaleTransform = CGAffineTransformMakeScale(self.currentScale, self.currentScale)
                    let translationTransform = CGAffineTransformMakeTranslation(translation.x, translation.y)
                    self.transform = CGAffineTransformConcat(scaleTransform, translationTransform)
                case .Ended , .Cancelled:
                    self.beforePoint = translation
                default:
                    NSLog("no action")
                }
            }
        }
    }
    
    private func tap(gesture:UITapGestureRecognizer){
        if self.gestureEnabled{
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.beforePoint = CGPointMake(0.0, 0.0)
                self.currentScale = 1.0
                self.transform = CGAffineTransformIdentity
            })
        }
    }
    
    private func pinch(gesture:UIPinchGestureRecognizer){
        
        if self.gestureEnabled{
            
            var scale = gesture.scale
            if self.currentScale > 1.0{
                scale = self.currentScale + (scale - 1.0)
            }
            switch gesture.state{
            case .Changed:
                let scaleTransform = CGAffineTransformMakeScale(scale, scale)
                let transitionTransform = CGAffineTransformMakeTranslation(self.beforePoint.x, self.beforePoint.y)
                self.transform = CGAffineTransformConcat(scaleTransform, transitionTransform)
            case .Ended , .Cancelled:
                if scale <= 1.0{
                    self.currentScale = 1.0
                    self.transform = CGAffineTransformIdentity
                }else{
                    self.currentScale = scale
                }
            default:
                NSLog("not action")
            }
        }
    }
}