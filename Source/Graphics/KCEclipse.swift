/**
 * @file	KCEclipse.swift
 * @brief	Define KCEclipse data structure
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public struct KCEclipse
{
	public var mCenter:		CGPoint
	public var mInnerRadius:	CGFloat
	public var mOuterRadius:	CGFloat

	private var mBounds:		CGRect

	public init(center c:CGPoint, innerRadius ir: CGFloat, outerRadius or: CGFloat) {
		mCenter		= c
		mInnerRadius	= ir
		mOuterRadius	= or
		mBounds		= KCEclipse.calcBounds(center: mCenter, outerRadius: or)
	}

	public var center: CGPoint {
		get { return mCenter }
	}

	public var innerRadius: CGFloat {
		get { return mInnerRadius }
	}

	public var outerRadius: CGFloat {
		get { return mOuterRadius }
	}

	public var bounds: CGRect {
		get { return mBounds }
	}

	static private func calcBounds(center c: CGPoint, outerRadius or: CGFloat) -> CGRect {
		let outdiameter = or * 2
		let origin      = CGPoint(x: c.x - or, y: c.y - or)
		let size        = CGSize(width: outdiameter, height: outdiameter)
		return CGRect(origin: origin, size: size)
	}
}

