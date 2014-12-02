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
	@IBOutlet weak var imageView: PFImageView!
	@IBOutlet weak var tableView: UITableView!
	
	let menuItems = ["inbox", "friends", "notifications", "settings", "logout"]
	
	var userNotifications: Int = 0 {
		
		didSet {
			tableView.reloadData()
		}
	}
	
	// ------------------------------------------------------------------
	//	MARK:					  STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
		// eliminate extra separator lines
		tableView.tableFooterView = UIView(frame: CGRectZero)
		
		loadUserProfileUI()
    }
	
	// VIEW DID APPEAR
	//
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// check for notifications
		checkForUserNotifications()
		//checkForSystemNotifications()
	}
	
	// LOAD VIEW
	//
	override func loadView() {
		super.loadView()
		
		tableView.rowHeight = 44.0
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	// PREPARE FOR SEGUE - one segue, different views
	//
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)
		
		// the navigation controller for all other vc's
		if segue.identifier == "navigationSegue" {
			
			let targetVC = segue.destinationViewController as UINavigationController
			
			// will instantiate a view for the nav controller
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
			
			// load vc
			targetVC.setViewControllers([vc], animated: true)
		}
	}
	
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
	
	// CELL - different prototype cell for each menu item
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let identifier = menuItems[indexPath.row]
		let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as StandardCell
		
		// dynamic title depending on notification count
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
			
			// go to login
			dismissViewControllerAnimated(true, completion: nil)
			
		} else {
			
			// segue to depending on which item was selected
			performSegueWithIdentifier("navigationSegue", sender: item)
		}
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	var indexOfPreviouslySelectedRow: NSIndexPath?
	
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
	
	// CHECK FOR USER NOTIFICATIONS
	//
	func checkForUserNotifications() {
		
		let query = PFQuery(className: kUserNotification.ClassKey)
		query.whereKey(kUserNotification.ToUser, equalTo: PFUser.currentUser())
		query.whereKey(kUserNotification.MarkedAsRead, equalTo: false)
		
		query.countObjectsInBackgroundWithBlock { (number: Int32, error: NSError!) -> Void in
			
			if error == nil {
				
				self.userNotifications = Int(number)
				
			} else {
				println("Error: \(error.userInfo)")
			}
		}
	}
	
	// LOAD USER PROFILE UI
	//
	func loadUserProfileUI() {
		
		usernameLabel.text = PFUser.currentUser().username
		imageView.image = UIImage(named: "defaultProfilePic")
		imageView.file = PFUser.currentUser()[kUser.ProfilePhoto] as PFFile
		imageView.loadInBackground()
		
		
	}
}
