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
}


class Factory {
	
	class func generateUsers() {
		
		let user1 = User(username: "teanyu", password: "ilovejohn", email: "teodora@bean.com")
		let user2 = User(username: "amySqrrl", password: "dinahsButt1", email: "amy@bean.com")
		let user3 = User(username: "sophie_loafie", password: "s4gS8iJheJo0", email: "sophie@bean.com")
		let user4 = User(username: "michaelmoon", password: "bridge95", email: "michael@bean.com")
		let user5 = User(username: "kimlouise", password: "hanoiHANOI", email: "kim@bean.com")
		let user6 = User(username: "tktktk", password: "amyAmy184", email: "tim@bean.com")
		let user7 = User(username: "tuxxi", password: "cesena29", email: "agata@bean.com")
		let user8 = User(username: "DMTR", password: "synthesizers123", email: "deme@bean.com")
		let user9 = User(username: "eugiResta", password: "pizzaman", email: "eugi@bean.com")
		let user10 = User(username: "vitomatera", password: "iloveFOOD", email: "vito@bean.com")
		
		let users = [user1, user2, user3, user4, user5, user6, user7, user8, user9, user10]
		
		for item in users {
			
			var newUser = PFUser()
			newUser.username = item.username
			newUser.password = item.password
			newUser.email = item.email
			
			newUser.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
				
				// success
				if error == nil {
					println("User successfully signed up: \(newUser.username)")
				} else {
					println(error)
				}
			})
		}
		
	}
	
}