//
//  CoreDataManager.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 20/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit
import CoreData


class CoreDataManager: NSObject {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	let kEntityName = (StoredUser: "StoredUser", StoredFriend: "StoredFriend")
	
	// lazy load moc
	var moc: NSManagedObjectContext? = {
		
		let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
		
		if let managedObjectContext = appDelegate.managedObjectContext {
			return managedObjectContext
		} else {
			return nil
		}
	}()
	
	// ------------------------------------------------------------------
	//	MARK:				    FUNCTIONS
	// ------------------------------------------------------------------
	
	// USER FOR ID
	//
	func userForId(id: String) -> StoredUser? {
		
		// request user
		let request = NSFetchRequest(entityName: kEntityName.StoredUser)
		let predicate = NSPredicate(format: "id = %@", argumentArray: [id])
		request.predicate = predicate
		
		var error: NSError?
		
		// execute request
		let results = moc!.executeFetchRequest(request, error: &error) as [StoredUser]?
		
		// if objects found
		if results != nil {
			
			// there should only be one user for id
			if results!.count == 1 {
				return results!.first
				
			} else if results!.count == 0 {
				println("CoreData Error: couldnt find user for id: \(id)")
				
			} else {
				println("CoreData Error: Fetched more than one StoredUser (should be unique)")
			}
			
		} else {
			println("CoreData Error: \(error!.userInfo)")
		}
		
		return nil
	}
	
	// STORE USER
	//
	func storeUser(user: PFUser, withImage imageData: NSData) -> Bool {
		
		// create user
		let entityDescription = NSEntityDescription.entityForName(kEntityName.StoredUser, inManagedObjectContext: moc!)
		var storedUser = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: moc!) as StoredUser
		
		// set properties
		storedUser.id = user.objectId
		storedUser.username = user.username
		storedUser.password = user.password
		storedUser.email = user.email
		storedUser.profileImage = imageData
		
		var error: NSError?
		
		// save
		if moc!.save(&error) {
			println("'\(storedUser.username)' succesfully saved to CoreData")
			return true
			
		} else {
			println("CoreData Error: couldn't save '\(storedUser.username)', \(error!.userInfo)")
			return false
		}
	}
	
	// STORE FRIEND
	//
	func storeFriend(friend: PFUser, withImageData imageData: NSData, forUserWithID id: String) -> Bool {
		
		// current friend
		let entityDescription = NSEntityDescription.entityForName(kEntityName.StoredFriend, inManagedObjectContext: moc!)
		var storedFriend = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: moc!) as StoredFriend
		
		// set properties
		storedFriend.id = friend.objectId
		storedFriend.username = friend.username
		storedFriend.profileImage = imageData
		
		// set relation
		if let user = self.userForId(id) {
			storedFriend.user = user
		} else {
			println("CoreData Error: couldn't store friend '\(storedFriend.username)'")
			return false
		}
		
		var error: NSError?
		
		// save
		if moc!.save(&error) {
			println("Friend '\(storedFriend.username)' successfully saved to CoreData")
			return true
		} else {
			println("CoreData Error: couldn't friend '\(storedFriend.username)', \(error!.userInfo)")
			return false
		}
	}
	
	// FRIENDS FOR USER WITH ID
	//
	func friendsForUserWithId(id: String) -> [StoredFriend]? {
		
		// get current user
		if let currentUser = self.userForId(id) {
			
			var friends = currentUser.friends.allObjects as [StoredFriend]
			
			// order alphabetically
			friends.sort({ (x: StoredFriend, y: StoredFriend) -> Bool in
				
				x.username < y.username ? true : false
			})
			
			return friends
			
		} else {
			println("CoreData Error: couldn't get friends")
			return nil
		}
	}
	
	// DELETE USER
	//
	func deleteUser(user: PFUser) {
		
	}
	
	// SYNC USER
	//
	func syncUser(user: PFUser) {
		
	}
	
	// DELETE FRIEND
	//
	func deleteFriend(friend: PFUser) {
		
	}
	
	// SYNC FRIEND
	//
	func syncFriend(friend: PFUser) {
		
	}
	
	// SYNC FRIENDS WITH PARSE
	//
	func syncFriendsWithParse(parseFriends: [PFUser], forUserID userID: String) -> Bool {
		
		// get all storedFriends for user
		let request = NSFetchRequest(entityName: kEntityName.StoredFriend)
		let predicate = NSPredicate(format: "user.id = %@", [userID])
		request.predicate = predicate
		
		var error: NSError?
		
		// execute
		if let results = moc!.executeFetchRequest(request, error: &error) {
			
			let storedFriends = results as [StoredFriend]
			
			// for each parse friend
			for parseFriend in parseFriends {
				
//				// check if already exists in storedFriends
//				if let found = find(storedFriends, parseFriend) {
//					
//				}
			}
		}
		
		
		
		return true
	}
	
	
	// PRINT USERS
	//
	func printAllUsers() {
		
		let request = NSFetchRequest(entityName: kEntityName.StoredUser)
		
		var error: NSError?
		
		let results = moc!.executeFetchRequest(request, error: &error) as [StoredUser]?
		
		if results != nil {
			
			println("Number of stored users: \(results!.count)")
			
			for index in 0..<results!.count {
				println("User \(index): \(results![index].username), friends: \(results![index].friends.count)")
			}
			
		} else {
			println("CoreData Error: \(error!.userInfo)")
		}
	}
   
}
