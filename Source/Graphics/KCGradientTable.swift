/**
 * @file	KCGradiend.swift
 * @brief	Define KCGradient data structure
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 */

import CoreGraphics
import Foundation

public class KCGradientTable
{
	public static let sharedGradientTable = KCGradientTable()

	private var mGradientTable: Dictionary<String, CGGradient>

	private init() {
		mGradientTable = [:]
	}

	public func gradient(forColor color: CGColor, doDebug dd: Bool = false) -> CGGradient {
		let key:String = "\(color.components!.description)"
		if let Gradient = mGradientTable[key] {
			return Gradient
		} else {
			let newGradient = KCAllocateGradient(baseColor: color, doDebug: dd)
			mGradientTable[key] = newGradient
			return newGradient
		}
	}
}

private func KCAllocateGradient(baseColor color:CGColor, doDebug dd: Bool = false) -> CGGradient
{
	let num    = color.numberOfComponents
	if let source = color.components {
		let count             = Int(5)
		let rates: [CGFloat]  = [1.00, 0.84, 0.68, 0.50, 0.00]

		var rate   = CGFloat(1.0)
		let rdiff  = rate / CGFloat(count)
		var components: Array<CGFloat> = []
		var locations:  Array<CGFloat> = []
		for i in 0..<count {
			for j in 0..<num {
				components.append(source[j] * rates[i])
			}
			locations.insert(rate, at: 0)
			rate -= rdiff
		}

		if dd {
			dumpForDebug(componentNum: num, count: count, components: components, locations: locations)
		}

		let colorspace = CGColorSpaceCreateDeviceRGB()
		if let Gradient = CGGradient(colorSpace: colorspace, colorComponents: components, locations: locations, count: count){
			return Gradient
		}
	}
	fatalError("Can not allocate Gradient")
}

private func dumpForDebug(componentNum num: Int, count cnt:Int, components comp: Array<CGFloat>, locations loc: Array<CGFloat>) {
	Swift.print("componentNum=\(num), count=\(cnt)")
	Swift.print("components:")
	for i in 0..<cnt {
		for j in 0..<num {
			let v = comp[i*num + j]
			Swift.print("\(v) ", terminator: "")
		}
		Swift.print("")
	}
	Swift.print("locations: \(loc)")
}
