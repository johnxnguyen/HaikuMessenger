//
//  Factory.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import Foundation

struct User {
	
	let username: String
	let password: String
	let email: String
	let profilePic: UIImage
}


class Factory {
	
	class func generateUsers() {
		
		let user1 = User(username: "tea", password: "tea", email: "tea@bean.com", profilePic: UIImage(named: "photo01")!)
		let user2 = User(username: "amysqrrl", password: "amysqrrl", email: "amy@bean.com", profilePic: UIImage(named: "photo02")!)
		let user3 = User(username: "soph95", password: "soph95", email: "sophie@bean.com", profilePic: UIImage(named: "photo03")!)
		let user4 = User(username: "michaelMoon", password: "michaelMoon", email: "michael@bean.com", profilePic: UIImage(named: "photo04")!)
		let user5 = User(username: "kimlouise", password: "kimlouise", email: "kim@bean.com", profilePic: UIImage(named: "photo05")!)
		let user6 = User(username: "TK", password: "TK", email: "tim@bean.com", profilePic: UIImage(named: "photo06")!)
		let user7 = User(username: "tuxxi", password: "tuxxi", email: "agata@bean.com", profilePic: UIImage(named: "photo07")!)
		let user8 = User(username: "eugi", password: "eugi", email: "eugi@bean.com", profilePic: UIImage(named: "photo08")!)
		let user9 = User(username: "vito", password: "vito", email: "vito@bean.com", profilePic: UIImage(named: "photo09")!)
		let user10 = User(username: "dmtr", password: "dmtr", email: "deme@bean.com", profilePic: UIImage(named: "photo10")!)
		let users = [user1, user2, user3, user4, user5, user6, user7, user8, user9, user10]
		
		for item in users {
			
			var newUser = PFUser()
			newUser.username = item.username
			newUser.password = item.password
			newUser.email = item.email
			newUser[kUser.ProfilePhoto] = PFFile(data: UIImageJPEGRepresentation(item.profilePic, 1.0))
			
			newUser.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
				
				// success
				if error == nil {
					println("User successfully signed up: \(newUser.username)")
					
					// save to CoreData
					let coreDataManager = CoreDataManager()
					coreDataManager.storeUser(newUser, withImage: UIImageJPEGRepresentation(item.profilePic, 1.0))
					
				} else {
					println(error)
				}
			})
		}
		
	}
	
}