//
//  ViewController.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/16.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import UIKit
import AVFoundation
class cameViewController: UIViewController {
//Shooting_button
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Do any additional setup after loading the view.
//    }
//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var imageFoundtion_View: UIView!
    @IBOutlet weak var Shooting_button: UIButton!
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
    // セッション.
    var mySession : AVCaptureSession!
    // デバイス.
    var myDevice : AVCaptureDevice!
    // 画像のアウトプット.
    var myImageOutput : AVCaptureStillImageOutput!
    
     var previewLayer: AVCaptureVideoPreviewLayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        Shooting_button.addTarget(self, action: "onClickMyButton:", forControlEvents: UIControlEvents.TouchUpInside)
        Shooting_button.layer.masksToBounds = true
        
        // セッションの作成.
        mySession = AVCaptureSession()
        
        // デバイス一覧の取得.
        let devices = AVCaptureDevice.devices()
        
        // バックカメラをmyDeviceに格納.
        for device in devices{
            if(device.position == AVCaptureDevicePosition.Back){
                myDevice = device as! AVCaptureDevice
            }
        }
        do {
        // バックカメラからVideoInputを取得.
        let videoInput = try AVCaptureDeviceInput(device: myDevice)
            // セッションに追加.
            mySession.addInput(videoInput)
        }catch{
            
        }
      
        
        // 出力先を生成.
        myImageOutput = AVCaptureStillImageOutput()
        
        // セッションに追加.
        mySession.addOutput(myImageOutput)
        
        // 画像を表示するレイヤーを生成.
        previewLayer = AVCaptureVideoPreviewLayer(session: mySession)
       // previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        
        // Viewに追加.
        self.imageFoundtion_View.layer.addSublayer(previewLayer)
        // セッション開始.
        mySession.startRunning()
        
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer!.frame = imageFoundtion_View.bounds
    }

    // ボタンイベント.
    func onClickMyButton(sender: UIButton){
        
        // ビデオ出力に接続.
        let myVideoConnection = myImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        // 接続から画像を取得.
        self.myImageOutput.captureStillImageAsynchronouslyFromConnection(myVideoConnection, completionHandler: { (imageDataBuffer, error) -> Void in
            
            // 取得したImageのDataBufferをJpegに変換.
            let myImageData : NSData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
            
            // JpegからUIIMageを作成.
            let myImage : UIImage = UIImage(data: myImageData)!
            
            let adddataImage = UIImagePNGRepresentation(myImage)
            let db = FMDatabase(path: databaseUtilitys().setdatapath)
            let datetimenow = NSDate()
            let sql = "INSERT INTO imageTabel (image,now_Datetime) VALUES (?,?);"
            
            db.open()
            db.executeUpdate(sql, withArgumentsInArray: [adddataImage!,datetimenow])
            db.close()
            self.performSegueWithIdentifier("Came_to_SelectIOImageView", sender: self)
            // アルバムに追加.
            //UIImageWriteToSavedPhotosimageIOVieAlbum(myImage, self, nil, nil)
            
        })
       
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      
    }
    @IBAction func ReturntoCollctionReceiptView_to_ImagePview(segue:UIStoryboardSegue){
    
    }
}


