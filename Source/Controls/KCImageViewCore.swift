/**
 * @file	KCImageViewCore.swift
 * @brief	Define KCImageViewCore class
 * @par Copyright
 *   Copyright (C) 2018-2022 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCImageViewCore : KCCoreView
{
    public enum Alignment {
        case left
        case center
        case right
    }

	#if os(OSX)
	@IBOutlet weak var mImageView: NSImageView!
	#else
	@IBOutlet weak var mImageView: UIImageView!
	#endif

	private var mImageSize:		CGSize	= CGSize.zero
	private var mScale:		CGFloat  = 1.0
	private let mMinimumSize:	CGSize   = CGSize(width: 10.0, height: 10.0)

	public func setup(frame frm: CGRect){
		super.setup(isSingleView: true, coreView: mImageView)
		KCView.setAutolayoutMode(views: [self, mImageView])
		#if os(OSX)
			mImageView.imageScaling = .scaleProportionallyUpOrDown
		#else
			mImageView.contentMode  = .scaleAspectFit
		#endif
	}


	public var image: CNImage? {
		get {
			return mImageView.image
		}
		set(val){
			if let img = val {
				mImageSize	 = img.size
				mImageView.image = img
				setupImage(image: img, scale: mScale)
			} else {
				mImageSize	 = CGSize.zero
				mImageView.image = nil
			}
		}
	}

	public var scale: CGFloat {
		get {
			return mScale
		}
		set(val){
			mScale = val
			setupImage(image: mImageView.image, scale: mScale)
		}
	}

    public var alignment: KCImageViewCore.Alignment {
        get {
            let result: KCImageViewCore.Alignment
            #if os(OSX)
            switch(mImageView.imageAlignment){
            case .alignLeft:    result = .left
            case .alignCenter:  result = .center
            case .alignRight:   result = .right
            default:
                CNLog(logLevel: .error, message: "Unsupported alignment", atFunction: #function, inFile: #file)
                result = .left
            }
            #else
            switch(mImageView.contentMode){
            case .left:         result = .left
            case .center:       result = .center
            case .right:        result = .right
            default:
                CNLog(logLevel: .error, message: "Unsupported alignment", atFunction: #function, inFile: #file)
                result = .left
            }
            #endif
            return result
        }
        set(align){
            #if os(OSX)
            switch(align){
            case .left:     mImageView.imageAlignment = .alignLeft
            case .center:   mImageView.imageAlignment = .alignCenter
            case .right:    mImageView.imageAlignment = .alignRight
            }
            #else
            switch(align){
            case .left:     mImageView.contentMode = .left
            case .center:   mImageView.contentMode = .center
            case .right:    mImageView.contentMode = .right
            }
            #endif
        }
    }

	private func setupImage(image imgp: CNImage?, scale scl: CGFloat){
		if let img = imgp {
			mImageView.image = img
		} else {
			mImageView.image = nil
		}
		setFrameSize(self.imageSize)
		#if os(iOS)
		mImageView.center = CGPoint(x: self.frame.width / 2.0, y: self.frame.height / 2.0)
		#endif
		self.invalidateIntrinsicContentSize()
	}

	#if os(OSX)
	open override var fittingSize: CGSize { get {
		return CGSize.minSize(contentsSize(), self.limitSize)
	}}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize.minSize(adjustContentsSize(size: size), self.limitSize)
	}
	#endif

	open override var intrinsicContentSize: CGSize {
		get { return CGSize.minSize(contentsSize(), self.limitSize) }
	}

	public var imageSize: CGSize { get {
		return CNScaledSize(size: mImageSize, scale: mScale)
	}}

	public override func contentsSize() -> CGSize {
		return self.imageSize
	}

	public override func adjustContentsSize(size tsize: CGSize) -> CGSize {
		return self.imageSize.resizeWithKeepingAscpect(inSize: tsize)
	}
}

