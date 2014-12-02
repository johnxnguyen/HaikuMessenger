//
//  StandardCell.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 16/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class StandardCell: UITableViewCell {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	let imageScale: CGFloat = 0.5
	let fontSize: CGFloat = 20

	// ------------------------------------------------------------------
	//	MARK:					  STANDARD
	// ------------------------------------------------------------------
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
		
		backgroundColor = UIColor.clearColor()
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//		if selected == true {
//			backgroundColor = UIColor(white: 1.0, alpha: 0.2)
//		} else {
//			backgroundColor = UIColor.clearColor()
//		}
//    }
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let size = self.contentView.frame.size
		
		// configure imageView
		imageView.frame.size = CGSizeMake(size.height * imageScale, size.height * imageScale)
		imageView.frame.origin.x = 25
		imageView.center.y = self.contentView.center.y

		// configure textLabel
		textLabel.font = UIFont(name: "AvenirNext-Regular", size: fontSize)
		
		// space between imageView and label
		let marginX = imageView.frame.origin.x + imageView.frame.width + 15
		textLabel.frame.origin.x = marginX
		
	}


}
