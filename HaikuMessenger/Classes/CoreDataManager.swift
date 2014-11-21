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
	//	MARK:				  CLASS FUNCTIONS
	// ------------------------------------------------------------------
	
	// STORE USER
	//
	func storeUser(user: PFUser, withImage imageData: NSData) {
		
		let entityDescription = NSEntityDescription.entityForName(kEntityName.StoredUser, inManagedObjectContext: moc!)
		var storedUser = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: moc!) as StoredUser
		
		storedUser.id = user.objectId
		storedUser.username = user.username
		storedUser.password = user.password
		storedUser.email = user.email
		storedUser.profileImage = imageData
		
		var error: NSError?
		
		if moc!.save(&error) {
			println("User succesfully saved to CoreData")
		} else {
			println("Error: couldn't save user to CoreData, \(error!.userInfo)")
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
	
	
	// STORE FRIEND
	//
	func storeFriend(friend: PFUser, forUserWithID id: String) -> Bool {
		
		// fetch friend
		friend.fetchIfNeeded()
		
		// current user
		let entityDescription = NSEntityDescription.entityForName(kEntityName.StoredFriend, inManagedObjectContext: moc!)
		var storedFriend = NSManagedObject(entity: entityDescription!, insertIntoManagedObjectContext: moc!) as StoredFriend
		
		storedFriend.id = friend.objectId
		storedFriend.username = friend.username
		storedFriend.email = friend.email
		
		// MAIN THREAD!
		storedFriend.profileImage  = friend[kUser.ProfilePhoto].getData()
		
		// set relation
		let user = self.userForId(id)
		
		if user != nil {
			storedFriend.user = user!
			
		}
		
		var error: NSError?
		
		if moc!.save(&error) {
			println("Friend successfully saved")
			return true
		} else {
			println("Error: couldn't save friend to CoreData, \(error!.userInfo)")
			return false
		}
	}
	
	
	// DELETE FRIEND
	//
	func deleteFriend(friend: PFUser) {
		
	}
	
	// SYNC FRIEND
	//
	func syncFriend(friend: PFUser) {
		
	}
	
	
	// SYNC ALL FRIENDS
	//
	class func syncAllFriends(friends: [PFUser]) {
		
	}
	
	// USER FOR ID
	//
	func userForId(id: String) -> StoredUser? {
		
		let request = NSFetchRequest(entityName: kEntityName.StoredUser)
		let predicate = NSPredicate(format: "id = %@", argumentArray: [id])
		request.predicate = predicate
		
		var error: NSError?
		
		let results = moc!.executeFetchRequest(request, error: &error) as [StoredUser]?
		
		if results != nil {
			if results!.count == 1 {
				println("Returning: \(results!.first!.username)")
				return results!.first
				
			} else if results!.count == 0 {
				println("Error: couldnt find user for id: \(id)")
			} else {
				println("Error: Fetched more than one StoredUser (should be unique)")
			}
		} else {
			println("CoreData Error: \(error!.userInfo)")
		}
		
		return nil
	}
	
	// FRIENDS FOR USER WITH ID
	//
	func friendsForUserWithId(id: String) -> [StoredFriend]? {
		
		let currentStoredUser = self.userForId(id)
		
		if currentStoredUser != nil {
			
			var friends = currentStoredUser!.friends.allObjects as [StoredFriend]
			
			// order alphabetically
			friends.sort({ (x: StoredFriend, y: StoredFriend) -> Bool in
				
				x.username < y.username ? true : false
			})
			
			return friends
			
		} else {
			return nil
		}
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
