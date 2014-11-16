//
//  InboxVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class InboxVC: UIViewController {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var sideBarButton: UIBarButtonItem!
	
	
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
		
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	@IBAction func logOutButtonTapped(sender: UIButton) {
		
		PFUser.logOut()
		
		// go to login
		dismissViewControllerAnimated(true, completion: nil)
	}

}
