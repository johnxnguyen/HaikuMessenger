//
//  ParseQueryManager.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 29/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	NOTE:
//
//	singleton code taken from http://code.martinrue.com/posts/the-singleton-pattern-in-swift

import UIKit

class ParseQueryManager: NSObject {
	
	// Swift Singleton
	class var sharedInstance: ParseQueryManager {
		
		struct Static {
			static var instance: ParseQueryManager?
			static var token: dispatch_once_t = 0
		}
		
		dispatch_once(&Static.token) {
			Static.instance = ParseQueryManager()
		}
		
		return Static.instance!
	}
	
	// FRIENDS QUERY - all PFUsers in the friends relation property of Current User
	var friendsQuery: PFQuery {
		
		let relation = PFUser.currentUser().relationForKey(kUser.Friends)
		let query = relation.query()
		query.cachePolicy = kPFCachePolicyCacheElseNetwork
		return query
	}

   
}
