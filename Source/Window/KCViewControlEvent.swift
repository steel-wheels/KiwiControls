/**
 * @file	KCViewControlEvent.swift
 * @brief	Define KCViewControlEvent class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif
import CoconutData

public enum KCViewControlEvent {
	case none
	case updateSize(KCView)
	case switchFirstResponder(KCViewBase)
}

public protocol KCViewControlEventReceiver {
	func notifyControlEvent(viewControlEvent event: KCViewControlEvent)
}

extension KCResponder {
	func notify(viewControlEvent event: KCViewControlEvent) {
		var responder: KCResponder? = self
		while responder != nil {
			if let receiver = responder as? KCViewControlEventReceiver {
				let _ = receiver.notifyControlEvent(viewControlEvent: event)
			}
			responder = responder?.next
		}
	}
}
