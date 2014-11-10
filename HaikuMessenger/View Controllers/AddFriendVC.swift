//
//  AddFriendVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

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
		
		var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
		
		// current search result
		let result = searchResults[indexPath.row]
		
		// configure cell
		cell.textLabel.text = result.username
		cell.detailTextLabel!.text = result.email
		
		return cell
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:                TABLE VIEW DELEGATE
	// ------------------------------------------------------------------
	
}
