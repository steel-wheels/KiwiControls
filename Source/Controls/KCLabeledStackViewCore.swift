/**
 * @file	KCLabeledStackViewCore.swift
 * @brief Define KCLabeledStackViewCore class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCLabeledStackViewCore : KCCoreView
{
	#if os(OSX)
	@IBOutlet weak var mLabel: KCTextField!
	@IBOutlet weak var mStack: KCStackView!
	#else
	@IBOutlet weak var mLabel: KCTextField!
	@IBOutlet weak var mStack: KCStackView!
	#endif

	private var 	mMinWidth:	Int = 100

	public func setup(frame frm: CGRect) -> Void {
		super.setup(isSingleView: false, coreView: mStack)
		KCView.setAutolayoutMode(views: [self, mLabel, mStack])
		mLabel.isBold		= true
		mLabel.decimalPlaces	= 0
		self.title    		= "Title"
	}

	public var title: String {
		get { return mLabel.text }
		set(newstr){ mLabel.text = newstr }
	}

	public var contentsView: KCStackView {
		get { return mStack }
	}

	public var labelView: KCTextField {
		get { return mLabel }
	}

	open func addArrangedSubViews(subViews vs:Array<KCView>){
		mStack.addArrangedSubViews(subViews: vs)
	}

	open func addArrangedSubView(subView v: KCView){
		mStack.addArrangedSubView(subView: v)
	}

	open func arrangedSubviews() -> Array<KCView> {
		return mStack.arrangedSubviews()
	}

	public func updateAppearance() {
		mLabel.updateAppearance()
		mStack.updateAppearance()
	}

	private let LabelHeight : CGFloat = 20.0

	open override func setFrameSize(_ newsize: CGSize) {
		super.setFrameSize(newsize)

		/* Decide label size */
		let newlabsize = CGSize(width: newsize.width, height: LabelHeight)
		self.labelView.setFrameSize(newlabsize)


		/* Decide content size */
		let contwidth: CGFloat
		if newsize.width > LabelHeight {
			contwidth = newsize.width - LabelHeight
		} else {
			contwidth = 0.0
		}
		let contheight: CGFloat
		if newsize.height > LabelHeight {
			contheight = newsize.height - LabelHeight
		} else {
			contheight = 0.0
		}
		let contsize = CGSize(width: contwidth, height: contheight)
		#if os(OSX)
			mStack.setFrameSize(contsize)
		#else
			mStack.setFrameSize(contsize)
		#endif
	}

	#if os(OSX)
	open override var fittingSize: CGSize {
		get { return CGSize.minSize(contentsSize(), self.limitSize) }
	}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize.minSize(adjustContentsSize(size: size), self.limitSize)
	}
	#endif

	open override var intrinsicContentSize: CGSize {
		get { return CGSize.minSize(contentsSize(), self.limitSize) }
	}

	// The constant value for layout is depend on XIB file
	public override func contentsSize() -> CGSize {
		let textsize  = mLabel.intrinsicContentSize
		let stacksize = mStack.intrinsicContentSize
		let usize     = CNUnionSize(textsize, stacksize, doVertical: true, spacing: 0.0)
		return usize
	}

	public override func adjustContentsSize(size sz: CGSize) -> CGSize {
		let textsize  = mLabel.intrinsicContentSize
		let stacksize = mStack.intrinsicContentSize
		let usize     = CNUnionSize(textsize, stacksize, doVertical: true, spacing: 0.0)
		if usize.width <= sz.width && usize.height <= sz.height {
			return sz
		} else {
			CNLog(logLevel: .error, message: "Size underflow", atFunction: #function, inFile: #file)
			return usize
		}
	}

	public override func invalidateIntrinsicContentSize() {
		mLabel.invalidateIntrinsicContentSize()
		mStack.invalidateIntrinsicContentSize()
		super.invalidateIntrinsicContentSize()
	}
}

