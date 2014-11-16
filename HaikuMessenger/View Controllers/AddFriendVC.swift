//
//  AddFriendVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	-------------------------- TO DO -----------------------------
//
//	- Case insensitive searching
//	
//
//	--------------------------------------------------------------

import UIKit

class AddFriendVC: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	@IBOutlet weak var searchBar: UISearchBar!
	@IBOutlet weak var tableView: UITableView!
	
	// the data source for the table view
	var searchResults: [PFUser] = [] {
		didSet {
			// whenever data changes
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
		
		searchBar.delegate = self
		tableView.delegate = self
		tableView.dataSource = self
		
		
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	@IBAction func cancelButtonTapped(sender: UIButton) {
		
		dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func doneButtonTapped(sender: UIButton) {
	}
	
	// CELL BUTTON
	//
	func cellButtonTapped(sender: UIButton) {
		
		// NOTE: EFFICIENT? PERHAPS STORE THE LIST OF NAMES FOR QUICK ACCESS
		
		let indexPath = NSIndexPath(forRow: sender.tag, inSection: 0)
		let cell = tableView.cellForRowAtIndexPath(indexPath)
		
		if cell != nil {
			
			println("Requesting friendship with: \(cell!.textLabel.text!)")
			
			let requestedUser = searchResults[sender.tag]
			
			// sends friend request & notification
			makeFriendRequest(requestedUser)
			
//			var me = PFUser.currentUser()
			
			// add as friend for me and them
//			me.addObject(requestedUser, forKey: kUser.friends)
//			me.saveInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
//				
//				if error == nil {
//					println("Successfully added friend: \(requestedUser.username)")
//				} else {
//					println("Error: \(error)")
//				}
//			})
//			requestedUser.addObject(me, forKey: kUser.friends)
//			requestedUser.saveInBackground()
			
		}
		
	}
	
	// ------------------------------------------------------------------
	//	MARK:               SEARCH BAR DELEGATE
	// ------------------------------------------------------------------
	
	func searchBarSearchButtonClicked(searchBar: UISearchBar) {
		
		var query = PFUser.query()
		query.whereKey("username", containsString: searchBar.text)
		
		query.findObjectsInBackgroundWithBlock {
			(objects: [AnyObject]!, error: NSError!) -> Void in
			
			// success
			if error == nil {
				
				println("\(objects.count) users found!")
				
				// store results
				self.searchResults = objects as [PFUser]
				
			} else {
				println(error.userInfo!)
			}
		}
	}
	
	// ------------------------------------------------------------------
	//	MARK:               TABLE VIEW DATA SOURCE
	// ------------------------------------------------------------------
	
	// NUMBER OF SECTIONS
	//
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	// NUMBER OF ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return searchResults.count
	}
	
	// CELL FOR ROW
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as AddFriendTableCell
		
		// current search result
		let result = searchResults[indexPath.row]
		
		// configure cell
		cell.textLabel.text = result.username
		cell.detailTextLabel!.text = result.email
		
		// tag button
		cell.button.tag = indexPath.row
		
		// set target (IS THIS EFFICIENT?)
		cell.button.addTarget(self, action: "cellButtonTapped:", forControlEvents: .TouchUpInside)
		
		return cell
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:                TABLE VIEW DELEGATE
	// ------------------------------------------------------------------
	
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// MAKE FRIEND REQUEST
	//
	func makeFriendRequest(toUser: PFUser) {
		
		var request = PFObject(className: kFriendRequest.ClassKey)
		request[kFriendRequest.FromUser] = PFUser.currentUser()
		request[kFriendRequest.ToUser] = toUser
		request[kFriendRequest.StatusKey] = kFriendRequest.StatusPending
		
		request.saveInBackgroundWithBlock({
			(success: Bool!, error: NSError!) -> Void in
			
			if error == nil {
				println("Request successfully made")
				
				// save friend request
				PFUser.currentUser().addUniqueObject(request, forKey: kUser.FriendRequests)
				PFUser.currentUser().saveInBackground()
				
				// notify receiver of request
//				self.sendNotification(toUser)
				
			} else {
				println("Error: \(error)")
			}
		})
	}
	
	// SEND NOTIFICATION
	//
//	func sendNotification(toUser: PFUser) {
//		
//		var notification = PFObject(className: kNotification.classKey)
//		notification[kNotification.toUser] = toUser
//		notification[kNotification.message] = "You have received a friend request from \(PFUser.currentUser().username)"
//		notification[kNotification.stateKey] = kNotification.stateActive
//		
//		notification.saveInBackgroundWithBlock({
//			(success: Bool!, error: NSError!) -> Void in
//			
//			if error == nil {
//				println("A notification was sent to \(toUser.username)")
//				
//				// save notification
//				toUser.addObject(notification, forKey: kUser.notifications)
//				toUser.saveInBackground()
//				
//			} else {
//				println("Error: \(error)")
//			}
//		})
//	}
}
