/**
 * @file	KCPreferenceWindow.swift
 * @brief	Define KCPreferenceWindow class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 * @references
 *   https://genjiapp.com/blog/2012/10/25/how-to-develop-a-preferences-window-for-os-x-app.html (Japanese)
 */

#if os(OSX)
import AppKit
#else
import UIKit
#endif
import CoconutData
import Foundation

#if os(OSX)

public class KCPreferenceWindow: NSWindow, NSWindowDelegate
{
	private var mDidCancelled = false

	public override init(contentRect rect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
		mDidCancelled = false
		super.init(contentRect: rect, styleMask: style, backing: backingStoreType, defer: flag)
		self.delegate = self
	}

	public var didCancelled: Bool { get { return mDidCancelled }}

	/* Close the window when the ESC is pressed */
	public override func cancelOperation(_ sender: Any?) {
		mDidCancelled = true
		self.close()
	}
}

#endif // os(OSX)

