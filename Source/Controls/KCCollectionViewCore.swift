/**
 * @file KCCollectionViewCore.swift
 * @brief Define KCCollectionViewCore class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData
import Foundation

open class KCCollectionViewCore: KCCoreView
{
    public typealias CallbackFunction = (_ idnum: Int) -> Void

    #if os(OSX)
    @IBOutlet weak var mCollectionView: NSCollectionView!
    #else
    @IBOutlet weak var mCollectionView: UICollectionView!
    #endif

    #if os(iOS)
    let ItemIdentifier  = "KCCollectionViewItem"
    #endif

    #if os(OSX)
    static let InitialNumberOfColumuns = 4
    #else
    static let InitialNumberOfColumuns = 2
    #endif

        private var mCollectionData     = CNCollectionData()
        private var mNumberOfColumns    = KCCollectionViewCore.InitialNumberOfColumuns
        private var mItems: Array<KCCollectionViewItem>         = []
        private var mButtonPressedCallback: CallbackFunction?   = nil

        private var mSymbolManager              = CNSymbolImages()
        private let mSymbolSize: CNSymbolSize   = .regular

        #if os(OSX)
        private var mLayout = NSCollectionViewFlowLayout()
        #else
        private var mLayout = UICollectionViewFlowLayout()
        #endif

    public func setup(frame frm: CGRect){
        super.setup(isSingleView: true, coreView: mCollectionView)
        KCView.setAutolayoutMode(views: [self, mCollectionView])

        #if os(iOS)
        let bdl = Bundle(for: KCCollectionViewCore.self)
        let nib = UINib(nibName: ItemIdentifier, bundle: bdl)
        mCollectionView.register(nib, forCellWithReuseIdentifier: ItemIdentifier)
        #endif // os(iOS)

        let space = 0.0
        mLayout.scrollDirection         = .vertical
        mLayout.minimumLineSpacing      = space
        mLayout.minimumInteritemSpacing = space
        mLayout.estimatedItemSize       = CGSize.zero // no info
        mLayout.sectionInset            = CNEdgeInsetsMake(space, space, space, space)

        mCollectionView.dataSource = self
        mCollectionView.delegate   = self
        mCollectionView.collectionViewLayout = mLayout
    }

    public func numberOfItems(inSection sec: Int) -> Int {
        return sec == 0 ? mCollectionData.count : 0
    }

    public func set(icons icns: Array<CNIcon>){
            mCollectionData.set(icons: icns)

            /* get max symbol size */
            for icon in icns {
                    let symname = icon.symbol.name
                    let _ = mSymbolManager.load(name: symname, size: mSymbolSize)
            }
            let iconsize = mSymbolManager.maxSize(symbolSize: mSymbolSize)

        /* allocate items and get max cell size */
        mItems = []
        var maxsize         = CGSize.zero
        var index: Int      = 0
        for icon in icns {
            let item = allocateItem(symbol:     icon.symbol,
                                    title:      icon.title,
                                    targetSize: iconsize,
                                    for:        IndexPath(item: index, section: 0))
            item.buttonPressedCallback = {
                (_ index: Int) -> Void in
                if let cbfunc = self.mButtonPressedCallback {
                    cbfunc(index)
                }
            }
            mItems.append(item)
            maxsize = CGSize.maxSize(maxsize, item.intrinsicContentsSize)
            index += 1
        }
        mLayout.itemSize = maxsize
        mCollectionView.reloadData()
        self.invalidateContents()
    }

    private func makeItem(at index: IndexPath) -> KCCollectionViewItem {
        if index.item < mItems.count {
            return mItems[index.item]
        } else {
            CNLog(logLevel: .error, message: "Unexpected index", atFunction: #function, inFile: #file)
            let dummy = allocateItem(symbol:        .character,
                                     title:         "Undefined",
                                     targetSize:    CGSize.zero,
                                     for:           IndexPath(item: 0, section: 0))
            return dummy
        }
    }

    public func set(selectionCallback cbfunc: @escaping CallbackFunction) {
        mButtonPressedCallback = cbfunc
    }

#if os(OSX)
    private func allocateItem(symbol sym: CNSymbol, title ttl: String, targetSize targsize: CGSize, for index: IndexPath) -> KCCollectionViewItem {
        return KCCollectionViewItem(idNumber: index.item, symbol: sym, title: ttl, targetSize: targsize)
    }
#else
    private func allocateItem(symbol sym: CNSymbol, title ttl: String, targetSize targsize: CGSize, for index: IndexPath) -> KCCollectionViewItem {
        if let item = mCollectionView.dequeueReusableCell(withReuseIdentifier: ItemIdentifier, for: index) as? KCCollectionViewItem {
            item.set(idNumber: index.item, symbol: sym, title: ttl, targetSize: targsize)
            return item
        } else {
            CNLog(logLevel: .error, message: "Failed to allocate item", atFunction: #function, inFile: #file)
            return KCCollectionViewItem()
        }
    }
#endif

    #if os(OSX)
    open override var fittingSize: CGSize {
        get { return CGSize.minSize(contentsSize(), self.limitSize) }
    }
    #else
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize.minSize(contentsSize(), self.limitSize)
    }
    #endif

    public override var intrinsicContentSize: CGSize { get {
        return contentSize()
    }}

    private func contentSize() -> CGSize {
        let colnum  = mNumberOfColumns
        let rownum  = rowCount()
        let itemsize = mLayout.itemSize
        let width   = itemsize.width  * CGFloat(colnum)
        let height  = itemsize.height * CGFloat(rownum)
        let space   = CNPreference.shared.windowPreference.spacing
        let hspace  = colnum >= 1 ? space * CGFloat(colnum - 1) : 0.0
        let vspace  = rownum >= 1 ? space * CGFloat(rownum - 1) : 0.0
        let result  = CGSize(width: width + hspace, height: height + vspace)
        return result
    }

    public override func setFrameSize(_ size: CGSize) {
        super.setFrameSize(size)
        mNumberOfColumns = max(Int(floor(size.width / mLayout.itemSize.width)), 1)
    }

    private func rowCount() -> Int {
        return (mItems.count + mNumberOfColumns - 1) / mNumberOfColumns
    }

    private func invalidateContents() {
        mCollectionView.invalidateIntrinsicContentSize()
        #if os(OSX)
        mCollectionView.needsLayout = true
        #else
        mCollectionView.setNeedsLayout()
        #endif
    }
}

#if os(OSX)
extension KCCollectionViewCore: NSCollectionViewDataSource
{
    public func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? mCollectionData.count : 0
    }
}
#else // os(OSX)
extension KCCollectionViewCore: UICollectionViewDataSource
{
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? mCollectionData.count : 0
    }
}
#endif // os(OSX

#if os(OSX)
extension KCCollectionViewCore: NSCollectionViewDelegate
{
    public func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        return makeItem(at: indexPath)
    }
}
#else  // os(OSX)
extension KCCollectionViewCore: UICollectionViewDelegate
{
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return makeItem(at: indexPath)
    }
}
#endif // os(OSX)

