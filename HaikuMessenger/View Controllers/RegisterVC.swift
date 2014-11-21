//
//  RegisterVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 13/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

//	-------------------------- TO DO -----------------------------
//
//	- forgot password?
//
//	--------------------------------------------------------------


import UIKit
import CoreData


class RegisterVC: UIViewController, NSURLConnectionDataDelegate {
	
	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	var facebookLogin: Bool!
	var facebookUser: Dictionary<String, AnyObject>?
	var imageData = NSMutableData()
	var profilePicture = UIImage(named: "defaultProfilePic")
	let coreDataManager = CoreDataManager()
	
	// password text field constraints. Use to change priorities, determining which
	// constraint is in effect
	@IBOutlet weak var passwordTFVerticalSpacingConstraintToEmailTF: NSLayoutConstraint!
	@IBOutlet weak var passwordTFVerticalSpacingConstraintToUsernameTF: NSLayoutConstraint!
	
	@IBOutlet weak var welcomeLabel: UILabel!
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordConfirmTextField: UITextField!
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imageView.image = profilePicture
		// needs to be half the width to be a circle
		// for some reason the frame is wack at runtime
		imageView.layer.cornerRadius = 80
		imageView.layer.masksToBounds = true
		imageView.layer.borderWidth = 5.0
		imageView.layer.borderColor = UIColor.whiteColor().CGColor
		
		
		if facebookLogin == true {
			
			// hide and disable text field
			emailTextField.hidden = true
			emailTextField.enabled = false
			
			// adjust constraint priorities to "fill the gap"
			passwordTFVerticalSpacingConstraintToEmailTF.priority = 1
			passwordTFVerticalSpacingConstraintToUsernameTF.priority = 100

			// get facebook user data
			FBRequestConnection.startForMeWithCompletionHandler({
				(connection: FBRequestConnection!, result: AnyObject!, error: NSError!) -> Void in
				
				if error == nil {
					
					self.facebookUser = (result as Dictionary<String, AnyObject>)
					
					let facebookID = self.facebookUser!["id"] as String
					let firstName = self.facebookUser!["first_name"] as String
					
					// display profile pic & welcome message
					self.downloadProfileImageWithId(facebookID)
					self.welcomeLabel.text = "Welcome, \(firstName)"
					
					
				} else {
					println("Error: \(error.userInfo)")
					
					// go to login
					self.navigationController!.popViewControllerAnimated(true)
				}
			})
			
		} else {
			welcomeLabel.text = "Welcome!"
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
	
	// DONE
	//
	@IBAction func doneBarButtonTapped(sender: UIBarButtonItem) {
		
		// validate form
		if formIsValid() {
			
			// FACEBOOK REGISTRATION
			if facebookLogin == true && facebookUser != nil {
				
				let facebookID = facebookUser!["id"] as String
				let accessTokenData = FBSession.activeSession().accessTokenData
				
				// create user (logs in or creates if necessary)
				PFFacebookUtils.logInWithFacebookId(facebookID, accessToken: accessTokenData.accessToken, expirationDate: accessTokenData.expirationDate, block: { (user: PFUser!, error: NSError!) -> Void in
					
					if error == nil {
						
						// user is signed up at this point, but but input details not saved
						
						// update user details
						user.username = self.usernameTextField.text
						user.password = self.passwordTextField.text
						// get email address & photo
						user.email = self.facebookUser!["email"] as String
						
						// image
						let profilePictureData = UIImageJPEGRepresentation(self.profilePicture!, 1.0)
						user[kUser.ProfilePhoto] = PFFile(data: profilePictureData)
						
						// save user
						user.saveInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
							
							if error == nil {
								println("Facebook user registration complete!")
								
								// save to store
								self.coreDataManager.storeUser(user, withImage: profilePictureData)
								
								// go to login
								self.navigationController!.popViewControllerAnimated(true)
								
							} else {
								println("Error: \(error.userInfo)")
								
								// delete user
								PFUser.currentUser().deleteInBackground()
								
								// alert to try again
								self.alertUser("Whoops!", message: "Something went wrong, please try again")
								
								// go to login
								self.navigationController!.popViewControllerAnimated(true)
							}
						})
						
					} else {
						// error logging in
						var errorString = error.userInfo!["error"] as String
						self.alertUser("Oops", message: errorString)
					}
				})
				
			} else {
				// EMAIL REGISTRATION
				
				var emailUser = PFUser()
				emailUser.username = usernameTextField.text
				emailUser.password = passwordTextField.text
				emailUser.email = emailTextField.text
				
				let profilePictureData = UIImageJPEGRepresentation(profilePicture, 1.0)
				emailUser[kUser.ProfilePhoto] = PFFile(data: profilePictureData)
				
				// save user
				emailUser.signUpInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
					
					if error == nil {
						
						println("Email user successfully registered!")
						
						// save to CoreData
						self.coreDataManager.storeUser(PFUser.currentUser(), withImage: profilePictureData)
						
						// go to login
						self.navigationController!.popViewControllerAnimated(true)
						
					} else {
						println("Error: \(error.userInfo)")
						
						// alert to try again
						self.alertUser("Whoops!", message: "Something went wrong, please try again")
						
						// go to login
						self.navigationController!.popViewControllerAnimated(true)
					}
				})
			}
		}
	}
	
	// CANCEL BUTTON
	//
	@IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
		
		// If the session state is any of the two "open" states when the button is clicked
		if FBSession.activeSession().state == FBSessionState.Open || FBSession.activeSession().state == FBSessionState.OpenTokenExtended {
			
			// Close the session and remove the access token from the cache
			// The session state handler (in the app delegate) will be called automatically
			FBSession.activeSession().closeAndClearTokenInformation()
		}
		
		// go to login
		self.navigationController!.popViewControllerAnimated(true)
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
		profilePicture = UIImage(data: imageData)
		imageView.image = profilePicture
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
	
	// IS VALID EMAIL
	//
	func isValidEmail(testStr:String) -> Bool {
		
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
		var emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest!.evaluateWithObject(testStr)
	}
	
	// VALIDATE FORM
	//
	func formIsValid() -> Bool {
		
		let username = usernameTextField.text
		let password = passwordTextField.text
		let passwordConfirm = passwordConfirmTextField.text
		let passwordLength = countElements(password)
		var errorMessage = ""
		
		// email registration && invalid email
		if facebookLogin == false && !isValidEmail(emailTextField.text) {
		
			alertUser("Uh oh!", message: "Please enter a valid email")
			return false
		}
		
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
		alertUser("Uh oh!", message: errorMessage)
		
		return false
	}
	
	// ALERT USER
	//
	func alertUser(title: String, message: String) {
		
		let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
		alert.show()
	}
	
}
