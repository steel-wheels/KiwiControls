/**
 * @file    KCCollectionViewItem.swift
 * @brief    Define KCCollectionViewItem class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
public typealias KCCollectionViewItemBase = NSCollectionViewItem
#else
import UIKit
public typealias KCCollectionViewItemBase = UICollectionViewCell
#endif
import CoconutData

import Foundation

public class KCCollectionViewItem: KCCollectionViewItemBase
{
    public typealias CallbackFunction = (_ index: Int) -> Void
    public var buttonPressedCallback: CallbackFunction? = nil

    private var mIconView:          KCIconView

    public init(idNumber idnum: Int, symbol sym: CNSymbol, title ttl: String, targetSize targsize: CGSize){
        mIconView               = KCIconView()
        mIconView.targetSize    = targsize      // must be set before symbol
        mIconView.idNumber      = idnum
        mIconView.symbol        = sym
        mIconView.title         = ttl

        #if os(OSX)
        super.init(nibName: nil, bundle: nil)
        #else
        super.init(frame: CGRect.zero)
        #endif

        #if os(OSX)
            self.view = mIconView
        #else
            self.contentView.addSubview(mIconView)
        #endif

        mIconView.buttonPressedCallback = {
            (_ index: Int) -> Void in
            if let cbfunc = self.buttonPressedCallback {
                cbfunc(index)
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("Do not call this constructor")
    }

    public var intrinsicContentsSize: CGSize { get {
        return mIconView.intrinsicContentSize
    }}

    public func setFrameSize(_ size: CGSize) {
        self.view.setFrameSize(size)
        mIconView.setFrameSize(size)
    }
}
