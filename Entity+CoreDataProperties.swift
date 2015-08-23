//
//  Entity+CoreDataProperties.swift
//  冷蔵庫帳
//
//  Created by 早坂彪流 on 2015/08/14.
//  Copyright © 2015年 早坂彪流. All rights reserved.
//
//  Delete this file and regenerate it using "Create NSManagedObject Subclass…"
//  to keep your implementation up to date with your model.
//

import Foundation
import CoreData

extension Entity {

    @NSManaged var id: NSNumber?
    @NSManaged var name: String?
    @NSManaged var attribute: NSDate?

}
