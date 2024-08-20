/**
 * @file	KCTexFieldtCore.swift
 * @brief	Define KCTextFieldCore class
 * @par Copyright
 *   Copyright (C) 2018-2023 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

#if os(iOS)
public protocol NSTextFieldDelegate {

}
#endif

open class KCTextFieldCore : KCCoreView, NSTextFieldDelegate
{
    public typealias CallbackFunction = (_ str: String) -> Void

#if os(OSX)
    @IBOutlet weak var mTextField: NSTextField!
#else
    @IBOutlet weak var mTextField: UITextField!
#endif

    private var 	mIsBold:		    Bool	= false
    private var 	mDecimalPlaces:		Int		= 0
    private var 	mMinWidth:		    Int		= 40
    private var     mPrerefedSize:      CGSize  = CGSize.zero

    private var	mCurrentValue:		CNValue = CNValue.null

    public var 	callbackFunction:	CallbackFunction? = nil

    public func setup(frame frm: CGRect){
        super.setup(isSingleView: true, coreView: mTextField)
        KCView.setAutolayoutMode(views: [self, mTextField])
#if os(OSX)
        if let cell = mTextField.cell {
            cell.wraps		= true
            cell.isScrollable	= false
        }
#endif

#if os(OSX)
        mTextField.delegate = self
        mTextField.lineBreakMode	= .byWordWrapping
#else
        mTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
#endif

        /* Initialize */
        self.isEnabled	= true
        self.isEditable	= false
        setFormat(isNumber: false, isBold: mIsBold, isEditable: self.isEditable, decimalPlaces: mDecimalPlaces)
        mCurrentValue	= .stringValue("")
    }

    public var hasBackgrooundColor: Bool {
        get {
            return mTextField.backgroundColor != nil
        }
        set(newval){
            if newval {
                let bgcol = CNPreference.shared.viewPreference.rootBackgroundColor(status: .normal)
                mTextField.backgroundColor = bgcol
            } else {
                mTextField.backgroundColor = nil
            }
#if os(OSX)
            mTextField.drawsBackground = newval
#endif
        }
    }

    public var isBold: Bool {
        get         { return mIsBold }
        set(newval) { mIsBold = newval }
    }

    public var decimalPlaces: Int {
        get { return mDecimalPlaces }
        set(newval){ mDecimalPlaces = newval }
    }

    public var isEditable: Bool {
        get {
#if os(OSX)
            return mTextField.isEditable
#else
            return false
#endif
        }
        set(newval) {
#if os(OSX)
            mTextField.isEditable = newval
#endif
        }
    }

    public var isEnabled: Bool {
        get	   { return mTextField.isEnabled		}
        set(newval){ mTextField.isEnabled = newval	}
    }

    public var font: CNFont? {
        get {
            return mTextField.font
        }
        set(font){
            mTextField.font = font
        }
    }

    public var alignment: NSTextAlignment {
        get {
#if os(OSX)
            return mTextField.alignment
#else
            return mTextField.textAlignment
#endif
        }
        set(align){
#if os(OSX)
            mTextField.alignment = align
#else
            mTextField.textAlignment = align
#endif
        }
    }

    public var text: String {
        get {
#if os(OSX)
            return mTextField.stringValue
#else
            if let t = mTextField.text {
                return t
            } else {
                return ""
            }
#endif
        }
        set(newval) {
            setFormat(isNumber: false, isBold: mIsBold, isEditable: self.isEditable, decimalPlaces: mDecimalPlaces)
            setString(string: newval)
            mCurrentValue = .stringValue(newval)
        }
    }

    public var number: NSNumber? {
        get {
            if let val = Double(self.text) {
                return NSNumber(value: val)
            } else {
                return nil
            }
        }
        set(newval){
            if let num = newval {
                setFormat(isNumber: true, isBold: mIsBold, isEditable: self.isEditable, decimalPlaces: mDecimalPlaces)
                setNumber(number: num, decimalPlaces: self.decimalPlaces)
                mCurrentValue = .numberValue(num)
            }
        }
    }

#if os(OSX)
    public override var acceptsFirstResponder: Bool { get {
        return mTextField.acceptsFirstResponder
    }}
#endif

    public override func becomeFirstResponder() -> Bool {
        return mTextField.becomeFirstResponder()
    }

    private func setString(string str: String) {
#if os(OSX)
        if self.isEditable {
            mTextField.placeholderString = str
        } else {
            mTextField.stringValue = str
        }
#else
        mTextField.text        = str
#endif
        mTextField.invalidateIntrinsicContentSize()
    }

    private func setNumber(number num: NSNumber, decimalPlaces dplaces: Int?) {
        let newstr: String
        if let dp = dplaces {
            if 0 <= dp {
                newstr = String(format: "%.*lf", dp, num.doubleValue)
            } else {
                newstr = "\(num.intValue)"
            }
        } else {
            newstr = "\(num.intValue)"
        }
        setString(string: newstr)
    }

    private func setFormat(isNumber num: Bool, isBold bld: Bool, isEditable edt: Bool, decimalPlaces dplace: Int) {
        /* Set font */
        let font: CNFont
        if num {
            font = CNFont.monospacedSystemFont(ofSize: CNFont.systemFontSize, weight: .regular)
        } else if bld {
            font = CNFont.boldSystemFont(ofSize: CNFont.systemFontSize)
        } else {
            font = CNFont.systemFont(ofSize: CNFont.systemFontSize)
        }
        mTextField.font = font

        /* Set attributes */
        #if os(OSX)
        mTextField.isEditable		= edt
        mTextField.usesSingleLineMode 	= true
        if num {
            /* For number */
            let numform = NumberFormatter()
            numform.numberStyle		= .decimal
            numform.maximumFractionDigits	= dplace
            numform.minimumFractionDigits	= dplace
            mTextField.formatter		= numform
        } else {
            /* for text */
            mTextField.formatter		= nil
        }
        #endif

        /* Set bezel */
        #if os(OSX)
        mTextField.isBezeled   = edt
        #else
        mTextField.borderStyle = edt ? .bezel : .none
        #endif
    }

    public override func setFrameSize(_ newsize: CGSize) {
        mPrerefedSize = newsize
        super.setFrameSize(newsize)
    }

    open override var intrinsicContentSize: CGSize { get {
        return contentsSize()
    }}

    #if os(OSX)
    open override var fittingSize: CGSize { get {
        return contentsSize()
    }}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return contentsSize()
	}
	#endif

    public override func contentsSize() -> CGSize {
        let fontsize = self.fontSize(font: mTextField.font)
        let minwidth  = fontsize.width * CGFloat(mMinWidth)
        let minheight = fontsize.height
        let result: CGSize
        if mPrerefedSize.width > 0.0 && mPrerefedSize.height > 0.0 {
            let width  = max(mPrerefedSize.width,  minwidth)
            let height = max(mPrerefedSize.height, minheight)
            result = CGSize(width: width, height: height)
        } else {
            result = CGSize(width: minwidth, height: minheight)
        }
        return result
    }

	#if os(OSX)
	public func controlTextDidEndEditing(_ obj: Notification) {
		notifyTextDidEndEditing()
	}

	public func controlTextDidChange(_ obj: Notification) {
		notifyTextDidEndEditing()
	}
	#else
	@objc public func textFieldDidChange(_ textEdit: KCTextField) {
		notifyTextDidEndEditing()
	}
	#endif

	private func notifyTextDidEndEditing() {
		if let cbfunc = self.callbackFunction {
			cbfunc(self.text)
		}
	}
}

