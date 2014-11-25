//
//  ComposeVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 22/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class ComposeVC: UIViewController {
	
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
		
		// set compose button item
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: UIBarButtonItemStyle.Plain, target: self.revealViewController(), action: "rightRevealToggle:")
		// set title
		navigationItem.title = "Compose"

		
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// PREPARE FOR SEGUE
	//
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		super.prepareForSegue(segue, sender: sender)

	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	// NEXT BUTTON
	//
	func nextButtonTapped(sender: UIBarButtonItem) {
		
		// go to friends list
		
	}
}
