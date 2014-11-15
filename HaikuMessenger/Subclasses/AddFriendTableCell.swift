//
//  AddFriendTableCell.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 11/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class AddFriendTableCell: UITableViewCell {

	var button: UIButton!
	
	// ------------------------------------------------------------------
	//	MARK:						INITS
	// ------------------------------------------------------------------
	
	override init() {
		super.init()
		
		// add a button
		setupButton()
		
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// add a button
		setupButton()
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// SETUP BUTTON
	//
	func setupButton() {
		
		button = UIButton.buttonWithType(UIButtonType.ContactAdd) as UIButton
		button.center.x = self.frame.width
		button.center.y = self.frame.height / 2.0
		self.addSubview(button)
	}
}
