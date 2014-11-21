//
//  LoginVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	NOTES:
//
//	All UI is contained in "containerView". If user is already logged in,
//	to smooth the auto transition to the inbox, the view (with all the UI)
//	is hidden before seguing to the inbox. Otherwise, the UI would appear
//	briefly before the segue.


import UIKit
import CoreData

class LoginVC: UIViewController {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	// all UI is contained in this view
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	var userIsloggedIn: Bool = false
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let coreDataManager = CoreDataManager()
		coreDataManager.printAllUsers()
	}
	
	// VIEW DID APPEAR
	//
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		// FB user already logged in?
		if userIsloggedIn {
			// go straight to inbox
			performSegueWithIdentifier("RevealViewControllerSegue", sender: nil)
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// if already logged in
		if PFUser.currentUser() != nil && PFFacebookUtils.isLinkedWithUser(PFUser.currentUser()) {
			
			// hide all UI elements to smooth auto segue to inbox
			containerView.hidden = true
			navigationController!.setNavigationBarHidden(true, animated: false)
			userIsloggedIn = true
			
		} else {
			containerView.hidden = false
			navigationController!.setNavigationBarHidden(false, animated: true)
			userIsloggedIn = false
		}
		
		// clear text fields
		usernameTextField.text = ""
		passwordTextField.text = ""
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
				// email registration
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
				// segue to inbox
				self.performSegueWithIdentifier("RevealViewControllerSegue", sender: nil)
				
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
			
			if error == nil {
				
				// state is open
				if state == FBSessionState.Open || state == FBSessionState.OpenTokenExtended {
					
					// go to register view controller
					self.performSegueWithIdentifier("RegisterSegue", sender: "facebookButton")
				}
			}

			// Retrieve the app delegate
			let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
			
			// Call the app delegate's sessionStateChanged:state:error method to handle session state changes
			appDelegate.sessionStateChanged(session, state: state, error: error)
		})
	}
	
	// REGISTER WITH EMAIL BUTTON
	//
	@IBAction func registerWithEmailButtonTapped(sender: UIButton) {
		
		performSegueWithIdentifier("RegisterSegue", sender: "emailButton")
	}
	
}
