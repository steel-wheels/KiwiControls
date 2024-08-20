/**
 * @file	ViewController.swift
 * @brief	Define ViewController class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

import KiwiControls
import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var mNavigationBar: KCNavigationBar!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		mNavigationBar.title = "Hello"

		mNavigationBar.isLeftButtonEnabled = true
		mNavigationBar.leftButtonTitle = "Left"
		mNavigationBar.leftButtonPressedCallback = {
			() -> Void in
			NSLog("Left button was pressed")
		}

		mNavigationBar.isRightButtonEnabled = true
		mNavigationBar.rightButtonTitle = "Right"
		mNavigationBar.rightButtonPressedCallback = {
			() -> Void in
			NSLog("Right button was pressed")
		}
	}
}

