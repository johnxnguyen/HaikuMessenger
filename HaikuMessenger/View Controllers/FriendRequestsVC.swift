//
//  FriendRequestsVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 12/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	NOTE:
//
//	the friend request PFObject is shared between two users. If the request
//	is set to accepted, the original sender will be notified and will add
//	the current user as a friend on their side. When a user accepts a request
//	the sender of the request is added as the time of acceptance. The requests 
//	are not deleted as they are needed to keep the friend lists sync on both sides

import UIKit

class FriendRequestsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var tableView: UITableView!
	
	var requests: [PFObject] = [] {
		
		didSet {
			tableView.reloadData()
		}
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
		// get friend requests
		let query = PFQuery(className: kFriendRequest.ClassKey)
		query.whereKey(kFriendRequest.ToUser, equalTo: PFUser.currentUser())
		query.findObjectsInBackgroundWithTarget(self, selector: "callbackWithResult:error:")
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:               TABLEVIEW DATA SOURCE
	// ------------------------------------------------------------------
	
	// SECTIONS
	//
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	// ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return requests.count
	}
	
	// CELL FOR ROW
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		let request = requests[indexPath.row]
		let fromUser = request[kFriendRequest.FromUser] as PFUser
		
		// fetch (but what if it isn't needed?
		fromUser.fetchIfNeededInBackgroundWithBlock {
			(object: PFObject!, error: NSError!) -> Void in
			
			if error == nil {
				cell.textLabel.text = fromUser.username
			} else {
				println("Error: \(error.userInfo!)")
			}
		}

		return cell
	}
	
	// ------------------------------------------------------------------
	//	MARK:               TABLE VIEW DELEGATE
	// ------------------------------------------------------------------
	
	// DID SELECT
	//
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		
		// accept friendship
		let friendRequest = requests[indexPath.row]
		friendRequest[kFriendRequest.StatusKey] = kFriendRequest.StatusAccepted
		friendRequest[kFriendRequest.MarkedAsRead] = true
		
		// save friendRequest
		friendRequest.saveInBackgroundWithBlock { (success: Bool!, error: NSError!) -> Void in
			
			// success
			if error == nil {
				
				let friend = friendRequest[kFriendRequest.FromUser] as PFUser
				
				println("You have accepted a \(friend.username)'s friend request")
				
				// send notification
				self.sendUserNotificationToUser(friend)
				self.sendSystemNotificationToUser(friend)
				
			} else {
				println("Parse Error: \(error.userInfo)")
			}
		}
		
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// PFQUERY CALLBACK
	//
	func callbackWithResult(results: [AnyObject]!, error: NSError!) {
		
		if error == nil {
			requests = results as [PFObject]
		} else {
			println("Error: \(error.userInfo)")
		}
	}
	
	// SEND USER NOTIFICATION
	//
	func sendUserNotificationToUser(user: PFUser) {
		
		let fromUser = PFUser.currentUser()
		
		var notification = PFObject(className: kUserNotification.ClassKey)
		notification[kUserNotification.FromUser] = fromUser
		notification[kUserNotification.ToUser] = user
		notification[kUserNotification.Message] = "\(fromUser.username) has accepted your friend request"
		notification[kUserNotification.MarkedAsRead] = false
		
		notification.saveInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
			
			if error == nil {
				println("User Notification sent!")
			} else {
				println("Error: \(error.userInfo)")
			}
		})
	}
	
	// SEND SYSTEM NOTIFICATION
	//
	func sendSystemNotificationToUser(user: PFUser) {
		
		var notification = PFObject(className: kSystemNotification.ClassKey)
		notification[kSystemNotification.FromUser] = PFUser.currentUser()
		notification[kSystemNotification.ToUser] = user
		notification[kSystemNotification.TypeKey] = kSystemNotification.TypeFriendRequestAccepted
		notification[kSystemNotification.MarkedAsRead] = false
		
		notification.saveInBackgroundWithBlock { (success: Bool!, error: NSError!) -> Void in
			
			if error == nil {
				println("System Notification sent!")
			} else {
				println("Error: \(error.userInfo)")
			}
		}
	}
}
