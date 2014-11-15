//
//  PageContainerVC.swift
//  HaikuMessenger
//
//  Created by John Nguyen on 13/11/2014.
//  Copyright (c) 2014 John Nguyen. All rights reserved.
//

import UIKit

class PageContainerVC: UIViewController, UIPageViewControllerDataSource {

	// ------------------------------------------------------------------
	//	MARK:               PROPERTIES & OUTLETS
	// ------------------------------------------------------------------
	
	var pageViewController: UIPageViewController!
	var currentIndex: Int?
	
	// ------------------------------------------------------------------
	//	MARK:					 STANDARD
	// ------------------------------------------------------------------
	
	// VIEW DID LOAD
	//
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// starting index
		currentIndex = 1
		let startingViewController = viewControllerForIndex(currentIndex!)
		
		// set up UIPageViewController
		pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
		pageViewController.dataSource = self
		
		
		pageViewController.setViewControllers([startingViewController!], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
		
		pageViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
		
		addChildViewController(pageViewController)
		view.addSubview(pageViewController.view)
		pageViewController.didMoveToParentViewController(self)
		
	}
	
	// MEMORY WARNING
	//
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	// ------------------------------------------------------------------
	//	MARK:          PAGE VIEW CONTROLLER DATA SOURCE
	// ------------------------------------------------------------------
	
	// BEFORE VIEW CONTROLLER
	//
	func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
		
		// get the index of the current view
		currentIndex = indexForViewController(viewController)
		
		// if current VC is the first one || no index
		if currentIndex <= 0 || currentIndex == nil {
			return nil
		}
		
		// return previous view controller
		return viewControllerForIndex(currentIndex! - 1)
	}
	
	// AFTER VIEW CONTROLLER
	//
	func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
		
		// get the index of the current view
		currentIndex = indexForViewController(viewController)
		
		// if current VC is the last one || no index
		if currentIndex >= 1 || currentIndex == nil {
			return nil
		}
		
		// return next view controller
		return viewControllerForIndex(currentIndex! + 1)
	}
	
	// ------------------------------------------------------------------
	//	MARK:					 HELPERS
	// ------------------------------------------------------------------
	
	// VIEW CONTROLLER FOR INDEX
	//
	func viewControllerForIndex(index: Int) -> UIViewController? {
		
		switch index {
		case 0:
			return storyboard!.instantiateViewControllerWithIdentifier(kViewControllerID.Friends) as FriendsVC
		case 1:
			return storyboard!.instantiateViewControllerWithIdentifier(kViewControllerID.Inbox) as InboxVC
		default:
			return nil
		}
	}
	
	// INDEX FOR VIEW CONTROLLER
	//
	func indexForViewController(viewController: UIViewController) -> Int? {
		
		if viewController.isMemberOfClass(FriendsVC) {
			return 0
		}
		
		if viewController.isMemberOfClass(InboxVC) {
			return 1
		}
		
		return nil
	}

	
}
