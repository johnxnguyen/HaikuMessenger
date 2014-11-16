//
//  FriendCell.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 15/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	// ------------------------------------------------------------------
	//	MARK:					STANDARD
	// ------------------------------------------------------------------
	
	override func layoutSubviews() {
		super.layoutSubviews()

		let size = self.contentView.frame.size
		
		// configure imageView
		imageView.frame.size = CGSizeMake(size.height * 0.9, size.height * 0.9)
		imageView.center.y = self.contentView.center.y
		
		// circle (could be inefficient, might be better to provide round image)
		imageView.layer.cornerRadius = imageView.frame.width / 2.0
		imageView.layer.masksToBounds = true
		
		// configure textLabel
		textLabel.font = UIFont(name: "AvenirNext-Regular", size: 25)
		
	}

}
