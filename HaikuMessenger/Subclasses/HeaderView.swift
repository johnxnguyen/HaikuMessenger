//
//  HeaderView.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 16/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit



@IBDesignable class HeaderView: UIView {
	
	var mainLabel: UILabel!
	var buttonLeft: UIButton!
	var buttonRight: UIButton!
	
	// ------------------------------------------------------------------
	//	MARK:              INSPECTABLE PROPERTIES
	// ------------------------------------------------------------------
	
	@IBInspectable var title: String? {
		didSet {
			mainLabel.text = title
			mainLabel.sizeToFit()
		}
	}
	
	@IBInspectable var textColor: UIColor = UIColor.blackColor() {
		didSet {
			mainLabel.textColor = textColor
		}
	}
	
	
	
	
	// ------------------------------------------------------------------
	//	MARK:					STANDARD
	// ------------------------------------------------------------------
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupView()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		setupView()
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		// center label
		mainLabel.center.x = self.frame.width / 2.0
		mainLabel.center.y = self.frame.height / 2.0
		
		// left button
		buttonLeft.center.y = self.frame.height / 2.0
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// SETUP VIEW
	//
	func setupView() {
		
		// label
		mainLabel = UILabel(frame: CGRectMake(0, 0, 100, 20))
		mainLabel.text = "Header"
		mainLabel.font = UIFont(name: "AvenirNext-Regular", size: 30)
		mainLabel.textAlignment = NSTextAlignment.Center
		mainLabel.sizeToFit()
		self.addSubview(mainLabel)
		
		// left button
		buttonLeft = UIButton.buttonWithType(UIButtonType.System) as UIButton
		buttonLeft.frame = CGRectMake(10, 0, 50, 30)
		buttonLeft.setTitle("Left Button", forState: UIControlState.Normal)
		buttonLeft.sizeToFit()
		self.addSubview(buttonLeft)
		
		// right button
	}

}
