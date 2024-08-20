/**
 * @file	KCTableViewCore.swift
 * @brief	Define KCTableViewCore class
 * @par Copyright
 *   Copyright (C) 2017-2022 Steel Wheels Project
 */

import CoconutData
#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif

#if os(OSX)
	public typealias KCTableViewDelegate    = NSTableViewDelegate
	public typealias KCTableViewDataSource  = NSTableViewDataSource
#else
	public typealias KCTableViewDelegate    = UITableViewDelegate
	public typealias KCTableViewDataSource  = UITableViewDataSource
#endif

open class KCTableViewCore : KCCoreView, KCTableViewDelegate, KCTableViewDataSource, KCTableCellDelegate
{
	public typealias VirtualFieldFunction 		= CNVirtualTable.VirtualFieldFunction
	public typealias ClickCallbackFunction       	= (_ double: Bool, _ record: CNRecord, _ field: String) -> Void
	public typealias IsEnableCallbackFunction	= (_ rowIndex: Int) -> Bool
	public typealias DidSelectedCallbackFunction	= (_ selected: Bool) -> Void
	public typealias FieldType			= CNInterfaceType
	public typealias RecordFilterFunction		= CNVirtualTable.RecordFilterFunction
	public typealias CompareFunction		= CNVirtualTable.CompareRecordFunction

	#if os(OSX)
	@IBOutlet weak var mTableView: NSTableView!
	#else
	@IBOutlet weak var mTableView: UITableView!
	#endif

	public struct FieldName {
		public var field:	String
		public var title:	String

		public init(field fld: String, title ttl: String){
			field	= fld
			title	= ttl
		}
	}

	private class Context {
		private var	mDataTable:		CNVirtualTable
		private var	mColumnTitles:		Dictionary<String, String>	// <column-name, column-title>
		private var	mFilterFunction:	RecordFilterFunction?
		private var	mVirtualFieldMembers: 	Dictionary<String, CNValueType>
		private var 	mVirtualFieldFunction:	VirtualFieldFunction?
		private var	mSortOrder:		CNSortOrder?
		private var	mCompareFunction:	CompareFunction?
		public  var	updated:		Bool

		public init(dataTable table: CNVirtualTable) {
			mDataTable		= table
			mColumnTitles		= [:]
			mVirtualFieldMembers	= [:]
			mFilterFunction		= nil
			mVirtualFieldFunction	= nil
			mSortOrder		= nil
			mCompareFunction	= nil
			updated			= true
		}

		public func clear() {
			mColumnTitles		= [:]
			mFilterFunction		= nil
			mVirtualFieldMembers	= [:]
			mVirtualFieldFunction	= nil
			mSortOrder		= nil
			mCompareFunction	= nil
		}

		public var dataTable: CNVirtualTable {
			get	    { return mDataTable }
			set(newtbl) { mDataTable = newtbl ; updated = true }
		}

		public var columnTitles: Dictionary<String, String> {
			get         { return mColumnTitles }
			set(newttl) { mColumnTitles = newttl ; updated = true }
		}

		public var filterFunction: RecordFilterFunction? {
			get          { return mFilterFunction }
			set(newfunc) { mFilterFunction = newfunc ; updated = true }
		}

		public var virtualFieldMembers: Dictionary<String,CNValueType> {
			get 		{ return mVirtualFieldMembers }
			set(newmemb)	{ mVirtualFieldMembers = newmemb ; updated = true}
		}

		public var virtualFieldFunction: VirtualFieldFunction? {
			get          { return mVirtualFieldFunction }
			set(newfunc) { mVirtualFieldFunction = newfunc ; updated = true }
		}

		public var sortOrder: CNSortOrder? {
			get         { return mSortOrder }
			set(neword) { mSortOrder = neword ; updated = true }
		}

		public var compareFunction: CompareFunction? {
			get	     { return mCompareFunction }
			set(newfunc) { mCompareFunction = newfunc ; updated = true }
		}
	}

	private var mCurrentContext:		Context
	private var mNextContext:		Context
	private var mColumnWidths:		Dictionary<String, CGFloat>	// <colunm-name, width>

	private var mMinimumVisibleRowCount:	Int
	private var mHasHeader:			Bool
	private var mIsEditable:		Bool

	private var mCellClickedCallback:	ClickCallbackFunction?       	= nil
	private var mIsEnableCallback:		IsEnableCallbackFunction?	= nil
	private var mDidSelectedCallback:	DidSelectedCallbackFunction? 	= nil

