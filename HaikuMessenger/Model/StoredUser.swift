//
//  StoredUser.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 20/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import Foundation
import CoreData

@objc(StoredUser)

class StoredUser: NSManagedObject {

    @NSManaged var email: String
    @NSManaged var id: String
    @NSManaged var password: String
    @NSManaged var profileImage: NSData
    @NSManaged var username: String
    @NSManaged var friends: NSSet

}
