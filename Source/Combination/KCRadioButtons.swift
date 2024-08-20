/**
 * @file KCRadioButtons.swift
 * @brief Define KCRadioButtons class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCRadioButtons: KCStackView
{
	public struct Label {
		public var 	title	: String
		public var	id	: Int

		public init(title tval: String, id ival: Int){
			self.title	= tval
			self.id		= ival
		}
	}

	public typealias CallbackFunction = (_ labelid: Int?) -> Void

	private var mLabels:		Array<Label>
	private var mButtons:		Array<KCRadioButton>
	private var mCurrentIndex:	Int?
	private var mColumunNum:	Int
	private var mCallbackFunction:	CallbackFunction?

	#if os(OSX)
	public override init(frame : NSRect){
		mLabels     		= []
		mButtons		= []
		mCurrentIndex		= nil
		mColumunNum 		= 1
		mCallbackFunction	= nil
		super.init(frame: frame) ;
	}
	#else
	public override init(frame: CGRect){
		mLabels     		= []
		mButtons		= []
		mCurrentIndex		= nil
		mColumunNum 		= 1
		mCallbackFunction	= nil
		super.init(frame: frame)
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 270)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 346)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mLabels     		= []
		mButtons		= []
		mCurrentIndex		= nil
		mColumunNum 		= 1
		mCallbackFunction	= nil
		super.init(coder: coder)
	}

	public var columnNum: Int {
		get         { return mColumunNum }
		set(newval) {
			if newval >= 1 {
				mColumunNum = newval
			} else {
				CNLog(logLevel: .error, message: "Invalid numberOfColumns: \(newval)", atFunction: #function, inFile: #file)
			}
		}
	}

	public var currentIndex: Int? {
		get { return mCurrentIndex }
	}

	public var callback: CallbackFunction? {
		get         { return self.mCallbackFunction }
		set(newval) { self.mCallbackFunction = newval }
	}

	public func setLabels(labels labs: Array<Label>){
		guard labs.count >= 1 else {
			CNLog(logLevel: .error, message: "Invalid label num", atFunction: #function, inFile: #file)
			return
		}
		mLabels		= labs

		/* Clear subview */
		super.removeAllArrangedSubviews()
		mButtons = []

		let cbfunc: KCRadioButton.CallbackFunction = {
			(_ index: Int) -> Void in
			self.pressed(buttonId: index)
		}

		/* Allocate boxes to arrange some radio buttons */
		let labelnum = labs.count
		let rownum   = (labelnum + mColumunNum - 1) / mColumunNum
		var buttonid = 0
		for _ in 0..<rownum {
			let hbox  = KCStackView()
			hbox.axis = .horizontal
			for _ in 0..<mColumunNum {
				if buttonid < labelnum {
					let newbutton = KCRadioButton()
					newbutton.buttonId 	= buttonid
					newbutton.title    	= labs[buttonid].title
					newbutton.state    	= .off
					newbutton.callback 	= cbfunc
					buttonid += 1
					hbox.addArrangedSubView(subView: newbutton)
					mButtons.append(newbutton)
				}
			}
			super.addArrangedSubView(subView: hbox)
		}

		/* Set minimum label width */
		var minwidth = 4
		for i in 0..<labs.count {
			minwidth = max(minwidth, labs[i].title.lengthOfBytes(using: .utf8))
		}
		for i in 0..<mButtons.count {
			let button = mButtons[i]
			button.minLabelWidth = minwidth
		}

		/* there is not On index */
		mCurrentIndex = nil
	}

	public func select(labelId lid: Int) {
		if let bid = labelIdToButtonId(labelId: lid) {
			select(buttonId: bid)
		}
	}

	public func unselect() {
		select(buttonId: nil) // no selected button
	}

	private func select(buttonId bid: Int?) {
		let prev = mCurrentIndex

		/* Unselect current button */
		if let idx = mCurrentIndex {
			mButtons[idx].state = .off
			mCurrentIndex = nil
		}
		/* Select new one */
		if let newidx = bid {
			mButtons[newidx].state = .on
			mCurrentIndex = newidx
		}
		if prev != mCurrentIndex {
			self.callback(buttonId: mCurrentIndex)
		}
	}

	private func pressed(buttonId bid: Int) {
		guard bid < mButtons.count else {
			CNLog(logLevel: .error, message: "Invalid index: \(bid)", atFunction: #function, inFile: #file)
			return
		}
		select(buttonId: bid)
	}

	private func callback(buttonId bidp: Int?) {
		if let cbfunc = mCallbackFunction {
			if let bid = bidp {
				if let lid = buttonIdToLabelId(buttonId: bid) {
					cbfunc(lid)
				} else {
					CNLog(logLevel: .error, message: "Invalid button id: \(bid)", atFunction: #function, inFile: #file)
				}
			} else {
				cbfunc(nil)
			}
		}
	}

	public func setState(labelId lid: Int, state stat: CNButtonState) {
		guard let bid = labelIdToButtonId(labelId: lid) else {
			return
		}
		let target = mButtons[bid]
		target.state = stat
		if stat == .on {
			mCurrentIndex = bid
		}
		target.requireDisplay()
	}

	private func labelIdToButtonId(labelId lid: Int) -> Int? {
		for i in 0..<mLabels.count {
			if mLabels[i].id == lid {
				return i
			}
		}
		CNLog(logLevel: .error, message: "The button which has lael id \(lid) is not found", atFunction: #function, inFile: #file)
		return nil
	}

	private func buttonIdToLabelId(buttonId bid: Int) -> Int? {
		if 0 <= bid && bid < mButtons.count {
			return mLabels[bid].id
		} else {
			return nil
		}
	}
}

