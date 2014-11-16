//
//  RootVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 15/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class RootVC: UIViewController {
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	// VIEW DID APPEAR
	//
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
//		
//		// FB user already logged in?
//		if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
//			// go straight to inbox
//			performSegueWithIdentifier("PageContainerSegue", sender: nil)
//			
//		} else {
//			
//			// go to login
//			performSegueWithIdentifier("LoginSegue", sender: nil)
//		}
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
}
