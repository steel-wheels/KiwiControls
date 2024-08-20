/**
 * @file	ApplicationDelegate.swift
 * @brief	Define ApplicationDelegate class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import CoconutData
import Cocoa

@NSApplicationMain
class AppDelegate: CNApplicationDelegate
{
	open override func applicationDidFinishLaunching(_ aNotification: Notification) {
		// Insert code here to initialize your application
		super.applicationDidFinishLaunching(aNotification)
	}

	open override func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
		super.applicationWillTerminate(aNotification)
	}
}

