//
//  Contants.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 11/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import Foundation


// PARSE OBJECT KEYS //

let kFriendRequest = (	ClassKey: "FriendRequest",
						FromUser: "fromUser",
						  ToUser: "toUser",
					   StatusKey: "status",
				  StatusAccepted: "accepted",
				  StatusDeclined: "declined",
				   StatusPending: "pending",
					MarkedAsRead: "markedAsRead")

let kUserNotification = (	ClassKey: "UserNotification",
							FromUser: "fromUser",
							  ToUser: "toUser",
							 Message: "message",
						MarkedAsRead: "markedAsRead")

let kSystemNotification = (	ClassKey: "SystemNotification",
							FromUser: "fromUser",
							  ToUser: "toUser",
							 TypeKey: "type",
			   TypeFriendRequestSent: "friendRequestSent",
		   TypeFriendRequestAccepted: "friendRequestAccepted",
			TypeFriendUpdatedProfile: "friendUpdatedProfile",
				   TypeFriendDeleted: "friendDeleted",
				 TypeBlockedByFriend: "blockedByFriend",
			   TypeUnblockedByFriend: "unblockedByFriend",
						MarkedAsRead: "markedAsRead")
	
let kUser = (			 Profile: "profile",
					ProfilePhoto: "ProfilePhoto",
						 Friends: "friends",
				   Notifications: "notifications",
				  FriendRequests: "friendRequests")


// VIEW CONTROLLER STORYBOARD/RESTORATION IDS //

let kViewControllerID = ( Inbox: "InboxViewController",
						Friends: "FriendsViewController",
						Message: "MessageViewController")
