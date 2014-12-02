//
//  CustomCell.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 1/12/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class CustomCell: PFTableViewCell {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var profileImageView: PFImageView!
	
	// ------------------------------------------------------------------
	//	MARK:					   INITS
	// ------------------------------------------------------------------
	
	override init() {
		super.init()
		
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
	}

	// ------------------------------------------------------------------
	//	MARK:					FUNCTIONS
	// ------------------------------------------------------------------
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		profileImageView.layer.cornerRadius = profileImageView.frame.width / 2.0
		profileImageView.layer.masksToBounds = true
		
		let imageViewWidth = profileImageView.frame.width
		let margin = profileImageView.frame.origin.x
		
		textLabel.frame.origin.x = imageViewWidth + margin * 2
	}
	
   
}
