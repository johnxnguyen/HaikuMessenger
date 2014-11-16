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

*/




import UIKit

class FriendsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	@IBOutlet weak var sideBarButton: UIBarButtonItem!
	
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
		
		// set the side bar action, when tapped, show the side bar
		sideBarButton.target = self.revealViewController()
		sideBarButton.action = "revealToggle:"
		sideBarButton.tintColor = UIColor.whiteColor()
		
		// set the gesture
		self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		
		tableView.dataSource = self
		tableView.delegate = self
		
		
			
		requestsButton.enabled = false
		
		syncFriends()
		
		
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
		
		var cell = tableView.dequeueReusableCellWithIdentifier("FriendCell") as FriendCell
		
		let friend = friends[indexPath.row]
		let imageData = friend[kUser.ProfilePhoto] as PFFile
		
		imageData.getDataInBackgroundWithBlock { (data: NSData!, error: NSError!) -> Void in
			
			if error == nil {
				cell.imageView.image = UIImage(data: data)
			}
		}
		
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
	
	// SYNC FRIENDS
	//
	func syncFriends() {
		
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
		
		combinedQuery.findObjectsInBackgroundWithBlock {
			(results: [AnyObject]!, error: NSError!) -> Void in
			
			if error == nil {
				
				
				var approvedFriends: [PFUser] = []
				
				// for each friendRequest
				for request in results {
					
					let toUser = request[kFriendRequest.ToUser] as PFUser
					let fromUser = request[kFriendRequest.FromUser] as PFUser
					
					// if current user is toUser
					if toUser.objectId == PFUser.currentUser().objectId {
						approvedFriends.append(fromUser)
						
					// if current user is fromUser
					} else if fromUser.objectId == PFUser.currentUser().objectId {
						approvedFriends.append(toUser)
					}
				}
				
				println("Number of approved friends: \(approvedFriends.count)")
				
				// store friends
				//self.friends = approvedFriends
				PFUser.currentUser().addUniqueObjectsFromArray(approvedFriends, forKey: kUser.Friends)
				PFUser.currentUser().saveInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
					
					if error == nil {
						
						self.fetchFriendDataIfNeeded()
					}
				})
				
			} else {
				println("Error: \(error.userInfo)")
			}
			
		}
	}
	
	// FETCH FRIEND DATA IF NEEDED
	//
	func fetchFriendDataIfNeeded() {
		
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
	}
	
	
}
