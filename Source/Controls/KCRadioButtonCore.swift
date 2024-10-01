/**
 * @file	KCRadioButtonCore.swift
 * @brief	Define KCRadioButtonCore class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

import CoconutData
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

open class KCRadioButtonCore: KCCoreView
{
	public typealias CallbackFunction = (_ buttonid: Int) -> Void

	private var mButtonID: Int? 			 = nil
	private var mState: CNButtonState		 = .hidden
	private var mCallbackFunction: CallbackFunction? = nil
	private var mMinLabelWidth: Int			 = 8
        private var mSymbolManager                       = CNSymbolImages()

	#if os(OSX)
	@IBOutlet weak var mRadioButton: NSButton!
	#else
	@IBOutlet weak var mButton: UIButton!
	@IBOutlet weak var mLabel: UILabel!
	#endif

	public func setup(frame frm: CGRect){
		#if os(OSX)
		super.setup(isSingleView: false, coreView: mRadioButton)
		#else
		super.setup(isSingleView: false, coreView: mButton)
		#endif

		// Set label images for each status
		#if os(iOS)
		setButtonSymbol(symbol: .square,		state: .normal)
		setButtonSymbol(symbol: .checkmarkSquare,	state: .selected)
		#endif

		self.state = .off
	}

	#if os(iOS)
	private func setButtonSymbol(symbol sym: CNSymbol, state stat: UIControl.State) {
                let img = mSymbolManager.load(name: sym.name, size: .regular)
		mButton.setImage(img, for: stat)
		mButton.setTitle("", for: stat)
	}
	#endif

	public var buttonId: Int? {
		get         { return mButtonID }
		set(newval) { mButtonID = newval }
	}

	public var title: String {
		get {
			#if os(OSX)
				return mRadioButton.title
			#else
				return mLabel.text ?? ""
			#endif
		}
		set(newval) {
			#if os(OSX)
				mRadioButton.title = newval
			#else
				mLabel.text = newval
			#endif
		}
	}

	public var state: CNButtonState {
		get {
			return mState
		}
		set(newstat) {
			if mState != newstat {
				switch newstat {
				case .hidden:
					self.isVisible	= false
					self.isEnabled	= false
					self.isOn	= false
				case .disable:
					self.isVisible	= true
					self.isEnabled	= false
					self.isOn	= false
				case .off:
					self.isVisible	= true
					self.isEnabled	= true
					self.isOn	= false
				case .on:
					self.isVisible	= true
					self.isEnabled	= true
					self.isOn	= true
				@unknown default:
					CNLog(logLevel: .error, message: "Internal error", atFunction: #function, inFile: #file)
				}
				mState = newstat
			}
		}
	}

	private var isVisible: Bool {
		get {
			#if os(OSX)
				return !mRadioButton.isHidden
			#else
				return !mButton.isHidden
			#endif
		}
		set(newval) {
			#if os(OSX)
				mRadioButton.isHidden = !newval
			#else
				mButton.isHidden = !newval
				mLabel.isHidden  = !newval
			#endif
		}
	}

	private var isEnabled: Bool {
		get         {
			#if os(OSX)
				return mRadioButton.isEnabled
			#else
				return mButton.isEnabled
			#endif
		}
		set(newval) {
			#if os(OSX)
				mRadioButton.isEnabled = newval
			#else
				mButton.isEnabled = newval
				mLabel.isEnabled = newval
			#endif
		}
	}

	private var isOn: Bool {
		get {
			#if os(OSX)
				return mRadioButton.state != .off
			#else
				return mButton.state == .selected
			#endif
		}
		set(newval){
			#if os(OSX)
				mRadioButton.state = newval ? .on : .off
			#else
				mButton.isSelected = newval
			#endif
		}
	}

	public var callback: CallbackFunction? {
		get        { return mCallbackFunction }
		set(newval){ mCallbackFunction = newval }
	}

	public var minLabelWidth: Int {
		get         { return mMinLabelWidth }
		set(newval) { if newval >= 1 { mMinLabelWidth = newval }}
	}

	#if os(OSX)
	@IBAction func buttonPressed(_ sender: Any) {
		self.pressed()
	}
	#else
	@IBAction func puttonPressed(_ sender: Any) {
		self.pressed()
	}
	#endif

	private func pressed() {
		if let bid = mButtonID, let cbfunc = mCallbackFunction {
			cbfunc(bid)
		}
	}

        public func updateAppearance() {
            let vpref = CNPreference.shared.viewPreference
            let fgcol = vpref.controlColor(status: .normal)
            #if os(OSX)
            mRadioButton.setTitleColor(fgcol, for: .normal)
            #else
            mButton.setTitleColor(fgcol, for: .normal)
            #endif
        }

	#if os(OSX)
	public override var fittingSize: CGSize {
		get { return CGSize.minSize(contentsSize(), self.limitSize) }
	}
	#else
	public override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize.minSize(contentsSize(), self.limitSize)
	}
	#endif

	public override var intrinsicContentSize: CGSize {
		get { return CGSize.minSize(contentsSize(), self.limitSize) }
	}

	public override func contentsSize() -> CGSize {
		#if os(OSX)
			return mRadioButton.intrinsicContentSize
		#else
			let swsize  = mButton.intrinsicContentSize
			let labsize = mLabel.intrinsicContentSize
		return CNUnionSize(swsize, labsize, doVertical: false, spacing: 0.0)
		#endif
	}

	public override func adjustContentsSize(size sz: CGSize) -> CGSize {
		let cursize = self.intrinsicContentSize
		if cursize.width <= sz.width && cursize.height <= sz.height {
			return sz
		} else {
			CNLog(logLevel: .error, message: "Size underflow", atFunction: #function, inFile: #file)
			return cursize
		}
	}
}

