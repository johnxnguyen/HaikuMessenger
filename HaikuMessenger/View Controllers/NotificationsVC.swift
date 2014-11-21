//
//  NotificationsVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 21/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------

	@IBOutlet weak var tableView: UITableView!
	
	var notifications: [PFObject] = [] {
		
		didSet {
			tableView.reloadData()
		}
	}

	// ------------------------------------------------------------------
	//	MARK:						STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// set menu bar button item
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
		// set title
		navigationItem.title = "Notifications"

		// set the gesture (swipe to reveal menu)
		self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		
		tableView.dataSource = self
		tableView.delegate = self
		
		// get notifications
		getNotifications()
		
		
    }
	
	// MEMORY WARNING
	//
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
		return notifications.count
	}
	
	// CELL
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		
		let notification = notifications[indexPath.row]
		
		// configure cell
		cell.textLabel.text = notification[kUserNotification.Message] as? String
		
		return cell
	}
	
	
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// GET NOTIFICATIONS
	//
	func getNotifications() {
		
		let query = PFQuery(className: kUserNotification.ClassKey)
		query.whereKey(kUserNotification.ToUser, equalTo: PFUser.currentUser())
		query.whereKey(kUserNotification.MarkedAsRead, equalTo: false)
		
		query.findObjectsInBackgroundWithBlock {
			(objects: [AnyObject]!, error: NSError!) -> Void in
			
			if error == nil {
				self.notifications = objects as [PFObject]
				
				// order newest to oldest
				self.notifications.sort({ (x: PFObject, y: PFObject) -> Bool in
					
					if x.createdAt.timeIntervalSinceNow > y.createdAt.timeIntervalSinceNow {
						return true
					} else {
						return false
					}
				})
				
			} else {
				println("Error: \(error.userInfo)")
			}
		}
	}
}
