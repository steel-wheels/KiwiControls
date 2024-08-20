/**
 * @file	KCCoodinate.swift
 * @brief	Define functions to calculate coodinate
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public func KCOrigin(origin elmorg: CGPoint, size elmsz: CGSize, frame frm: CGRect) -> CGPoint {
	let origin: CGPoint
	#if os(iOS)
		origin = CGPoint(x: elmorg.x, y: frm.size.height - elmsz.height - elmorg.y)
	#else
		origin = elmorg
	#endif
	return origin
}