	#if os(OSX)
	public override init(frame : NSRect){
		let table			 = KCTableViewCore.allocateDummyTable()
		mCurrentContext			= Context(dataTable: table)
		mNextContext			= Context(dataTable: table)
		mColumnWidths			= [:]

		mMinimumVisibleRowCount		= 8
		mHasHeader			= false
		mIsEditable			= false
		super.init(frame: frame)
	}
	#else
	public override init(frame : CGRect){
		let table			= KCTableViewCore.allocateDummyTable()
		mCurrentContext			= Context(dataTable: table)
		mNextContext			= Context(dataTable: table)
		mColumnWidths			= [:]

		mMinimumVisibleRowCount		= 8
		mHasHeader			= false
		mIsEditable			= false
		super.init(frame: frame)
	}
	#endif

	public required init?(coder: NSCoder) {
		let table			= KCTableViewCore.allocateDummyTable()
		mCurrentContext			= Context(dataTable: table)
		mNextContext			= Context(dataTable: table)
		mColumnWidths			= [:]

		mMinimumVisibleRowCount		= 8
		mHasHeader			= false
		mIsEditable			= false
		super.init(coder: coder)
	}

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 270)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 346)
		#endif
		self.init(frame: frame)
	}

	public static func allocateDummyTable() -> CNVirtualTable {

		guard let typeurl = CNFilePath.URLForResourceFile(fileName: "dummy-table.d", fileExtension: "ts", subdirectory: "Data", forClass: KCTableViewCore.self) else {
			fatalError("Failed to allocate URL for dummy_table.d.ts")
		}

		guard let typescr = typeurl.loadContents() as? String else {
			fatalError("Failed to load contents from \(typeurl.path)")
		}

		let rectype: CNInterfaceType
		let tparser = CNValueTypeParser()
		switch tparser.parse(source: typescr) {
		case .success(let vtypes):
			switch vtypes[0] {
			case .interfaceType(let iftype):
				rectype = iftype
			default:
				fatalError("Unexpected value type: \(typeurl.path)")
			}
		case .failure(let err):
			fatalError(err.toString())
		}

		guard let dataurl = CNFilePath.URLForResourceFile(fileName: "dummy-table", fileExtension: "json", subdirectory: "Data", forClass: KCTableViewCore.self) else {
			fatalError("Failed to allocate URL for dummy_table.json")
		}

		guard let datascr = dataurl.loadContents() as? String else {
			fatalError("Failed to load contents from \(dataurl.path)")
		}

		let datavals: Array<CNValue>
		let vparser = CNValueParser()
		switch vparser.parse(source: datascr) {
		case .success(let val):
			switch val {
			case .arrayValue(let arr):
				datavals = arr
			default:
				fatalError("Unexpected value data: \(dataurl.path)")
			}
		case .failure(let err):
			fatalError(err.toString())
		}

		let table = CNValueTable(recordType: rectype)
		if let err = table.load(value: datavals, from: dataurl.path()) {
			CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
		}

		return CNVirtualTable(sourceTable: table)
	}

	public var numberOfRows: Int 	{ get {
		#if os(OSX)
			return mTableView.numberOfRows
		#else
			return 0
		#endif
	}}

	public var numberOfColumns: Int { get {
		#if os(OSX)
			return mTableView.numberOfColumns
		#else
			return 0
		#endif
	}}

	public func setup(frame frm: CGRect) {
		super.setup(isSingleView: true, coreView: mTableView)

		KCView.setAutolayoutMode(views: [self, mTableView])
		mTableView.delegate   = self
		mTableView.dataSource = self

		#if os(OSX)
			mTableView.target			= self
			mTableView.doubleAction 		= #selector(doubleClicked)
			mTableView.columnAutoresizingStyle	= .sequentialColumnAutoresizingStyle
			mTableView.allowsColumnReordering	= false
			mTableView.allowsColumnResizing		= false
			mTableView.allowsColumnSelection	= false
			mTableView.allowsMultipleSelection	= false
			mTableView.allowsEmptySelection		= true
			mTableView.usesAutomaticRowHeights	= true
			mTableView.usesAlternatingRowBackgroundColors	= false
			//mTableView.columnAutoresizingStyle	= .noColumnAutoresizing
		#endif

		reload()
	}

	public var dataTable: CNTable {
		get { return mCurrentContext.dataTable }
		set(newval) { mNextContext.dataTable = CNVirtualTable(sourceTable: newval) }
	}

	public var filterFunction: RecordFilterFunction? {
		get         { return mCurrentContext.filterFunction  }
		set(newval) { mNextContext.filterFunction = newval }
	}

	public var compareFunction: CompareFunction? {
		get         { return mCurrentContext.compareFunction	}
		set(newval) { mNextContext.compareFunction = newval	}
	}

	public var virtualFieldMembers: Dictionary<String, CNValueType> {
		get	    { return mCurrentContext.virtualFieldMembers }
		set(newval) { mNextContext.virtualFieldMembers = newval  }
	}

	public var virtualFieldunction: VirtualFieldFunction? {
		get         { return mCurrentContext.virtualFieldFunction	}
		set(newval) { mNextContext.virtualFieldFunction = newval	}
	}

	public var sortOrder: CNSortOrder {
		get         { return mCurrentContext.sortOrder ?? .none	}
		set(newval) { mNextContext.sortOrder = newval		}
	}

	public var hasHeader: Bool {
		get	    { return mHasHeader}
		set(newval) { mHasHeader = newval }
	}

	public var hasGrid: Bool {
		get {
			#if os(OSX)
				return mTableView.gridStyleMask.contains(.solidHorizontalGridLineMask)
			#else
				return mTableView.separatorStyle != .none
			#endif
		}
		set(doenable){
			#if os(OSX)
				let vpref = CNPreference.shared.viewPreference
				if doenable {

					mTableView.gridStyleMask.insert(.solidHorizontalGridLineMask)
					mTableView.gridStyleMask.insert(.solidVerticalGridLineMask)
					mTableView.gridColor = vpref.graphicsForegroundColor()
				} else {
					mTableView.gridStyleMask.remove(.solidHorizontalGridLineMask)
					mTableView.gridStyleMask.remove(.solidVerticalGridLineMask)
					mTableView.gridColor = vpref.graphicsForegroundColor()
				}
			#else
				if doenable {
					mTableView.separatorStyle = .singleLine
				} else {
					mTableView.separatorStyle = .none
				}
			#endif

		}
	}

	private func fieldName(at idx: Int) -> String? {
		let fnames = mCurrentContext.dataTable.fieldNames()
		if idx < fnames.count {
			return fnames[idx]
		} else {
			return nil
		}
	}

	private func fieldTitle(at idx: Int) -> String {
		let fnames = mCurrentContext.dataTable.fieldNames()
		if idx < fnames.count {
			let fname = fnames[idx]
			if let title = mCurrentContext.columnTitles[fname] {
				return title
			} else {
				return fname
			}
		} else {
			return "?"
		}
	}

	public var isEditable: Bool {
		get         { return mIsEditable   }
		set(newval) { mIsEditable = newval }
	}

	public var minimumVisibleRowCount: Int {
		get      { return mMinimumVisibleRowCount	}
		set(cnt) { mMinimumVisibleRowCount = cnt	}
	}

	public var cellClickedCallback: ClickCallbackFunction? {
		get         { return mCellClickedCallback   }
		set(newval) { mCellClickedCallback = newval }
	}

	public var isEnableCallback: IsEnableCallbackFunction? {
		get	     { return mIsEnableCallback   }
		set(newval)  { mIsEnableCallback = newval }
	}

	public var didSelectedCallback: DidSelectedCallbackFunction? {
		get         { return mDidSelectedCallback   }
		set(newval) { mDidSelectedCallback = newval }
	}

	public func reload() {
		#if os(OSX)
		guard self.isForeground else {
			return // update later
		}

		mTableView.beginUpdates()

		/* Set header */
		if let _ = mTableView.headerView {
			if !mHasHeader {
				/* ON -> OFF */
				mTableView.headerView = nil
			}
		} else {
			if mHasHeader {
				/* OFF -> ON */
				mTableView.headerView = NSTableHeaderView()
			}
		}
		/* Set new fields */
		if mNextContext.updated {
			mNextContext.updated = false // reset flag

			/* Remove all current columns */
			while mTableView.tableColumns.count > 0 {
				if let col = mTableView.tableColumns.last {
					mTableView.removeTableColumn(col)
				}
			}
			/* Add all new columns */
			let table  = mNextContext.dataTable
			let colnum = table.fieldNames().count
			for i in 0..<colnum {
				let fname = fieldName(at: i) ?? "?"
				let newcol        = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: fname))
				newcol.title      = fieldTitle(at: i)
				newcol.isHidden	  = false
				newcol.isEditable = mIsEditable
				newcol.minWidth	  = 32
				newcol.maxWidth	  = 1000
				newcol.sizeToFit()
				/* The width of cell will be updated in the following method
				 * tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
				 */
				/* Add to the table */
				mTableView.addTableColumn(newcol)
			}

			/* Replace to current */
			mCurrentContext = mNextContext
			mNextContext.clear()
		}
		mTableView.endUpdates()


		/* Set filter */
		if let filter = mCurrentContext.filterFunction {
			mCurrentContext.dataTable.setRecordFilterFunction(function: filter)
			mCurrentContext.filterFunction = filter
			mNextContext.filterFunction    = nil
		}
		/* Set sort order */
		if let order = mCurrentContext.sortOrder {
			mCurrentContext.dataTable.setSortOrder(order: order)
			mCurrentContext.sortOrder = order
			mNextContext.sortOrder	  = nil
		}
		/* Set compare function */
		if let comp = mNextContext.compareFunction {
			mCurrentContext.dataTable.setCompareRecordFunction(function: comp)
			mCurrentContext.compareFunction = comp
			mNextContext.compareFunction    = nil
		}

		/* Clear column width info */
		mColumnWidths.removeAll()

		mTableView.noteNumberOfRowsChanged()
		mTableView.reloadData()

		#endif // os(OSX)
	}

	@IBAction func mCellAction(_ sender: Any) {
		click(isDouble: false)
	}

	@objc func doubleClicked(sender: AnyObject) {
		click(isDouble: true)
	}

	private func click(isDouble double: Bool) {
		#if os(OSX)
			let rowidx = mTableView.clickedRow
			let colidx = mTableView.clickedColumn

			/* Callback: clicked */
			if 0<=rowidx && rowidx < self.dataTable.recordCount, let colname = fieldName(at: colidx) {
				if let rec = self.dataTable.record(at: rowidx), let cbfunc = self.mCellClickedCallback {
					cbfunc(double, rec, colname)
				} else {
					CNLog(logLevel: .detail, message: "Clicked col:\(colname) row:\(rowidx)", atFunction: #function, inFile: #file)
				}
			}
			/* Callback: didSelected */
			if let cbfunc = mDidSelectedCallback {
				cbfunc(true) // callback
			}
		#endif
	}

	public func selectedRecord() -> CNRecord? {
		#if os(OSX)
			let indices = mTableView.selectedRowIndexes
			for idx in indices {
				if let rec = self.dataTable.record(at: idx) {
					return rec
				} else {
					CNLog(logLevel: .error, message: "No record at index:\(idx)", atFunction: #function, inFile: #file)
				}
			}
		#endif
		return nil
	}

	public func removeSelectedRecord() {
		#if os(OSX)
		let sets = mTableView.selectedRowIndexes
		if !sets.isEmpty {
			/* Remove data from table */
			sets.forEach({
				(_ idx: Int) -> Void in
				if !self.dataTable.remove(at: idx) {
					CNLog(logLevel: .error, message: "Failed to remove row data: \(idx)", atFunction: #function, inFile: #file)
				}
			})

			/* Remove from table view */
			mTableView.beginUpdates()
			mTableView.removeRows(at: sets, withAnimation: .slideUp)
			mTableView.endUpdates()

			/* Callback: didSelected */
			if let cbfunc = didSelectedCallback {
				cbfunc(false) // callback
			}
		}
		#endif
	}

	public func tableCellView(shouldEndEditing view: KCTableCellView, columnTitle title: String, rowIndex ridx: Int, value val: CNValue) {
		if let rec = self.dataTable.record(at: ridx) {
			if rec.setValue(value: val, forField: title) {
				return
			}
		}
		CNLog(logLevel: .error, message: "Failed to set value", atFunction: #function, inFile: #file)
	}

	/*
	 * dataSource
	 */
	#if os(OSX)
	public func numberOfRows(in tableView: NSTableView) -> Int {
		return self.dataTable.recordCount
	}

	public func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		var result: CNValue = CNValue.null
		if let col = tableColumn {
			if let rec = self.dataTable.record(at: row) {
				if let val = rec.value(ofField: col.identifier.rawValue){
					result = val
				}
			}
		}
		return result
	}

	public func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
		if let col = tableColumn, let val = object as? CNValue {
			if let rec = self.dataTable.record(at: row) {
				if rec.setValue(value: val, forField: col.identifier.rawValue) {
					return
				}
			}
		}
		CNLog(logLevel: .error, message: "Failed to set object value", atFunction: #function, inFile: #file)
	}
	#else
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}

	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return KCTableCellView(style: .default, reuseIdentifier: "default")
	}
	#endif

	/*
	 * Delegate
	 */
	#if os(OSX)
	public func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let newview = mTableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "tableCellView"), owner: mTableView)
		if let cell = newview as? KCTableCellView {
			let title:    String
			if let col = tableColumn {
				title = col.title
			} else {
				title = ""
			}

			cell.setup(title: title, row: row, delegate: self)
			if let cbfunc = mIsEnableCallback {
				cell.isEnabled  = cbfunc(row)
			} else {
				cell.isEnabled  = true // default
			}
			cell.isEditable = mIsEditable

			/* Adjust size */
			if let col = tableColumn, let font = cell.textField?.font {
				let width = columnWidths(columnName: col.identifier.rawValue, font: font)
				if width > col.width {
					col.width = width
				}
			} else {
				CNLog(logLevel: .error, message: "Failed to adjust width", atFunction: #function, inFile: #file)
			}
		} else {
			CNLog(logLevel: .error, message: "Unexpected cell view", atFunction: #function, inFile: #file)
		}
		return newview
	}

	public func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let result: Bool
		if let cbfunc = mIsEnableCallback {
			result = cbfunc(row)
		} else {
			result = true
		}
		return result
	}

	private func columnWidths(columnName cname: String, font fnt: CNFont) -> CGFloat {
		let table = mCurrentContext.dataTable
		if let width = mColumnWidths[cname] {
			return width
		}
		var width: CGFloat = 0.0
		for ridx in 0..<table.recordCount {
			if let rec = table.record(at: ridx) {
				if let val = rec.value(ofField: cname) {
					let cellsize = stringToSize(string: val.description, withFont: fnt)
					width = max(width, cellsize.width)
				} else {
					CNLog(logLevel: .error, message: "No valid field: \(ridx):\(cname)", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "No valid record", atFunction: #function, inFile: #file)
			}
		}
		mColumnWidths[cname] = width
		return width
	}

	private func stringToSize(string str: String, withFont fnt: CNFont) -> CGSize {
		let attr = [NSAttributedString.Key.font: fnt]
		let strsize: CGSize = (str as NSString).size(withAttributes: attr)
		let space  = mTableView.intercellSpacing
		let result = CGSize(width: strsize.width * 1.2 + space.width * 2.0, height: strsize.height * 1.2 + space.height * 2.0)
		return result
	}

	#endif

	/*
	 * Layout
	 */
	public func view(atColumn cidx: Int, row ridx: Int) -> KCViewBase? {
		#if os(OSX)
		if let view = mTableView.view(atColumn: cidx, row: ridx, makeIfNecessary: false) {
			return view
		} else {
			return nil
		}
		#else
		return nil
		#endif
	}

	public override var intrinsicContentSize: CGSize {
		#if os(OSX)
		let size: CGSize = calcContentSize()
		#else
		let size = super.intrinsicContentSize
		#endif
		return size
	}

	#if os(OSX)
	private func calcContentSize() -> CGSize {
		var result = CGSize.zero
		let space  = mTableView.intercellSpacing
		if let header = mTableView.headerView {
			result        =  header.frame.size
			result.height += space.height
		}
		let actnum = min(mTableView.numberOfRows, mMinimumVisibleRowCount)
		if actnum > 0 {
			var frame: CGRect = CGRect.zero
			/* Calc for non-empty rows */
			for ridx in 0..<actnum {
				if let rview = mTableView.rowView(atRow: ridx, makeIfNecessary: true) {
					frame = rview.frame
					result.width  =  max(result.width, frame.size.width)
					result.height += frame.size.height
				}
			}
			/* Calc for non-empty rows */
			for _ in actnum..<mMinimumVisibleRowCount {
				result.width  =  max(result.width, frame.size.width)
				result.height += frame.size.height
			}
			/* Calc for space */
			if mMinimumVisibleRowCount > 1 {
				result.height += space.height * CGFloat(mMinimumVisibleRowCount - 1)
			}
			return CGSize.minSize(result, self.limitSize)
		} else {
			/* Calc dummy size. The unit size is given from XIB setting */
			let unitsize = CGSize(width: 124, height: 17)
			let fnum     = mCurrentContext.dataTable.fieldNames().count
			var result   = CGSize(width: unitsize.width * CGFloat(fnum), height: unitsize.height * CGFloat(mMinimumVisibleRowCount))
			/* Calc for space */
			if mMinimumVisibleRowCount > 1 {
				result.height += space.height * CGFloat(mMinimumVisibleRowCount - 1)
			}
			return CGSize.minSize(result, self.limitSize)
		}
	}
	#endif

	public var firstResponderView: KCViewBase? { get {
		#if os(OSX)
		let row = mTableView.clickedRow
		let col = mTableView.clickedColumn
		if 0<=row && row<mTableView.numberOfRows && 0<=col && col<mTableView.numberOfColumns {
			if let cell = mTableView.view(atColumn: col, row: row, makeIfNecessary: false) as? KCTableCellView {
				return cell.firstResponderView
			}
		}
		#endif
		return nil
	}}
}
