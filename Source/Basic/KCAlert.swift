/**
 * @file	KCAlert.swift
 * @brief	Define KCAlert class
 * @par Copyright
 *   Copyright (C) 2015 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif
import CoconutData

public class KCAlert : NSObject
{
	public class func alert(type typ: CNAlertType, messgage msg: String, labels labs: Array<String>, in viewcont: KCViewController, callback cbfunc: @escaping (_ buttonid: Int) -> Void) {
		#if os(OSX)
			let alert = NSAlert()
			switch typ {
			  case .critical:	alert.alertStyle = .critical
			  case .informational:	alert.alertStyle = .informational
			  case .warning:	alert.alertStyle = .warning
			  @unknown default:	alert.alertStyle = .informational
			}
			alert.messageText = msg
			let count = min(labs.count, 3)
			if count > 3 {
				CNLog(logLevel: .error, message: "Too many labels: \(count)", atFunction: #function, inFile: #file)
			}
			for i in 0..<count {
				alert.addButton(withTitle: labs[i])
			}
			switch alert.runModal() {
			  case .alertFirstButtonReturn:		cbfunc(0)
			  case .alertSecondButtonReturn:	cbfunc(1)
			  case .alertThirdButtonReturn:		cbfunc(2)
			  default:				cbfunc(-1)
			}
		#else
			let title   = "Error"
			let alert   = UIAlertController(title: title, message: msg, preferredStyle: .alert)
			let action = UIAlertAction(title: "OK", style: .default, handler: {
				(action:UIAlertAction!) -> Void in
			})
			alert.addAction(action)
			viewcont.present(alert, animated: false, completion: {
				() -> Void in
				cbfunc(0)
			})
		#endif
	}
}

