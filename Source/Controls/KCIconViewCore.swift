/**
 * @file	KCIconViewCore.swift
 * @brief	Define KCIconViewCore class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

#if os(OSX)
public class KCIconButtonCell: NSButtonCell {
	public override func highlight(_ flag: Bool, withFrame cellFrame: NSRect, in controlView: NSView) {
		self.isHighlighted = flag
	}
}
#endif

open class KCIconViewCore : KCCoreView
{
    public typealias CallbackFunction = (_ index: Int) -> Void
    public var buttonPressedCallback: CallbackFunction? = nil

#if os(OSX)
    @IBOutlet weak var mImageButton: NSButton!
#else
    @IBOutlet weak var mImageButton: UIButton!
#endif

    private var mIdNumber:      Int         = 0
    private var mTargetSize:    CGSize?     = nil
    private var mSymbol:        CNSymbol    = .character

    public func setup(frame frm: CGRect){
        super.setup(isSingleView: true, coreView: mImageButton)
        KCView.setAutolayoutMode(views: [self, mImageButton])

        #if os(OSX)
        mImageButton.imageScaling   = .scaleProportionallyUpOrDown
        mImageButton.isTransparent  = false    // Required to display icon
        mImageButton.bezelStyle     = .regularSquare
        mImageButton.isBordered     = true
        mImageButton.imagePosition  = .imageAbove
        mImageButton.title          = "Untutled"
        mImageButton.lineBreakMode  = .byWordWrapping
        #else
        var conf = UIButton.Configuration.bordered()
        conf.imagePlacement = .top
        conf.title = "Untutled"
        conf.titleLineBreakMode = .byWordWrapping
        mImageButton.configuration = conf
        #endif
        setSymbol(mSymbol)
        updateAppearance()
    }

    public var symbol: CNSymbol {
        get         { return mSymbol }
        set(sym)    {
            setSymbol(sym)
            mSymbol = sym
        }
    }

    public var title: String {
        get {
            return getTitle()
        }
        set(ttl) {
            setTitle(ttl)
        }
    }

    public var targetSize: CGSize? {
        get          { return mTargetSize }
        set(newsize) { mTargetSize = newsize }
    }

    public var idNumber: Int {
        get      { return mIdNumber }
        set(val) { mIdNumber = val  }
    }

    #if os(OSX)
    open override var fittingSize: CGSize { get {
        return CGSize.minSize(contentsSize(), self.limitSize)
    }}
    #else
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize.minSize(contentsSize(), self.limitSize)
    }
    #endif

    public override var intrinsicContentSize: CGSize { get {
        return contentSize()
    }}

    private func contentSize() -> CGSize {
        let result = mImageButton.intrinsicContentSize
        return result
    }

    public override func setFrameSize(_ size: CGSize) {
        #if os(OSX)
        mImageButton.setFrameSize(size)
        #else
        mImageButton.setFrame(size: size)
        #endif
        super.setFrameSize(size)
    }

    public func updateAppearance() {
        let vpref = CNPreference.shared.viewPreference

        /* set button */
        let btnfg = vpref.graphicsForegroundColor()
        #if os(OSX)
        mImageButton.contentTintColor = btnfg
        #else
        mImageButton.setTitleColor(btnfg, for: .normal)
        #endif
    }

    private func setSymbol(_ sym: CNSymbol) {
        let img = CNSymbolImages.shared.load(name: sym.name, size: .regular)
        let padimg = img.expand(xPadding: 12.0, yPadding: 12.0)
        let extimg: CNImage
        if let targsize = mTargetSize {
            let xtarg = targsize.width  - padimg.size.width
            let ytarg = targsize.height - padimg.size.height
            if (xtarg > 0.0 && ytarg >= 0.0) || (xtarg >= 0.0 || ytarg > 0.0) {
                extimg = padimg.expand(xPadding: xtarg/2.0, yPadding: ytarg/2.0)
            } else {
                extimg = padimg
            }
        } else {
            extimg = padimg
        }
        #if os(OSX)
            mImageButton.image = extimg
            mImageButton.needsLayout = true
        #else
            mImageButton.configuration?.image = extimg
            mImageButton.setNeedsUpdateConfiguration()
        #endif
    }

    private func setTitle(_ ttl: String) {
        #if os(OSX)
            mImageButton.title = ttl
            mImageButton.needsLayout = true
        #else
            mImageButton.configuration?.title = ttl
            mImageButton.setNeedsUpdateConfiguration()
        #endif
    }

    private func getTitle() -> String {
        #if os(OSX)
            return mImageButton.title
        #else
            return mImageButton.configuration?.title ?? "Untitled"
        #endif
    }

    #if os(OSX)
    @IBAction func buttonPressed(_ sender: Any) {
        if let callback = buttonPressedCallback {
            callback(mIdNumber)
        }
    }
    #else
    @IBAction func buttonPressed(_ sender: Any) {
        if let callback = buttonPressedCallback {
            callback(mIdNumber)
        }
    }
    #endif
}
