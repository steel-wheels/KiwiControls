/**
 * @file	KCTableView.swift
 * @brief	Define KCTableView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCTableView : KCInterfaceView
{
	public typealias VirtualFieldFunction		= KCTableViewCore.VirtualFieldFunction
	public typealias RecordFilterFunction		= CNVirtualTable.RecordFilterFunction
	public typealias CompareFunction		= (_ rec0: CNRecord, _ rec1: CNRecord) -> ComparisonResult

	private var mVirtualFields: 		Dictionary<String, CNValueType>

	#if os(OSX)
	public override init(frame : NSRect){
		mVirtualFields	= [:]
		super.init(frame: frame) ;
		setup() ;
	}
	#else
	public override init(frame: CGRect){
		mVirtualFields	= [:]
		super.init(frame: frame) ;
		setup()
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 272)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 375)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mVirtualFields	= [:]
		super.init(coder: coder) ;
		setup() ;
	}

	public var numberOfRows:	Int { get { return coreView.numberOfRows	}}
	public var numberOfColumns:	Int { get { return coreView.numberOfColumns	}}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCTableView.self, nibName: "KCTableViewCore") as? KCTableViewCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCTableViewCore")
		}
	}

	public var dataTable: CNTable {
		get         { return coreView.dataTable   }
		set(newval) { coreView.dataTable = newval }
	}

	public var filterFunction: RecordFilterFunction? {
		get         { return coreView.filterFunction  }
		set(newval) { coreView.filterFunction = newval }
	}

	public var compareFunction: CompareFunction? {
		get         { return coreView.compareFunction	}
		set(newval) { coreView.compareFunction = newval	}
	}

	public var virtualFieldMembers: Dictionary<String, CNValueType> {
		get         { return coreView.virtualFieldMembers	}
		set(newval) { coreView.virtualFieldMembers = newval	}
	}

	public var virtualFieldFunction: KCTableViewCore.VirtualFieldFunction? {
		get         { return coreView.virtualFieldunction	}
		set(newval) { coreView.virtualFieldunction = newval	}
	}

	public var sortOrder: CNSortOrder {
		get         { return coreView.sortOrder		}
		set(newval) { coreView.sortOrder = newval	}
	}

	public var hasHeader: Bool {
		get         { return coreView.hasHeader }
		set(newval) { coreView.hasHeader = newval }
	}

	public var hasGrid: Bool {
		get         { return coreView.hasGrid }
		set(newval) { coreView.hasGrid = newval }
	}

	public var isEditable: Bool {
		get         { return coreView.isEditable }
		set(newval) { coreView.isEditable = newval }
	}

	public var minimumVisibleRowCount: Int {
		get         { return coreView.minimumVisibleRowCount }
		set(newval) { coreView.minimumVisibleRowCount = newval }
	}

	public func reload() {
		coreView.reload()
	}

	public func selectedRecord() -> CNRecord? {
		return coreView.selectedRecord()
	}

	public func removeSelectedRecord() {
		coreView.removeSelectedRecord()
	}

	public var firstResponderView: KCViewBase? { get {
		return coreView.firstResponderView
	}}

	public func view(atColumn col: Int, row rw: Int) -> KCViewBase? {
		return coreView.view(atColumn: col, row: rw)
	}

	public var cellClickedCallback: KCTableViewCore.ClickCallbackFunction? {
		get         { return coreView.cellClickedCallback   }
		set(cbfunc) { coreView.cellClickedCallback = cbfunc }
	}

	public var isEnableCallback: KCTableViewCore.IsEnableCallbackFunction? {
		get	     { return coreView.isEnableCallback   }
		set(newval)  { coreView.isEnableCallback = newval }
	}

	public var didSelectedCallback: ((_ selected: Bool) -> Void)? {
		get         { return coreView.didSelectedCallback   }
		set(cbfunc) { coreView.didSelectedCallback = cbfunc }
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(table: self)
	}

	private var coreView: KCTableViewCore {
		get { return getCoreView() }
	}
}


