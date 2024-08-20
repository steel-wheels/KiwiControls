/**
 * @file	KCTableCellView.swift
 * @brief	Define KCTableCellView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation
#if os(OSX)
import Cocoa
#else
import UIKit
#endif

public protocol KCTableCellViewProtocol
{
	var value: CNValue? { set get }
	var isEditable: Bool { set get }
}

public protocol KCTableCellDelegate {
	func tableCellView(shouldEndEditing view: KCTableCellView, columnTitle title: String, rowIndex ridx: Int, value val: CNValue)
}

#if os(OSX)
public class KCTableCellView: NSTableCellView, KCTableCellViewProtocol, NSTextFieldDelegate
{
	private var mDelegate:		KCTableCellDelegate? = nil
	private var mTitle		= ""
	private var mRowIndex		= -1
	private var mIsInitialized	= false

	public func setup(title tstr: String, row ridx: Int, delegate dlg: KCTableCellDelegate){
		mTitle		= tstr
		mRowIndex	= ridx
		mDelegate	= dlg
		guard !mIsInitialized else {
			return // already initialized
		}
		if let field = super.textField {
			field.delegate = self
		}
		mIsInitialized = true
	}

	public var value: CNValue? {
		get         { return self.objectValue as? CNValue }
		set(newval) { self.objectValue = newval }
	}

	public override var objectValue: Any? {
		get {
			return super.objectValue
		}
		set(newval){
			if let nval = newval as? CNValue {
				updateValue(value: nval)
			}
			super.objectValue = newval
		}
	}

	private func updateValue(value val: CNValue){
		if let field = super.textField {
			field.stringValue = val.description
			field.sizeToFit()
		} else {
			let newfield = NSTextField(string: val.description)
			super.textField = newfield
			newfield.sizeToFit()
		}
	}

	private func updateImageValue(value val: CNImage){
		if let imgview = super.imageView {
			imgview.image = val
		} else {
			let newimage = NSImageView()
			newimage.image = val
			super.imageView = newimage
		}
	}

	public var firstResponderView: KCViewBase? { get {
		if let field = self.textField {
			return field
		} else if let imgview = self.imageView {
			return imgview
		} else {
			return nil
		}
	}}

	public var isEditable: Bool {
		get {
			if let field = self.textField {
				return field.isEditable
			} else {
				return false
			}
		}
		set(newval){
			if let field = self.textField {
				field.isEditable = newval
				if newval {
					field.needsDisplay = true
				}
			} else if let _ = self.imageView {
				// do nothing
			} else {
				// do nothing
			}
		}
	}

	public var isEnabled: Bool {
		get {
			if let field = self.textField {
				return field.isEnabled
			} else if let img = self.imageView {
				return img.isEnabled
			} else {
				return false
			}
		}
		set(newval){
			if let field = self.textField {
				field.isEnabled = newval
				if newval {
					field.textColor = NSColor.controlTextColor
				} else {
					field.textColor = NSColor.disabledControlTextColor
				}
			} else if let img = self.imageView {
				img.isEnabled = newval
			} else {
				// do nothing
			}
		}
	}

	public override var intrinsicContentSize: NSSize {
		get {
			if let field = self.textField {
				return self.intrinsicContentSize(ofTextField: field)
			} else if let img = self.imageView {
				return img.intrinsicContentSize
			} else {
				return super.intrinsicContentSize
			}
		}
	}

	private func intrinsicContentSize(ofTextField field: NSTextField) -> CGSize {
		let DefaultLength: Int = 4

		let curnum = field.stringValue.count
		let newnum = max(curnum, DefaultLength)

		let fitsize = field.fittingSize

		let newwidth: CGFloat
		if let font = field.font {
			let attr = [NSAttributedString.Key.font: font]
			let str: String = " "
			let fsize = str.size(withAttributes: attr)
			newwidth = max(fitsize.width, fsize.width * CGFloat(newnum))
		} else {
			newwidth = fitsize.width
		}

		field.preferredMaxLayoutWidth = newwidth
		return CGSize(width: newwidth, height: fitsize.height)
	}

	public override var fittingSize: CGSize {
		get {
			if let field = self.textField {
				return field.fittingSize
			} else if let img = self.imageView {
				return img.fittingSize
			} else {
				return super.fittingSize
			}
		}
	}

	public override func setFrameSize(_ newsize: CGSize) {
		let fitsize = self.fittingSize
		if fitsize.width <= newsize.width && fitsize.height <= newsize.height {
			self.setFrameSizeBody(size: newsize)
		} else {
			self.setFrameSizeBody(size: fitsize)
		}
	}

	private func setFrameSizeBody(size newsize: CGSize){
		super.setFrameSize(newsize)
		if let field = self.textField {
			field.setFrameSize(newsize)
		} else if let img = self.imageView {
			img.setFrameSize(newsize)
		}
	}

	public override func hitTest(_ point: NSPoint) -> NSView? {
		if let field = self.textField {
			return field
		} else if let img = self.imageView {
			return img
		} else {
			return super.hitTest(point)
		}
	}

	/* NSTextFieldDelegate */
	public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
		return self.isEditable
	}

	public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
		if let dlg = mDelegate {
			let val: CNValue = .stringValue(fieldEditor.string)
			dlg.tableCellView(shouldEndEditing: self, columnTitle: mTitle, rowIndex: mRowIndex, value: val)
		}
		return true
	}
}

#else  // os(OSX)

public class KCTableCellView: UITableViewCell, KCTableCellViewProtocol, UITextFieldDelegate
{
	private var mTextField: UITextField
	private var mIsDirty:	Bool
	private var mDelegate:	KCTableCellDelegate?
	private var mTitle:	String
	private var mRowIndex:	Int

	public override init(style stl: UITableViewCell.CellStyle, reuseIdentifier ident: String?) {
		mTextField = UITextField(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0))
		mIsDirty   = false
		mDelegate  = nil
		mTitle	   = "?"
		mRowIndex  = -1
		super.init(style: stl, reuseIdentifier: ident)

		/* Add label as a sub view */
		mTextField.frame  = self.frame ; mTextField.bounds = self.bounds
		mTextField.isUserInteractionEnabled = false // not editable
		mTextField.delegate = self
		self.contentView.addSubview(mTextField)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setup(title tstr: String, row ridx: Int, delegate dlg: KCTableCellDelegate){
		mTitle		= tstr
		mRowIndex	= ridx
		mDelegate	= dlg
	}

	public var isEditable: Bool {
		get         { return mTextField.isUserInteractionEnabled }
		set(newval) {
			mTextField.isUserInteractionEnabled = newval
			if !newval && mIsDirty {
				notifyEndEditing()
			}
		}
	}

	public var value: CNValue? {
		get {
			if let txt = mTextField.text {
				return .stringValue(txt)
			} else {
				return nil
			}
		}
		set(newval) {
			if let val = newval {
				mTextField.text = val.toString()
			} else {
				mTextField.text = ""
			}
		}
	}

	private func notifyEndEditing() {
		if let dlg = mDelegate, let txt = mTextField.text {
			let val: CNValue = .stringValue(txt)
			dlg.tableCellView(shouldEndEditing: self, columnTitle: mTitle, rowIndex: mRowIndex, value: val)
			mIsDirty = false
		}
	}

	/* UITextFieldDelegete */
	public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
		if mTextField.isUserInteractionEnabled {
			mIsDirty = true
			return true
		} else {
			return false
		}
	}

	public func textFieldDidEndEditing(_ textField: UITextField) {
		notifyEndEditing()
	}
}

#endif // os(OSX)

