//
//  ParseManager.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 30/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	NOTE:
//
//	singleton code taken from http://code.martinrue.com/posts/the-singleton-pattern-in-swift

struct Friend {
	
	var username: String
	var pic: UIImage
}

import UIKit

class ParseManager: NSObject {
	
	// Swift Singleton
	class var sharedInstance: ParseManager {
		
		struct Static {
			static var instance: ParseManager?
			static var token: dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			Static.instance = ParseManager()
		}
		
		return Static.instance!
	}
	
	// cached data
	var currentUser: PFUser?
	var friends: [Friend]?
	
	// functions
	func loadData() {
		
		self.currentUser = PFUser.currentUser()
		
		// query for friends
		let relation = self.currentUser!.relationForKey(kUser.Friends)
		let query = relation.query()
		
		// execute query
		query.findObjectsInBackgroundWithBlock {
			(objects: [AnyObject]!, error: NSError!) -> Void in
			
			// success
			if error == nil {
				
				// empty
				self.friends = []
				
				let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
				
				// ASYNC
				dispatch_async(queue) {
					
					// repopulate
					for friend in objects {
						
						let username = (friend as PFUser).username
						let imageFile = friend[kUser.ProfilePhoto] as PFFile
						let imageData = imageFile.getData()
						self.friends!.append(Friend(username: username, pic: UIImage(data: imageData)!))
					}
					
					// sort array
					self.friends!.sort({ (x: Friend, y: Friend) -> Bool in
						return x.username < y.username
					})
				}
			}
		}
	}
	
	func addFriendWithId(id: String) {
		
		// get the user
		let query = PFUser.query()
		query.getObjectInBackgroundWithId(id, block: { (object: PFObject!, error: NSError!) -> Void in
			
			// success
			if error == nil {
				
				let friend = object as PFUser
				
				// get profile pic
				let imageFile = friend[kUser.ProfilePhoto] as PFFile
				imageFile.getDataInBackgroundWithBlock({ (data: NSData!, error: NSError!) -> Void in
					
					// success
					if error == nil {
						// append to friends
						self.friends!.append(Friend(username: friend.username, pic: UIImage(data: data)!))
						
						// reorder
						self.friends!.sort({ (x: Friend, y: Friend) -> Bool in
							return x.username < y.username
						})
						
					} else {
						println("Parse Error: \(error.userInfo)")
					}
				})
			} else {
				println("Parse Error: \(error.userInfo)")
			}
		})
	}
	
	// DID LOG IN
	//
	func didLogin() {
		
		println("User logged in")
		
		// sync user to current installation
		let installation = PFInstallation.currentInstallation()
		installation["user"] = PFUser.currentUser()
		installation.saveInBackground()
		
		self.loadData()
	}
	
	// DID LOG OUT
	//
	func didLogout() {
		
		println("User logged out")

		// clear cache
		self.currentUser = nil
		self.friends = nil
	}

   
}
