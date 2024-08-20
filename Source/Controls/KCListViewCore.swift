/**
 * @file	KCListViewCore.swift
 * @brief	Define KCListViewCore class
 * @par Copyright
 *   Copyright (C) 2023  Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCListViewCore : KCCoreView, KCTableViewDataSource, KCTableViewDelegate, KCTableCellDelegate
{
	public typealias SelectionNotification = (_ val: String) -> Void
	public typealias UpdatedNotification   = () -> Void

	private var mCurrentItems: Array<String>			= []
	private var mNextItems: Array<String>				= []
	private var mHasHeader						= false
	private var mIsEditable						= false
	private var mSelectionNotification: SelectionNotification?	= nil
	private var mUpdatedNotification: UpdatedNotification?		= nil
	private var mSelectedItem: String?				= nil
	private var mVisibleRowCount: Int				= 16
	private var mFont: CNFont	= CNFont.systemFont(ofSize: CNFont.systemFontSize)

	#if os(OSX)
	@IBOutlet weak var mTableView: NSTableView!
	#else
	@IBOutlet weak var mTableView: UITableView!
	#endif

	static let DefaultColumnName	= "default"

	public func setup(frame frm: CGRect){
		super.setup(isSingleView: true, coreView: mTableView)
		KCView.setAutolayoutMode(views: [self, mTableView])
		mTableView.dataSource = self
		mTableView.delegate   = self

		#if os(OSX)
		mTableView.allowsEmptySelection		= true
		#else  // os(OSX)
		#endif // os(OSX)
		mTableView.allowsMultipleSelection	= false

		/* actions */
		#if os(OSX)
		mTableView.target = self
		#endif // os(OSX)
	}

	public var items: Array<String> { get {
		return mNextItems
	}}

	public func set(items itms: Array<String>) {
		mNextItems = itms
		reload()
	}

	public var selectionNotification: SelectionNotification? {
		get        { return mSelectionNotification  }
		set(notif) { mSelectionNotification = notif }
	}

	public var updatedNotification: UpdatedNotification? {
		get        { return mUpdatedNotification }
		set(notif) { mUpdatedNotification = notif }
	}

	public var isEditable: Bool {
		get 	    { return mIsEditable }
		set(newval) {
			mIsEditable = newval
			if !newval { resetEditable() }
		}
	}

	public var visibleRowCount: Int {
		get         { return mVisibleRowCount }
		set(newval) { mVisibleRowCount = newval }
	}

	public func selectedItem() -> String? {
		return mSelectedItem
	}

	private func index(ofValue val: String) -> Int? {
		for i in 0..<mCurrentItems.count {
			if mCurrentItems[i] == val {
				return i ;
			}
		}
		return nil
	}

	public var subCellViews: Array<KCTableCellView> { get {
		var result: Array<KCTableCellView>  = []
		for i in 0..<mCurrentItems.count {
			if let cell = tableViewCell(at: i) {
				result.append(cell)
			}
		}
		return result
	}}

	public func reload() {
		mTableView.beginUpdates()

		/* Set header */
		#if os(OSX)
		if let _ = mTableView.headerView {
			if !mHasHeader {
				/* ON -> OFF */
				mTableView.headerView = nil
			}
		} else {
			if mHasHeader {
				/* OFF -> ON */
				let header = NSTableHeaderView()
				header.tableView = mTableView
				mTableView.headerView = header
			}
		}
		#endif

		mTableView.endUpdates()

		/* Require layout */
		mTableView.invalidateIntrinsicContentSize()
		#if os(OSX)
		mTableView.noteNumberOfRowsChanged()
		#endif

		/* The replacement of source data must be replaced after endUpdates() */
		mCurrentItems = mNextItems
		mTableView.reloadData()
	}

	public func updateAppearance() {
        mTableView.backgroundColor = CNColor.clear
	}

	public override var intrinsicContentSize: CGSize { get {
		let res = self.calcContentSize()
		return res
	}}

	private func calcContentSize() -> CGSize {
		var result: CGSize = .zero
		let spacing = self.intercellSpacing
		#if os(OSX)
		if let header = mTableView.headerView {
			result        =  header.frame.size
			result.height += spacing.height
		}
		#else
		if let header = mTableView.headerView(forSection: 0){
			result        =  header.frame.size
			result.height += spacing.height
		}
		#endif
		let itemnum = min(mCurrentItems.count, mVisibleRowCount)
		for ridx in 0..<itemnum {
			#if os(OSX)
			if let rview = mTableView.rowView(atRow: ridx, makeIfNecessary: true) {
				frame = rview.frame
				result.width  =  max(result.width, frame.size.width)
				result.height += frame.size.height
			}
			#else
			if let rview = mTableView.cellForRow(at: IndexPath(item: ridx, section: 0)) {
				frame = rview.frame
				result.width  =  max(result.width, frame.size.width)
				result.height += frame.size.height
			}
			#endif
		}
		if itemnum > 1 {
			// spaces between cells
			result.height += spacing.height * CGFloat(itemnum - 1)
		}
		let frmspc = CNPreference.shared.windowPreference.spacing
		result.height += frmspc * 2
		result.width  += frmspc * 2

		return result
	}

	private var intercellSpacing: CGSize { get {
		#if os(OSX)
			return mTableView.intercellSpacing
		#else
			return CGSize.zero
		#endif
	}}

	public func tableViewCell(at row: Int) -> KCTableCellView? {
		if 0 <= row && row < mCurrentItems.count {
			#if os(OSX)
			if let rowview = mTableView.rowView(atRow: row, makeIfNecessary: true) {
				return rowview.view(atColumn: 0) as? KCTableCellView
			}
			#else
			let path = IndexPath(row: row, section: 0)
			if let rowview = mTableView.cellForRow(at: path) {
				return rowview as? KCTableCellView
			}
			#endif
		}
		return nil
	}

	private func resetEditable() {
		for i in 0..<mCurrentItems.count {
			#if os(OSX)
			if let rowview = mTableView.rowView(atRow: i, makeIfNecessary: false) {
				if let cell = rowview.view(atColumn: 0) as? KCTableCellView {
					cell.isEditable = false
				}
			}
			#else
			let path = IndexPath(row: i, section: 0)
			if let rowview = mTableView.cellForRow(at: path) {
				if let cell = rowview as? KCTableCellView {
					cell.isEditable = false
				}
			}
			#endif
		}
	}

	/*
	 * NSTableViewDataSource
	 */
	#if os(OSX)
	public func numberOfRows(in tableView: NSTableView) -> Int {
		return mCurrentItems.count
	}

	public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		if 0 <= row && row < mCurrentItems.count {
			return mCurrentItems[row]
		} else {
			return nil
		}
	}
	#else
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return mCurrentItems.count
	}
	#endif

	/*
	 * NSTableViewDelegate
	 */
	#if os(OSX)
	public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		guard 0 <= row && row < mCurrentItems.count else {
			return nil
		}

		let ident = NSUserInterfaceItemIdentifier("default")
		if let newview = mTableView.makeView(withIdentifier: ident, owner: self) as? KCTableCellView {
			let title = mCurrentItems[row]
			newview.setup(title: KCListViewCore.DefaultColumnName, row: row, delegate: self)
			newview.value = .stringValue(title)
			if let field = newview.textField {
				field.font = mFont
			}
			return newview
		} else {
			CNLog(logLevel: .error, message: "Failed to make view", atFunction: #function, inFile: #file)
			return nil
		}
	}

	public func tableViewSelectionDidChange(_ notification: Notification) {
		selected(row: mTableView.selectedRow)
	}

	public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
		NSLog("update object at \(row)")
	}

	#else // if os(OSX)

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let text: String
		let row = indexPath.row
		if 0 <= row && row < mCurrentItems.count {
			text = mCurrentItems[row]
		} else {
			text = ""
		}
		let newcell = KCTableCellView(style: .default, reuseIdentifier: "default")
		newcell.setup(title: KCListViewCore.DefaultColumnName, row: row, delegate: self)
		newcell.value = .stringValue(text)
		return newcell
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if mIsEditable {
			if let cell = tableViewCell(at: indexPath.row) {
				cell.isEditable = true
			}
		} else {
			selected(row: indexPath.row)
		}
	}

	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		if let cell = tableViewCell(at: indexPath.row) {
			cell.isEditable = false
		}
	}
	#endif

	/* KCTableCellViewDelegate */
	public func tableCellView(shouldEndEditing view: KCTableCellView, columnTitle title: String, rowIndex ridx: Int, value val: CNValue) {
		edited(row: ridx, value: val)
	}

	#if os(OSX)
	/* reference: https://stackoverflow.com/questions/59514414/nstableview-directly-editing-a-textfield-without-highlighting-the-whole-row
	 */
	// if we find an editable text field at this point, we return it instead of the cell
	// this will prevent any cell reaction
	public override func hitTest(_ point: NSPoint) -> NSView? {
		guard mIsEditable else {
			return super.hitTest(point)
		}

		let lpoint = mTableView.superview!.convert(point, to: self)
		let column = mTableView.column(at: lpoint)
		guard column == 0 else {
			return super.hitTest(point)
		}

		let row = mTableView.row(at: lpoint)
		guard let cell = tableViewCell(at: row) else {
			return super.hitTest(point)
		}
		if let textField = cell.hitTest(convert(lpoint, to: cell.superview)) as? NSTextField {
			textField.isEditable = true
			return textField
		} else {
			return super.hitTest(point)
		}
	}
	#endif

	private func selected(row rval: Int) {
		if 0 <= rval && rval < mCurrentItems.count {
			let item = mCurrentItems[rval]
			mSelectedItem = item
			if let selfunc = mSelectionNotification {
				selfunc(item)
			}
		}
	}

	private func edited(row rval: Int, value val: CNValue) {
		if 0 <= rval && rval < mNextItems.count {
			if let str = val.toString() {
				if mNextItems[rval] != str {
					mNextItems[rval] = str
					callUpdateNotification()
				}
			} else {
				CNLog(logLevel: .error, message: "Failed to set edited value", atFunction: #function, inFile: #file)
			}
		}
	}

	private func insert(row rval: Int) {
		if 0 <= rval && rval < mNextItems.count {
			mNextItems.insert("", at: rval)
			callUpdateNotification()
			self.reload()
		}
	}

	private func delete(row rval: Int) {
		if 0 <= rval && rval < mNextItems.count {
			mNextItems.remove(at: rval)
			callUpdateNotification()
			self.reload()
		}
	}

	private func callUpdateNotification() {
		if let notif = mUpdatedNotification {
			notif() // Call updated notification
		} else {
			CNLog(logLevel: .debug, message: "Send updated notification")
		}
	}
}

