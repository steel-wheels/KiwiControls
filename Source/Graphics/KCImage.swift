/**
 * @file	KCImage.swift
 * @brief	Extend KCImage class
 * @par Copyright
 *   Copyright (C) 2016 Steel Wheels Project
 * @par Reference
 *    http://qiita.com/HaNoHito/items/2fe95aba853f9cedcd3e
 */

import CoconutData
import Foundation

#if os(iOS)
import UIKit
#else
import Cocoa
#endif

public typealias KCImageDrawer = (_ context: CGContext, _ bounds: CGRect) -> Void

#if os(OSX)

extension NSImage
{
	public class func generate(context ctxt: CGContext, bounds bnds:CGRect, drawFunc dfunc: KCImageDrawer) -> NSImage {
		let newimg = NSImage(size: bnds.size)
		newimg.lockFocus()
		dfunc(ctxt, bnds)
		newimg.unlockFocus()
		return newimg
	}

	/* https://stackoverflow.com/questions/11949250/how-to-resize-nsimage */
	public func resized(to _size: NSSize) -> NSImage? {
		let targetsize = self.size.resizeWithKeepingAscpect(inSize: _size)

		if let bitmapRep = NSBitmapImageRep(
		    bitmapDataPlanes: nil, pixelsWide: Int(targetsize.width), pixelsHigh: Int(targetsize.height),
		    bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
		    colorSpaceName: .calibratedRGB, bytesPerRow: 0, bitsPerPixel: 0
		) {
		    bitmapRep.size = targetsize
		    NSGraphicsContext.saveGraphicsState()
		    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmapRep)
		    draw(in: NSRect(x: 0, y: 0, width: targetsize.width, height: targetsize.height), from: .zero, operation: .copy, fraction: 1.0)
		    NSGraphicsContext.restoreGraphicsState()

		    let resizedImage = NSImage(size: targetsize)
		    resizedImage.addRepresentation(bitmapRep)
		    return resizedImage
		}
	    return nil
	}

	public var toCGImage: CGImage {
		var imageRect = NSRect(x: 0, y: 0, width: size.width, height: size.height)
		#if swift(>=3.0)
			guard let image = cgImage(forProposedRect: &imageRect, context: nil, hints: nil) else {
				abort()
			}
		#else
			guard let image = CGImageForProposedRect(&imageRect, context: nil, hints: nil) else {
				abort()
			}
		#endif
		return image
	}
}

#endif

#if os(iOS)

extension UIImage
{
	public convenience init?(contentsOf url: URL){
		do {
			let data = try Data(contentsOf: url)
			self.init(data: data)
		} catch {
			return nil
		}
	}

	public class func generate(context: CGContext, bounds bnds:CGRect, drawFunc: KCImageDrawer) -> UIImage {
		var newimage: UIImage? = nil

		UIGraphicsBeginImageContext(bnds.size)

		drawFunc(context, bnds)
		newimage = UIGraphicsGetImageFromCurrentImageContext()

		UIGraphicsEndImageContext()

		if let result = newimage {
			return result
		} else {
			fatalError("Can not get current context")
		}
	}

	public func resized(to _size: CGSize) -> CNImage? {
		/* Copied from https://develop.hateblo.jp/entry/iosapp-uiimage-resize */

		let targetsize = self.size.resizeWithKeepingAscpect(inSize: _size)
		UIGraphicsBeginImageContextWithOptions(targetsize, false, 0.0)
		draw(in: CGRect(origin: .zero, size: targetsize))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()

		return resizedImage
	}

	public var toCGImage: CGImage {
		if let cgimg = self.cgImage {
			return cgimg
		} else {
			fatalError("Can not convert to CGImage")
		}
	}
}

#endif

extension CGImage {
	public var size: CGSize {
		#if swift(>=3.0)
		#else
			let width  = CGImageGetWidth(self)
			let height = CGImageGetHeight(self)
		#endif
		return CGSize(width: width, height: height)
	}

	#if os(OSX)
	public var toNSImage: NSImage {
		#if swift(>=3.0)
			return NSImage(cgImage: self, size: size)
		#else
			return NSImage(CGImage: self, size: size)
		#endif
	}
	#endif
}


