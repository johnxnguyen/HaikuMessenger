//
//  LoginVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	// VIEW DID APPEAR
	//
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// already logged in? there is a current user &|| it's linked with FB
		if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
			
			// go straight to inbox
			performSegueWithIdentifier("InboxSegue", sender: nil)
		}
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:				  USER INTERFACE
	// ------------------------------------------------------------------
	
	// LOG IN BUTTON
	//
	@IBAction func loginButtonTapped(sender: UIButton) {
		
		let username = usernameTextField.text
		let password = passwordTextField.text
		
		PFUser.logInWithUsernameInBackground(username, password: password) {
			(user: PFUser!, error: NSError!) -> Void in
			
			// success
			if user != nil {
				
				// segue to inbox
				self.performSegueWithIdentifier("InboxSegue", sender: nil)
				
				// clear text fields
				self.usernameTextField.text = ""
				self.passwordTextField.text = ""
				
			} else {
				// error
				let errorString = error.userInfo!["error"] as String
				let alert = UIAlertView(title: "Oops!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
				alert.show()
			}
		}
	}
	
	// FACEBOOK BUTTON
	//
	@IBAction func facebookButtonTapped(sender: UIButton) {
		
		let permissions = ["public_profile", "email", "user_friends"]
		
		PFFacebookUtils.logInWithPermissions(permissions, block: {
			(user: PFUser!, error: NSError!) -> Void in
			
			// success
			if user != nil {
				
				println("Facebook user successfully logged in/created to Parse")
				
				// segue to FB account details
				self.performSegueWithIdentifier("FacebookRegisterSegue", sender: nil)
				
			} else {
				
				// no error
				if error == nil {
					
					println("Facebook Login was cancelled")
				} else {
					println(error.description)
				}
				
			}
		})
	}
	
	// EMAIL BUTTON
	//
	@IBAction func emailButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("EMailRegisterSegue", sender: nil)
	}
	

}
