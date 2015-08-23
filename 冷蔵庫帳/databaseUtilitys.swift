//
//  databaseUtilitys.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/18.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//

import Foundation

class databaseUtilitys {
    var setdatapath:String{
        get{
            let documentsFolder = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            let _path = documentsFolder[0] + "/app.db"
            
            return _path
        }
    }
}