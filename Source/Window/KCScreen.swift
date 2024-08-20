/**
 * @file	KCScreen.swift
 * @brief	Define KCScreen class
 * @par Copyright
 *   Copyright (C) 2023 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import CoconutData

public class KCScreen
{
#if os(OSX)
	public static func maxWindowSize() -> CGSize {
        var result  = CGSize.zero
        let screens = NSScreen.screens
        if screens.count > 0 {
            result = KCScreen.windowSize(screen: screens[0])
            for i in 0..<screens.count {
                let winsize = KCScreen.windowSize(screen: screens[i])
                result = CGSize.minSize(result, winsize)
            }
        }
		return result
	}

    private static func windowSize(screen scn: NSScreen) -> CGSize {
        let entiresize  = scn.visibleFrame.size
        let inset       = scn.safeAreaInsets
        let width       = max(entiresize.width  - inset.left - inset.right,  0.0)
        let height      = max(entiresize.height - inset.top  - inset.bottom, 0.0)
        return CGSize(width: width, height: height)
    }

#else
	/* reference: https://stackoverflow.com/questions/62501090/how-to-get-window-size-in-swift-including-ipad-split-screen
	 */
	public static func mainWindow() -> UIWindow? {
		let windowp = UIApplication.shared.connectedScenes
			.compactMap({ scene -> UIWindow? in
				(scene as? UIWindowScene)?.keyWindow
			}).first
			if let window = windowp {
				return window
			} else {
				CNLog(logLevel: .error, message: "Failed to get the correct window size", atFunction:#function, inFile: #file)
				return nil
			}
	}

	public static func mainStatusBar() -> UIStatusBarManager? {
		if let window = mainWindow() {
			if let scene = window.windowScene {
				return scene.statusBarManager
			}
		}
		return nil
	}

	public static func maxWindowSize() -> CGSize {
		if let window = mainWindow() {
			return window.frame.size
		} else {
			return CGSize.zero
		}
	}

	public static func statusBarSize() -> CGSize {
		if let bar = mainStatusBar() {
			return bar.statusBarFrame.size
		} else {
			return CGSize.zero
		}
	}

#endif

	public static func adjustSize(size sz: CGSize) -> CGSize {
		let maxsize   = maxWindowSize()
		#if os(OSX)
		let maxwidth  = maxsize.width  * 0.8
		let maxheight = maxsize.height * 0.8
		#else
		let barsize   = statusBarSize()
		let maxwidth  = maxsize.width
		let maxheight = maxsize.height - barsize.height
		#endif
		if maxwidth <= 0.0 || maxheight <= 0.0 {
			return sz
		}
		if sz.width < maxwidth && sz.height < maxheight {
			return sz
		} else if sz.width < maxwidth { // && sz.height >= maxheight
			let ratio = sz.height / maxheight
			return CGSize(width: sz.width / ratio, height: maxheight)
		} else if sz.height < maxheight { // && sz.width >= maxwidth
			let ratio = sz.width / maxwidth
			return CGSize(width: maxwidth, height: sz.height / ratio)
		} else {
			return CGSize(width: maxwidth, height: maxheight)
		}
	}
}

