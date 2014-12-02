//
//  Contants.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 11/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import Foundation


// PARSE OBJECT KEYS //

// column keys
let kFriendRequest = (			Class: "FriendRequest",
							 FromUser: "fromUser",
							   ToUser: "toUser",
							   Status: "status",
						 MarkedAsRead: "markedAsRead")

// constant values
let kFriendRequestStatus = ( Accepted: "accepted",
							 Declined: "declined",
							  Pending: "pending")

let kUserNotification = (	ClassKey: "UserNotification",
							FromUser: "fromUser",
							  ToUser: "toUser",
							 Message: "message",
						MarkedAsRead: "markedAsRead")

	
let kUser = (			 Profile: "profile",
					ProfilePhoto: "ProfilePhoto",
						 Friends: "friends")


// VIEW CONTROLLER STORYBOARD/RESTORATION IDS //

let kViewControllerID = ( Inbox: "InboxViewController",
						Friends: "FriendsViewController",
						Message: "MessageViewController")
