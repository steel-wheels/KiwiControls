/**
 * @file    KCLabelViewCore.swift
 * @brief    Define KCLabel;Core class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCLabelViewCore : KCCoreView, NSTextFieldDelegate
{
	#if os(iOS)
	@IBOutlet weak var mLabel: UILabel!
	#endif
	#if os(OSX)
	@IBOutlet weak var mLabel: NSTextField!
	#endif

    private let mDecimalPlace   = 2

    public func setup(frame frm: CGRect){
        super.setup(isSingleView: true, coreView: mLabel)
        KCView.setAutolayoutMode(views: [self, mLabel])

        #if os(OSX)
            mLabel.delegate = self
            mLabel.isEditable = false
        #else
        #endif
        self.isEnabled = true
        self.alignment = .left
    }

    public var isEnabled: Bool {
        get       { return mLabel.isEnabled     }
        set(newval){ mLabel.isEnabled = newval  }
    }

    public var alignment: NSTextAlignment {
        get {
            #if os(OSX)
                return mLabel.alignment
            #else
                return mLabel.textAlignment
            #endif
        }
        set(align){
            #if os(OSX)
                mLabel.alignment = align
            #else
                mLabel.textAlignment = align
            #endif
        }
    }

    public var text: String {
        get {
            #if os(OSX)
            return mLabel.stringValue
            #else
            return mLabel.text ?? ""
            #endif
        }
        set(newval) {
            #if os(OSX)
            mLabel.stringValue = newval
            #else
            mLabel.text = newval
            #endif
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
                let dval = num.doubleValue
                let str: String
                if dval.truncatingRemainder(dividingBy: 1) == 0.0 {
                    str = "\(Int(dval))"
                } else {
                    str = String(format: "%.*lf", mDecimalPlace, dval)
                }
                self.text = str
            } else {
                self.text = ""
            }
        }
    }

	public func updateAppearance() {
		let vpref = CNPreference.shared.viewPreference
		mLabel.textColor = vpref.textColor(status: .normal)
	}
}

