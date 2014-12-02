//
//  FriendsVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

/*	NOTES	

- what happens when a user is deleted? how sync your friends
- optimise images
- Friend no longer added after request accepted. need to sync friends with store

*/




import UIKit


class FriendsVC: PFQueryTableViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	
	@IBOutlet weak var requestsButton: UIButton!
	
	var newFriendRequestsCount: Int = 0 {
		didSet {
			updateFriendRequestsButton()
		}
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	
	// INIT
	//
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// class name to query
		parseClassName = "_User"
		
		// key to display in cell label
		textKey = "username"
		
		// image key
		imageKey = kUser.ProfilePhoto
		
		// place holder image
		placeholderImage = UIImage(named: "defaultProfilePic")
		
		// enable pull to refresh
		pullToRefreshEnabled = true
		
		// pagination?
		paginationEnabled = false
		
	}
	
	// VIEW WILL APPEAR
	//
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		loadObjects()
		
		// check for new friend requests
		checkForFriendRequests()
	}
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set menu bar button item
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
		// set add bar button item
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addBarButtonTapped:")
		// set title
		navigationItem.title = "Friends"
		
		// set the gesture (swipe to reveal menu)
		self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
	}
	
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	@IBAction func showRequestsBarButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("FriendRequestsSegue", sender: self)
	}
	
	// ADD BAR BUTTON
	//
	func addBarButtonTapped(sender: UIBarButtonItem) {
		
		performSegueWithIdentifier("AddFriendSegue", sender: nil)
	}
	
	// ------------------------------------------------------------------
	//	MARK:             TABLE VIEW DATA SOURCE
	// ------------------------------------------------------------------
	
	override func queryForTable() -> PFQuery! {
		
		let relation = PFUser.currentUser().relationForKey(kUser.Friends)
		let query = relation.query()
//		query.cachePolicy = kPFCachePolicyCacheElseNetwork
		return query
	}
	
	// CELL FOR ROW
	//
	override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!, object: PFObject!) -> PFTableViewCell! {
		
		let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as CustomCell
		
		let friend = object as PFUser
		
		cell.textLabel.text = friend.username
		cell.profileImageView.image = UIImage(named: "defaultProfilePic")
		cell.profileImageView.file = friend[kUser.ProfilePhoto] as PFFile
		cell.profileImageView.loadInBackground()
		
		return cell
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:               TABLE VIEW DELEGATE
	// ------------------------------------------------------------------

	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// CHECK FOR FRIEND REQUEST
	//
	func checkForFriendRequests() {
		
		// friend requests for current user not yet seen
		let query = PFQuery(className: kFriendRequest.Class)
		query.whereKey(kFriendRequest.ToUser, equalTo: PFUser.currentUser())
		query.whereKey(kFriendRequest.MarkedAsRead, equalTo: false)
		query.countObjectsInBackgroundWithBlock { (count: Int32, error: NSError!) -> Void in
			
			if error == nil {
				self.newFriendRequestsCount = Int(count)
				
			} else {
				println("Error: \(error.userInfo)")
			}
		}
	}
	
	// UPDATE FRIEND REQUEST BUTTON
	//
	func updateFriendRequestsButton() {
		
		if newFriendRequestsCount > 0 {
			
			requestsButton.enabled = true
			
			if newFriendRequestsCount == 1 {
				requestsButton.setTitle("\(newFriendRequestsCount) Request", forState: UIControlState.Normal)
			} else {
				requestsButton.setTitle("\(newFriendRequestsCount) Requests", forState: UIControlState.Normal)
			}
			
		} else {
			requestsButton.enabled = false
		}
	}
	
	
}
