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
	
	
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		
		// sets status bar to white (only for this VC)
		//self.navigationController!.navigationBar.barStyle = UIBarStyle.Black
		
		// set menu bar buttom item
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
		// set compose button item
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "composeButtonTapped:")
		// set title
		navigationItem.title = "Inbox"
		
		// set the gesture (swipe to reveal menu)
		self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
		self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
		
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	// COMPOSE BUTTON
	//
	func composeButtonTapped(sender: UIBarButtonItem) {
		
		performSegueWithIdentifier("ComposeSegue", sender: nil)
	}

}
