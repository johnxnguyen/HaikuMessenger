//
//  AppDelegate.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 10/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		// set up Parse
		Parse.setApplicationId("c9OYYti1GDRDDCzMoorltK4wKOFhXr0VGGG3tjdI", clientKey: "U4ZvJjglcUMiF93MhstUGZ5NzHR98ZaQVtcv0tJH")

		// set up Facebook
		PFFacebookUtils.initializeFacebook()
		
		// security measures
		PFUser.enableAutomaticUser()
		var defaultACL = PFACL()
		
		// optionally enable public read access, while disabling public write
		defaultACL.setPublicReadAccess(true)
		
		PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
		
		// generate users
		//Factory.generateUsers()
		
		
		// Facebook, check for cached session
		
		// Whenever a person opens the app, check for a cached session
		if FBSession.activeSession().state == FBSessionState.CreatedTokenLoaded {
			
			// If there's one, just open the session silently, without showing the user the login UI
			FBSession.openActiveSessionWithReadPermissions(["publich_profile"], allowLoginUI: false, completionHandler: { (session: FBSession!, state: FBSessionState, error: NSError!) -> Void in
				
				// Handler for session state changes
				// This method will be called EACH time the session state changes,
				// also for intermediate states and NOT just when the session open
				self.sessionStateChanged(session, state: state, error: error)

			})
		}
		
		// set up navbar
		UINavigationBar.appearance().barTintColor = UIColor(red: 252/255.0, green: 95/255.0, blue: 95/255.0, alpha: 1.0)
		UINavigationBar.appearance().titleTextAttributes = NSDictionary(objectsAndKeys: UIColor.whiteColor(), NSForegroundColorAttributeName, UIFont(name: "AvenirNext-Regular", size: 20)!, NSFontAttributeName)
		
		
		
		return true
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
		
		// handler
		return FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
		
		// handler
		FBAppCall.handleDidBecomeActive()
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		// Saves changes in the application's managed object context before the application terminates.
		self.saveContext()
	}

	// MARK: - Core Data stack

	lazy var applicationDocumentsDirectory: NSURL = {
	    // The directory the application uses to store the Core Data store file. This code uses a directory named "self.edu.HaikuMessenger" in the application's documents Application Support directory.
	    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
	    return urls[urls.count-1] as NSURL
	}()

	lazy var managedObjectModel: NSManagedObjectModel = {
	    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
	    let modelURL = NSBundle.mainBundle().URLForResource("HaikuMessenger", withExtension: "momd")!
	    return NSManagedObjectModel(contentsOfURL: modelURL)!
	}()

	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
	    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
	    // Create the coordinator and store
	    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
	    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("HaikuMessenger.sqlite")
	    var error: NSError? = nil
	    var failureReason = "There was an error creating or loading the application's saved data."
	    if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
	        coordinator = nil
	        // Report any error we got.
	        let dict = NSMutableDictionary()
	        dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
	        dict[NSLocalizedFailureReasonErrorKey] = failureReason
	        dict[NSUnderlyingErrorKey] = error
	        error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
	        // Replace this with code to handle the error appropriately.
	        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	        NSLog("Unresolved error \(error), \(error!.userInfo)")
	        abort()
	    }
	    
	    return coordinator
	}()

	lazy var managedObjectContext: NSManagedObjectContext? = {
	    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
	    let coordinator = self.persistentStoreCoordinator
	    if coordinator == nil {
	        return nil
	    }
	    var managedObjectContext = NSManagedObjectContext()
	    managedObjectContext.persistentStoreCoordinator = coordinator
	    return managedObjectContext
	}()

	// MARK: - Core Data Saving support

	func saveContext () {
	    if let moc = self.managedObjectContext {
	        var error: NSError? = nil
	        if moc.hasChanges && !moc.save(&error) {
	            // Replace this implementation with code to handle the error appropriately.
	            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	            NSLog("Unresolved error \(error), \(error!.userInfo)")
	            abort()
	        }
	    }
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// FB SESSION STATE CHANGED
	//
	func sessionStateChanged(session: FBSession, state: FBSessionState, error: NSError!) {
		
		// If the session was opened successfully
		if error == nil && state == FBSessionState.Open {
			println("Facebook Session Opened")
			return
		}
		
		if state == FBSessionState.Closed || state == FBSessionState.ClosedLoginFailed {
			println("Facebook Session Closed")
		}
		
		// Handle errors
		if error != nil {
			
			print("Facebook Session Error. ")
			
			var alertText: String
			var alertTitle: String
			
			// If the error requires people using an app to make an action outside of the app in order to recover
			if FBErrorUtility.shouldNotifyUserForError(error) == true {
				alertTitle = "Something went wrong"
				alertText = FBErrorUtility.userMessageForError(error)
				showMessage(alertText, withTitle: alertTitle)
				
			} else {
				
				// if the user cancelled login, do nothing
				if FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.UserCancelled {
					println("User cancelled login")
					
				} else if FBErrorUtility.errorCategoryForError(error) == FBErrorCategory.AuthenticationReopenSession {
					alertTitle = "Session Error"
					alertText = "Your current session is no longer valid. Please log in again."
					showMessage(alertText, withTitle: alertTitle)
					
				} else {
					// Here we will handle all other errors with a generic error message.
					// We recommend you check our Handling Errors guide for more info
					// https://developers.facebook.com/docs/ios/errors/
					
					// get more error info from the error
					let errorUserInfo: NSDictionary = error.userInfo!
					let errorInfo = errorUserInfo.objectForKey("com.facebook.sdk:ParsedJSONResponseKey")! as NSDictionary
					let body = errorInfo.objectForKey("body") as NSDictionary
					let errorCode = body.objectForKey("error") as NSDictionary
					let errorMessage: AnyObject? = errorCode.objectForKey("message")
					
					// show message
					alertTitle = "Something went wrong"
					alertText = "Please retry. \n\n If the problem persists contact us and mention this error code: \(errorMessage)"
					showMessage(alertText, withTitle: alertTitle)
				}
			}
			
			// Clear this token
			FBSession.activeSession().closeAndClearTokenInformation()
		}
		
	}
	
	// SHOW MESSAGE
	//
	func showMessage(message: String, withTitle title: String) {
		
		let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Ok")
		alert.show()
	}
	
}

