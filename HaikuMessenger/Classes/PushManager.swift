//
//  PushManager.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 26/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class PushManager: NSObject {
	
	class func sendSilentNotificationToUser(userId: String, from fromUserId: String, withIdentifier identifier: String) {
		
		let parameters = [kPush.RecipientId: userId, kPush.SenderId: fromUserId, kPush.Identifier: identifier]
		
		// Send notification
		PFCloud.callFunctionInBackground("sendSilentNotificationToUser", withParameters: parameters) {
			(object: AnyObject!, error: NSError!) -> Void in
			
			if error == nil {
				
				println("Push sent!")
				
			} else {
				println("Push Error: \(error.userInfo)")
			}
		}
	}
	
}

// PUSH KEYS
let kPush = (			  SenderId: "senderId",
						   RecipientId: "recipientId",
							Identifier: "identifier")

let kPushIdentifier = ( FriendAccepted: "friendAccepted",
						 FriendUpdated: "friendUpdated",
						 FriendDeleted: "friendDeleted",
							   Blocked: "blocked",
							 Unblocked: "unblocked")

