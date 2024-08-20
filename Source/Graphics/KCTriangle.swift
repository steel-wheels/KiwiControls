/**
* @file	KGCircule.swift
* @brief	Define KGCircule data structure
* @par Copyright
*   Copyright (C) 2016 Steel Wheels Project
*/

import Foundation
import CoreGraphics

public struct KCTriangle
{
	public var bounds:	CGRect

	public init(bounds bnd: CGRect){
		bounds = bnd
	}

	public var top: CGPoint {
		get {
			let minx = bounds.origin.x
			let maxx = minx + bounds.size.width
			let midx = (minx + maxx) / 2.0
			let maxy = bounds.origin.y + bounds.size.height
			return CGPoint(x: midx, y: maxy)
		}
	}

	public var left: CGPoint {
		get {
			return bounds.origin
		}
	}

	public var right: CGPoint {
		get {
			let x = bounds.origin.x + bounds.size.width
			let y = bounds.origin.y
			return CGPoint(x: x, y: y)
		}
	}

	public var description: String {
		let topstr   = top.description
		let leftstr  = left.description
		let rightstr = right.description
		return "{top:\(topstr)}, left:\(leftstr),right:\(rightstr)}"
	}
}

