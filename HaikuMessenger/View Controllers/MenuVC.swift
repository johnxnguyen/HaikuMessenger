//
//  MenuVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 16/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class MenuVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var tableView: UITableView!
	
	let menuItems = ["inbox", "friends"]
	
	
	// ------------------------------------------------------------------
	//	MARK:					  STANDARD
	// ------------------------------------------------------------------

    override func viewDidLoad() {
        super.viewDidLoad()
		
		tableView.dataSource = self
		tableView.delegate = self
		
//		self.view.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
//		tableView.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
//		tableView.separatorColor = UIColor.darkGrayColor()

		
    }
	
	// LOAD VIEW
	//
	override func loadView() {
		super.loadView()
		
		// removes warning for ambigous layout
		tableView.rowHeight = 44
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	// ------------------------------------------------------------------
	//	MARK:               TABLE VIEW DATASOURCE
	// ------------------------------------------------------------------
	
	// SECTIONS
	//
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}
	
	// ROWS
	//
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuItems.count
	}
	
	// CELL
	//
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		
		let cellIdentifier = menuItems[indexPath.row]
		
		let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell
		
		return cell
	}
}
