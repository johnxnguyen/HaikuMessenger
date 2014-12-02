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
		
		// remove search bar border
		searchBar.backgroundImage = UIImage()
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
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
		
		var friendRequest = PFObject(className: kFriendRequest.Class)
		friendRequest[kFriendRequest.FromUser] = PFUser.currentUser()
		friendRequest[kFriendRequest.ToUser] = toUser
		friendRequest[kFriendRequest.Status] = kFriendRequestStatus.Pending
		friendRequest[kFriendRequest.MarkedAsRead] = false
		
		friendRequest.saveInBackgroundWithBlock({
			(success: Bool!, error: NSError!) -> Void in
			
			if error == nil {
				println("Request successfully made")
				
			} else {
				println("Error: \(error)")
			}
		})
	}
	
	// SEND USER NOTIFICATION
	//
	func sendUserNotification(toUser: PFUser) {
		
		var notification = PFObject(className: kUserNotification.ClassKey)
		notification[kUserNotification.FromUser] = PFUser.currentUser()
		notification[kUserNotification.ToUser] = toUser
		notification[kUserNotification.Message] = "You have received a friend request from \(PFUser.currentUser().username)"
		notification[kUserNotification.MarkedAsRead] = false
		
		
		notification.saveInBackgroundWithBlock({
			(success: Bool!, error: NSError!) -> Void in
			
			if error == nil {
				println("A user notification was sent to \(toUser.username)")

			} else {
				println("Error: \(error.userInfo)")
			}
		})
	}
}
