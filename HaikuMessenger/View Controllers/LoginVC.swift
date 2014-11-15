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
		
		// FB user already logged in?
		if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
			// go straight to inbox
			performSegueWithIdentifier("PageContainerSegue", sender: nil)
		}
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// PREPARE FOR SEGUE
	//
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		if segue.identifier == "RegisterSegue" {
			
			var targetViewController = segue.destinationViewController as RegisterVC
			
			// who is calling?
			if (sender as String) == "facebookButton" {
				targetViewController.facebookLogin = true
			} else {
				targetViewController.facebookLogin = false
			}
			
		}
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
			if error == nil {				
				// clear text fields
				self.usernameTextField.text = ""
				self.passwordTextField.text = ""
				// segue to inbox
				self.performSegueWithIdentifier("PageContainerSegue", sender: nil)
				
			} else {
				// error
				let errorString = error.userInfo!["error"] as String
				let alert = UIAlertView(title: "Oops!", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
				alert.show()
			}
		}
	}
	
	// REGISTER WITH FACEBOOK BUTTON
	//
	@IBAction func registerWithFacebookButtonTapped(sender: UIButton) {
		

		// open the session
		FBSession.openActiveSessionWithReadPermissions(["public_profile", "email", "user_friends"], allowLoginUI: true, completionHandler: { (session: FBSession!, state: FBSessionState, error: NSError!) -> Void in
			
			// Retrieve the app delegate
			let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
			
			// Call the app delegate's sessionStateChanged:state:error method to handle session state changes
			appDelegate.sessionStateChanged(session, state: state, error: error)
			
			// go to register view controller
			self.performSegueWithIdentifier("RegisterSegue", sender: "facebookButton")
		})
	}
	
	// REGISTER WITH EMAIL BUTTON
	//
	@IBAction func registerWithEmailButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("RegisterSegue", sender: "emailButton")
	}
}
