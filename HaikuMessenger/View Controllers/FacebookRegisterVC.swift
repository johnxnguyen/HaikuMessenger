//
//  FacebookRegisterVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class FacebookRegisterVC: UIViewController, NSURLConnectionDataDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	let facebookUser: PFUser!
	var imageData = NSMutableData()
	
	@IBOutlet weak var welcomeLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordConfirmTextField: UITextField!
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// get the facebook user
		let request = FBRequest.requestForMe()
		request.startWithCompletionHandler {
			(connection: FBRequestConnection!, result: AnyObject?, error: NSError!) -> Void in
			
			// success
			if error == nil {
				
				// get user details
				let userDetails = result as Dictionary<String, AnyObject>
				let facebookID = userDetails["id"] as String
				let firstName = userDetails["first_name"] as String
				
				// display profile pic & welcome message
				self.downloadProfileImageWithId(facebookID)
				self.welcomeLabel.text = "Welcome, \(firstName)"
			}
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
	
	// SIGN UP BUTTON
	//
	@IBAction func SignUpButtonTapped(sender: UIButton) {
		
		// validate form
		if formIsValid() {
			
			// get user details
			let request = FBRequest.requestForMe()
			
			request.startWithCompletionHandler({
				(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
				
				// get email address
				let userDetails = result as Dictionary<String, AnyObject>
				let userEmail = userDetails["email"] as String
				
				// get current user
				let currentUser = PFUser.currentUser()
				
				// store details
				currentUser.username = self.usernameTextField.text
				currentUser.password = self.passwordTextField.text
				currentUser.email = userEmail
				
				// save photo
				let photoFile = PFFile(data: self.imageData)
				currentUser[kUser.ProfilePhoto] = photoFile
				
				// VERIFY EMAIL HERE
				
				// save user, go to log in screen
				currentUser.saveInBackgroundWithBlock({
					(succeeded: Bool, error: NSError!) -> Void in
					
					// success
					if error == nil {
						println("Facebook user registration complete: \(currentUser.username)")

						// go back to inbox
						self.performSegueWithIdentifier("InboxSegue", sender: nil)
						
					} else {
						// alert user of error
						var errorString = error.userInfo!["error"] as String
						let alert = UIAlertView(title: "Oops", message: errorString, delegate: nil, cancelButtonTitle: "Ok")
						alert.show()
					}
				})
			})
		}
	}
	
	// CANCEL BUTTON
	//
	@IBAction func cancelBarButtonTapped(sender: UIButton) {
		
		// delete facebook user from Parse (created on previous page)
		PFUser.currentUser().deleteInBackgroundWithBlock {
			(sucess: Bool!, error: NSError!) -> Void in
			
			if error == nil {
				println("Registration canceled, FB user deleted")
			} else {
				println("Error: \(error.userInfo)")
			}
			
			// go back to login
			self.navigationController!.popToRootViewControllerAnimated(true)
		}
	}
	
	// ------------------------------------------------------------------
	//	MARK:           NSURL CONNECTION DATA DELEGATE
	// ------------------------------------------------------------------
	
	// DID RECEIVE DATA
	//
	func connection(connection: NSURLConnection, didReceiveData data: NSData) {
		
		// as chunks come in, build up data file
		imageData.appendData(data)
	}
	
	// DOWNLOADING COMPLETE
	//
	func connectionDidFinishLoading(connection: NSURLConnection) {
		
		// display profile picture
		let profileImage = UIImage(data: imageData)
		imageView.image = profileImage
	}
	
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// DOWNLOAD PROFILE IMAGE
	//
	func downloadProfileImageWithId(facebookID: String) {
		
		// create url
		let pictureUrl = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1")
		let urlRequest = NSURLRequest(URL: pictureUrl!, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 4.0)
		let urlConnection = NSURLConnection(request: urlRequest, delegate: self)
		
		if urlConnection == nil {
			println("Error: Failed to download profile image")
		}
		
	}

	
	// VALIDATE FORM
	//
	func formIsValid() -> Bool {
		
		let username = usernameTextField.text
		let password = passwordTextField.text
		let passwordConfirm = passwordConfirmTextField.text
		let passwordLength = countElements(password)
		var errorMessage = ""
		
		// username & password have data
		if !username.isEmpty && !password.isEmpty {
			
			// username is one word
			if username.rangeOfCharacterFromSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == nil {
				
				// password is between 6 & 15 chars long
				if passwordLength >= 6 && passwordLength <= 15 {
					
					// password contains only alphanumeric chars (upper, lower, numbers)
					if password.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) == nil {
						
						// passwords match
						if password == passwordConfirm {
							// valid!
							return true
							
						} else {
							// passwords don't match
							errorMessage = "Passwords don't match"
						}
					} else {
						// password contains illegal chars
						errorMessage = "Your password must be alphanumeric (no symbols) and 6 - 15 characters long"
					}
				} else {
					// password is not between 6 & 15 chars
					errorMessage = "Your password must be alphanumeric (no symbols) and 6 - 15 characters long"
				}
			} else {
				// username not one word
				errorMessage = "Your username must be one word"
			}
		} else {
			// username &or password empty
			errorMessage = "Please complete all fields"
		}
		
		// alert the error
		let alert = UIAlertView(title: "Uh oh!", message: errorMessage, delegate: nil, cancelButtonTitle: "ok")
		alert.show()
		
		return false
	}
}
