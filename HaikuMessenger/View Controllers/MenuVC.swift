//
//  MenuVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 16/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	-------------------------- TO DO -----------------------------
//
//	- If row is selected, dont allow to reload view. Simply go back
//	to the open view
//
//	- batch friend adds. gather and sort all notifications first
//
//	--------------------------------------------------------------

import UIKit


class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var usernameLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var tableView: UITableView!
	
	let menuItems = ["inbox", "friends", "notifications", "settings", "logout"]
	
	var userNotifications: Int = 0 {
		
		didSet {
			tableView.reloadData()
		}
	}
	
	var indexOfPreviouslySelectedRow: NSIndexPath?
	
	// ------------------------------------------------------------------
	//	MARK:					  STANDARD
	// ------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
		// eliminate extra separator lines
		tableView.tableFooterView = UIView(frame: CGRectZero)
		
		loadUserProfileUI()
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// check for notifications
		checkForUserNotifications()
		checkForSystemNotifications()
	}
	
	override func loadView() {
		super.loadView()
		
		tableView.rowHeight = 44.0
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)
		
		if segue.identifier == "navigationSegue" {
			
			let targetVC = segue.destinationViewController as UINavigationController
			let storyboard = self.storyboard!
			var vc: UIViewController!
			
			// identify which vc to load
			switch (sender as String) {
				
			case "inbox":
				vc = storyboard.instantiateViewControllerWithIdentifier("InboxViewController") as InboxVC
			case "friends":
				vc = storyboard.instantiateViewControllerWithIdentifier("FriendsViewController") as FriendsVC
			case "notifications":
				vc = storyboard.instantiateViewControllerWithIdentifier("NotificationsViewController") as NotificationsVC
			case "settings":
				vc = storyboard.instantiateViewControllerWithIdentifier("SettingsViewController") as SettingsVC
			default:
				println("Segue specifier not recognized, loading InboxVC as default")
				vc = storyboard.instantiateViewControllerWithIdentifier("InboxViewController") as InboxVC
			}
			
			targetVC.setViewControllers([vc], animated: true)
		}
		
		
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	

	
	// ------------------------------------------------------------------
	//	MARK:               TABLE VIEW DATASOURCE
	// ------------------------------------------------------------------
	
	// SECTIONS
	//
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	// ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuItems.count
	}
	
	// CELL
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let identifier = menuItems[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as StandardCell
		
		if identifier == "notifications" {
			if userNotifications > 0 {
				cell.textLabel.text = "Notifications: \(userNotifications)"
				
			} else {
				cell.textLabel.text = "Notifications"
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
		
		let item = menuItems[indexPath.row]
		
		// update cell states
		updateCellSelectionStates(indexPath)
		
		// if logout row
		if item == "logout" {
			
			PFUser.logOut()
			dismissViewControllerAnimated(true, completion: nil)
			
		} else {
			
			// segue to depending on which item was selected
			performSegueWithIdentifier("navigationSegue", sender: item)
		}
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// UPDATE CELL SELECTION STATES
	//
	func updateCellSelectionStates(indexPath: NSIndexPath) {
		
		// which item was selected?
		let item = menuItems[indexPath.row]
		
		// get selected cell
		var cell = tableView.cellForRowAtIndexPath(indexPath)
		
		// set active icon for selected cell
		cell!.imageView.image = UIImage(named: "\(item)_active_icon")
		
		// if there was a previously selected cell
		if indexOfPreviouslySelectedRow != nil {
			
			// set normal state icon (deselected)
			var prevItem = menuItems[indexOfPreviouslySelectedRow!.row]
			var prevCell = tableView.cellForRowAtIndexPath(indexOfPreviouslySelectedRow!)
			prevCell!.imageView.image = UIImage(named: "\(prevItem)_icon")
		}
		
		// update prev index
		indexOfPreviouslySelectedRow = indexPath
	}
	
	// CHECK FOR USER NOTOFICATIONS
	//
	func checkForUserNotifications() {
		
		let query = PFQuery(className: kUserNotification.ClassKey)
		query.whereKey(kUserNotification.ToUser, equalTo: PFUser.currentUser())
		query.whereKey(kUserNotification.MarkedAsRead, equalTo: false)
		
		query.countObjectsInBackgroundWithBlock { (number: Int32, error: NSError!) -> Void in
			
			if error == nil {
				println("You have \(number) user notification(s)")
				self.userNotifications = Int(number)
				
			} else {
				println("Error: \(error.userInfo)")
			}
		}
	}
	
	// CHECK FOR SYSTEM NOTIFICATIONS
	//
	func checkForSystemNotifications() {
		
		let query = PFQuery(className: kSystemNotification.ClassKey)
		query.whereKey(kSystemNotification.ToUser, equalTo: PFUser.currentUser())
		query.whereKey(kSystemNotification.MarkedAsRead, equalTo: false)
		
		query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
			
			if error == nil {
				
				println("You have \(objects.count) system notification(s): ")
				
				// for each notification
				for index in 0..<objects.count {
					
					let notification = objects[index] as PFObject
					
					// determine type
					let type = notification[kSystemNotification.TypeKey] as String
					
					switch type {
						
					case kSystemNotification.TypeFriendRequestSent:
						println("You have a friend request")
						
					case kSystemNotification.TypeFriendRequestAccepted:
						
						println("Someone has accepted your friend request")
						
						// the user who accepted your request
						let friend = notification[kSystemNotification.FromUser] as PFUser
						
						let coreDataManager = CoreDataManager()
						
						// store friend to CoreData
						if coreDataManager.storeFriend(friend, forUserWithID: PFUser.currentUser().objectId) == true {
							
							// change flag
							notification[kSystemNotification.MarkedAsRead] = true
							notification.saveInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
								
								if error == nil {
									println("System Notification marked as read")
								} else {
									println("Error: \(error.userInfo)")
								}
							})
							
						} else {
							println("Failed to store friend")
						}
						
					case kSystemNotification.TypeFriendUpdatedProfile:
						println("A friend has updated their profile")
						
					case kSystemNotification.TypeFriendDeleted:
						println("A friend has deleted their account")
						
					case kSystemNotification.TypeBlockedByFriend:
						println("You have been blocked by a friend")
						
					case kSystemNotification.TypeUnblockedByFriend:
						println("You have been unblocked by a friend")
						
					default:
						println("System Notification type unrecognised: \(type)")
						
					}
				}
				
			} else {
				// couldnt find notification objects
				println("Error: \(error.userInfo)")
			}
		}
	}
	
	// LOAD USER PROFILE UI
	//
	func loadUserProfileUI() {
		
		let coreDataManager = CoreDataManager()
		let currentUser = coreDataManager.userForId(PFUser.currentUser().objectId)
		
		if currentUser != nil {
			
			usernameLabel.text = currentUser!.username
			imageView.image = UIImage(data: currentUser!.profileImage)
			imageView.layer.cornerRadius = 10.0
			imageView.layer.masksToBounds = true
		}
	}
}
