/**
 * @file	KCHexagon.swift
 * @brief	Define KCHexagon data structure
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import Foundation
#if os(iOS)
import UIKit
#endif

public struct KCHexagon
{
	private var mCenter:	CGPoint
	private var mRadius:	CGFloat
	private var mLineWidth:	CGFloat
	private var mVertexes:	Array<CGPoint>
	private var mBounds:	CGRect

	public var center: CGPoint {
		get { return mCenter }
	}

	public var radius: CGFloat {
		get { return mRadius }
	}

	public var lineWidth: CGFloat {
		get { return mLineWidth }
	}

	public var vertexes: Array<CGPoint> {
		get { return mVertexes }
	}

	public var bounds: CGRect {
		get { return mBounds }
	}

	public init(center c:CGPoint, lineWidth l: CGFloat, radius r: CGFloat){
		mCenter		= c
		mLineWidth	= l
		mRadius		= r
		mVertexes	= []

		/* calc vertexes */
		let pi		= CGFloat.pi
		var angle	= pi / 2.0
		let adiff	= pi / 3.0
		let dradius	= mRadius - (mLineWidth / 2.0)
		for _ in 0..<6 {
			let x = mCenter.x + dradius * cos(angle)
			let y = mCenter.y + dradius * sin(angle)
			angle = angle - adiff
			mVertexes.append(CGPoint(x: x, y: y))
		}

		/* calc bounds */
		let dx      = mRadius * cos(pi * 2.0 / 12.0) // 30 degree
		let dy      = mRadius
		let borigin = CGPoint(x: mCenter.x-dx, y: mCenter.y-dy)
		let bsize   = CGSize(width: dx*2.0, height: dy*2.0)
		mBounds = CGRect(origin: borigin, size: bsize)
	}

	public init(bounds bnds: CGRect, lineWidth l: CGFloat){
		let center = bnds.center
		let radius = min(bnds.size.width/2.0, bnds.size.height/2.0)
		self.init(center: center, lineWidth: l, radius: radius)
	}

	public var description: String {
		return "{center:\(center.description) radius:\(radius))"
	}
}

