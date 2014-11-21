//
//  SettingsVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 21/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController {

	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set menu bar button item
		navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu"), style: .Plain, target: self.revealViewController(), action: "revealToggle:")
		// set title
		navigationItem.title = "Settings"
		
		// set the gesture (swipe to reveal menu)
		self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

}
