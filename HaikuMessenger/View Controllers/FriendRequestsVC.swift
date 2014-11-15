//
//  FriendRequestsVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 12/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

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
		
		// get requests
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
		
		// ON MAIN THREAD!
		fromUser.fetchIfNeeded()
		
		// configure cell
		cell.textLabel.text = fromUser.username
		
		return cell
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
}
