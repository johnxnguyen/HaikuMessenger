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


class FriendsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var tableView: UITableView!
	@IBOutlet weak var requestsButton: UIButton!
	
	var friends: [StoredFriend]? {

		didSet {
			tableView.reloadData()
		}
	}
	
	var newFriendRequestsCount: Int = 0 {
		
		didSet {
			updateFriendRequestsButton()
		}
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW WILL APPEAR
	//
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// keep friend list synced
		updateParseFriendsList()
		
		// get friends from store
		let coreDataManager = CoreDataManager()
		friends = coreDataManager.friendsForUserWithId(PFUser.currentUser().objectId)
		
		// check for new friend requests
		checkForFriendRequests()
	}
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
		requestsButton.hidden = true
		
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
	
	// NUMBER OF SECTIONS
	//
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	// NUMBER OF ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if friends != nil {
			return friends!.count
			
		} else {
			return 0
		}
	}
	
	// CELL FOR ROW
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as FriendCell
		
		let friend = friends![indexPath.row]
		
		// configure cell
		cell.textLabel.text = friend.username
		cell.imageView.image = UIImage(data: friend.profileImage)
		
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
		let query = PFQuery(className: kFriendRequest.ClassKey)
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
			
			requestsButton.hidden = false
			requestsButton.enabled = true
			
			if newFriendRequestsCount == 1 {
				requestsButton.setTitle("\(newFriendRequestsCount) Request", forState: UIControlState.Normal)
			} else {
				requestsButton.setTitle("\(newFriendRequestsCount) Requests", forState: UIControlState.Normal)
			}
			
		} else {
			
			requestsButton.hidden = true
			requestsButton.enabled = false
		}
	}
	
	// UPDATE PARSE FRIENDS LIST - sync accepted requests with users friend
	//
	func updateParseFriendsList() {
		
		// fetch all accepted friend requests to you
		let query1 = PFQuery(className: kFriendRequest.ClassKey)
		query1.whereKey(kFriendRequest.ToUser, equalTo: PFUser.currentUser())
		query1.whereKey(kFriendRequest.StatusKey, equalTo: kFriendRequest.StatusAccepted)
		
		// fetch all accepted friend requests from you
		let query2 = PFQuery(className: kFriendRequest.ClassKey)
		query2.whereKey(kFriendRequest.FromUser, equalTo: PFUser.currentUser())
		query2.whereKey(kFriendRequest.StatusKey, equalTo: kFriendRequest.StatusAccepted)
		
		// combine requests (query1 || query2)
		let combinedQuery = PFQuery.orQueryWithSubqueries([query1, query2])
		
		// find objects
		combinedQuery.findObjectsInBackgroundWithBlock {
			(results: [AnyObject]!, error: NSError!) -> Void in
			
			// success
			if error == nil {
				
				// hold approved friends
				var approvedFriends: [PFUser] = []
				
				// for each friendRequest
				for request in results {
					
					let toUser = request[kFriendRequest.ToUser] as PFUser
					let fromUser = request[kFriendRequest.FromUser] as PFUser
					
					// if current user is toUser
					if toUser.objectId == PFUser.currentUser().objectId {
						// add fromUser
						approvedFriends.append(fromUser)
						
					// if current user is fromUser
					} else if fromUser.objectId == PFUser.currentUser().objectId {
						// add toUser
						approvedFriends.append(toUser)
					}
				}
				
				// save only new
				PFUser.currentUser().addUniqueObjectsFromArray(approvedFriends, forKey: kUser.Friends)
				PFUser.currentUser().saveInBackground()
				
			} else {
				println("Parse Error: \(error.userInfo)")
			}
		}
	}
	
	
}
