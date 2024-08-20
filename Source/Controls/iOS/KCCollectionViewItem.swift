/**
 * @file    KCCollectionViewItem.swift
 * @brief    Define KCButton class
 * @par Copyright
 *   Copyright (C) 2016-2017 Steel Wheels Project
 */

import UIKit
import CoconutData
import Foundation

public class KCCollectionViewItem: UICollectionViewCell
{
    public typealias CallbackFunction = (_ index: Int) -> Void
    public var buttonPressedCallback: CallbackFunction? = nil

    @IBOutlet weak var mIconView: KCIconView!

    public func setFrameSize(_ size: CGSize) {
        mIconView.setFrame(size: size)
    }

    public func set(idNumber idnum: Int, symbol sym: CNSymbol, title ttl: String, targetSize targsize: CGSize) {
        mIconView.targetSize    = targsize
        mIconView.idNumber      = idnum
        mIconView.symbol        = sym
        mIconView.title         = ttl
        mIconView.buttonPressedCallback = {
            (_ index: Int) -> Void in
            if let cbfunc = self.buttonPressedCallback {
                cbfunc(index)
            }
        }
    }

    public var intrinsicContentsSize: CGSize { get {
        return mIconView.intrinsicContentSize
    }}
}

/*

 public class KCCollectionViewItem: KCCollectionViewItemBase
 {
     private var mRootView:  KCStackView
     private var mImageView: KCImageView
     private var mLabelView: KCLabelView
     private var mCellSize:  CGSize?

     public init(symbol sym: CNSymbol, size sz: CNSymbolSize, title ttl: String){
         mRootView      = KCStackView()
         mRootView.axis = .vertical

         let image = sym.load(size: sz)

         mImageView = KCImageView()
         mImageView.image = image
         mRootView.addArrangedSubView(subView: mImageView)

         mLabelView = KCLabelView()
         mLabelView.text = ttl
         mRootView.addArrangedSubView(subView: mLabelView)

         mCellSize = nil

         #if os(OSX)
         super.init(nibName: nil, bundle: nil)
         #else
         super.init(frame: CGRect.zero)
         #endif

         #if os(OSX)
             self.view = mRootView
         #else
             self.contentView.addSubview(mRootView)
         #endif
     }

     required init?(coder: NSCoder) {
         fatalError("Do not call this constructor")
     }

     public var intrinsicContentsSize: CGSize { get {
         if let size = mCellSize {
             return size
         } else {
             let newsize = cellSize()
             mCellSize   = newsize
             return newsize
         }
     }}

     public func setFrameSize(_ size: CGSize) {
         mRootView.setFrameSize(size)
         let labheight = mLabelView.frame.height
         let imgheight = max(size.height - labheight, 0.0)
         mImageView.setFrame(size: CGSize(width: size.width, height: imgheight))
         mLabelView.setFrame(size: CGSize(width: size.width, height: labheight))
     }

     private func cellSize() -> CGSize {
         let imgsize: CGSize
         if let img = mImageView.image {
             imgsize = img.size
         } else {
             imgsize = CGSize.zero
         }
         let labsize = mLabelView.intrinsicContentSize
         let space = CNPreference.shared.windowPreference.spacing
         return CNUnionSize(imgsize, labsize, doVertical: true, spacing: space)
     }
 }

 */
