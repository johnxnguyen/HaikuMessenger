//
//  FriendsVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var requestsButton: UIButton!
	
	var friends: [PFUser] = [] {
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
		
		requestsButton.enabled = false
		
		// get friends list if needed
		if friends.isEmpty {
			// safeguard against empty property
			let objects: AnyObject? = PFUser.currentUser().objectForKey(kUser.Friends)
			
			if objects != nil {
				
				PFUser.fetchAllInBackground(objects as [PFUser], block: {
					(fetchedObjects: [AnyObject]!, error: NSError!) -> Void in
					
					if error == nil {
						self.friends = fetchedObjects as [PFUser]
					} else {
						println("Error: \(error.userInfo)")
					}
				})
				
				
				
			}
		}
		
		// get requests
		let query = PFQuery(className: kFriendRequest.ClassKey)
		query.whereKey(kFriendRequest.ToUser, equalTo: PFUser.currentUser())
		query.countObjectsInBackgroundWithTarget(self, selector: "callbackWithResult:error:")
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	@IBAction func addBarButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("AddFriendSegue", sender: nil)
		
	}
	
	@IBAction func showRequestsBarButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("FriendRequestsSegue", sender: self)
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:             TABLE VIEW DATA SOURCE
	// ------------------------------------------------------------------
	
	// NUMBER OF SECTIONS
	//
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	// NUMBER OF ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return friends.count
	}
	
	// CELL FOR ROW
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		
		let friend = friends[indexPath.row]
		
		// configure cell
		cell.textLabel.text = friend.username
		
		return cell
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:               TABLE VIEW DELEGATE
	// ------------------------------------------------------------------

	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// PFQUERY CALLBACK
	//
	func callbackWithResult(results: NSNumber!, error: NSError!) {
		// success
		if error == nil {
			
			let number = results as Int
			
			if number > 0 {
				requestsButton.enabled = true
				
				if results == 1 {
					requestsButton.setTitle("\(number) Request", forState: UIControlState.Normal)
				} else {
					requestsButton.setTitle("\(number) Requests", forState: UIControlState.Normal)
				}
			} else {
				requestsButton.enabled = false
			}
			
		} else {
			println("Error: \(error.userInfo)")
		}
	}
	
}
