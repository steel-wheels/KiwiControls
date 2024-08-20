/**
 * @file KCPopuoMenuCore.swift
 * @brief Define KCPopupMenuCore class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData
import Foundation

open class KCPopupMenuCore: KCCoreView
{
	public typealias SelectionNotification = (_ val: Int) -> Void

#if os(OSX)
	@IBOutlet weak var mPopupButton: 	NSPopUpButton!
	private var mSelectionNotification:	SelectionNotification? = nil
	private var mItems:			Array<CNMenuItem> = []
#else
	@IBOutlet weak var mPickerView: UIPickerView!
	private var mDelegate:	KCPopupMenuCoreDelegate = KCPopupMenuCoreDelegate()
#endif

	public func setup(frame frm: CGRect) -> Void {
		#if os(OSX)
			super.setup(isSingleView: true, coreView: mPopupButton)
			KCView.setAutolayoutMode(views: [self, mPopupButton])
		#else
			super.setup(isSingleView: true, coreView: mPickerView)
			KCView.setAutolayoutMode(views: [self, mPickerView])
		#endif
		#if os(OSX)
			mPopupButton.removeAllItems()
		#else
			let delegate = KCPopupMenuCoreDelegate()
			mPickerView.delegate   = delegate
			mPickerView.dataSource = delegate
			mDelegate = delegate
		#endif
	}

	#if os(OSX)
	@IBAction func buttonAction(_ sender: Any) {
		if let cbfunc = selectionNotification {
			let idx = self.indexOfSelectedItem
			if 0<=idx && idx<mItems.count {
				cbfunc(mItems[idx].value)
			}
		} else {
			CNLog(logLevel: .detail, message: "Popup menu pressed")
		}
	}
	#endif

	public var selectionNotification: SelectionNotification? {
		get {
			#if os(OSX)
			return mSelectionNotification
			#else
			return mDelegate.selectionNotification
			#endif
		}
		set(newfunc){
			#if os(OSX)
			mSelectionNotification = newfunc
			#else
			mDelegate.selectionNotification = newfunc
			#endif
		}
	}

	public func currentItem() -> Int? {
		#if os(OSX)
			let idx = indexOfSelectedItem
			if 0<=idx && idx<mItems.count {
				return mItems[idx].value
			} else {
				return nil
			}
		#else
			return mDelegate.selectedItem()
		#endif
	}

	private var indexOfSelectedItem: Int { get {
		#if os(OSX)
			return mPopupButton.indexOfSelectedItem
		#else
			return mDelegate.indexOfSelectedItem
		#endif
	}}

	public func menuItems() -> Array<CNMenuItem> {
		#if os(OSX)
			return mItems
		#else
			return mDelegate.allItems()
		#endif
	}

        public func menuItem(at idx: Int) -> CNMenuItem? {
                let items = menuItems()
                if idx < items.count {
                        return items[idx]
                } else {
                        return nil
                }
        }

	public func set(menuItems src: Array<CNMenuItem>) {
		removeAllItems()
		addItems(src)
		selectItem(0)
	}

	public func select(byValue val: Int) -> Bool {
		var result = false
		let items = menuItems()
		for i in 0..<items.count {
			if items[i].value == val {
				selectItem(i)
				result = true
			}
		}
		return result
	}

	private func addItem(_ item: CNMenuItem) {
		#if os(OSX)
			mPopupButton.addItem(withTitle: item.title)
			mItems.append(item)
		#else
			mDelegate.addItem(item)
		#endif
	}

	private func addItems(_ items: Array<CNMenuItem>) {
		#if os(OSX)
			mPopupButton.addItems(withTitles: items.map { $0.title })
			mItems.append(contentsOf: items)
		#else
			mDelegate.addItems(items)
		#endif
	}

	private func selectItem(_ index: Int) {
		let items = self.menuItems()
		guard 0<=index && index<items.count else {
			return
		}
		/* Update component setting */
		#if os(OSX)
			mPopupButton.selectItem(at: index)
		#else
			mDelegate.selectItem(at: index)
		#endif
		if let cbfunc = selectionNotification {
			cbfunc(items[index].value)
		}
	}

	private func removeAllItems() {
		#if os(OSX)
			mPopupButton.removeAllItems()
			mItems = []
		#else
			mDelegate.removeAllItems()
		#endif
	}

	#if os(OSX)
	open override var fittingSize: CGSize {
		get { return contentSize() }
	}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return contentSize()
	}
	#endif

	open override var intrinsicContentSize: CGSize {
		get { return contentSize() }
	}

	private func contentSize() -> CGSize {
		#if os(OSX)
			var btnsize = mPopupButton.intrinsicContentSize
			if let font = mPopupButton.font {
				btnsize.width  = max(btnsize.width,  font.pointSize * CGFloat(15))
				btnsize.height = max(btnsize.height, font.pointSize * 1.2        )
			}
		#else
			let btnsize = mPickerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
		#endif
		let space = CNPreference.shared.windowPreference.spacing
		return CGSize(width:  btnsize.width + space, height: btnsize.height + space)
	}
}

#if os(iOS)
@objc private class KCPopupMenuCoreDelegate:NSObject, UIPickerViewDelegate, UIPickerViewDataSource
{
	public var selectionNotification: KCPopupMenuCore.SelectionNotification? = nil

	private var mItems:	Array<CNMenuItem> = []
	private var mIndex:	Int = -1

	public var indexOfSelectedItem: Int {
		get { return mIndex }
	}

	public func allItems() -> Array<CNMenuItem> {
		return mItems
	}

	public func addItem(_ item: CNMenuItem) {
		mItems.append(item)
	}

	public func addItems(_ items: Array<CNMenuItem>) {
		mItems.append(contentsOf: items)
	}

	public func selectItem(at index: Int) {
		guard 0 <= index && index < mItems.count else {
			CNLog(logLevel: .error, message: "Invalid index to select menu item: \(index)", atFunction: #function, inFile: #file)
			return
		}
		mIndex = index
	}

	public func removeAllItems() {
		mItems = []
	}

	public func selectedItem() -> Int? {
		let idx = indexOfSelectedItem
		if 0<=idx && idx<mItems.count {
			return mItems[idx].value
		} else {
			return nil
		}
	}

	public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		mIndex = row
		if mIndex < mItems.count {
			if let cbfunc = selectionNotification {
				cbfunc(mItems[mIndex].value)
			}
		}
	}

	public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if component == 0 {
			if 0 <= row && row < mItems.count {
				return mItems[row].title
			}
		}
		return nil
	}

	/* as data source */
	public func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}

	/* as data source */
	public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return mItems.count
	}
}
#endif

