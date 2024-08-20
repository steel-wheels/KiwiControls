/**
 * @file	KCVertices.swift
 * @brief	Define KCVertices data structure
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

#if os(iOS)
import UIKit
#endif
import Foundation

public struct KCVertices
{
	private var mVertices	: Array<CGPoint>
	private var mBounds	: CGRect

	public init(){
		mVertices = []
		mBounds   = CGRect.zero
	}

	public var vertices: Array<CGPoint> { return mVertices }

	public init(veritces vs: Array<CGPoint>){
		if vs.count > 0 {
			mVertices = vs
			mBounds   = KCVertices.allocateBoundRect(vertices: vs)
		} else {
			mVertices = []
			mBounds   = CGRect.zero
		}
	}

	private static func allocateBoundRect(vertices vs: Array<CGPoint>) -> CGRect {
		if vs.count == 0 {
			return CGRect.zero
		}
		/* Check 1st point */
		let o0   = vs[0]
		var xmin = o0.x
		var xmax = xmin
		var ymin = o0.y
		var ymax = ymin
		/* Check 2nd, 3rd, ... */
		let count = vs.count
		for i in 1..<count {
			let on = vs[i]
			if on.x < xmin {
				xmin = on.x
			} else if xmax < on.x {
				xmax = on.x
			}
			if on.y < ymin {
				ymin = on.y
			} else if ymax < on.y {
				ymax = on.y
			}
		}
		return CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
	}
}
