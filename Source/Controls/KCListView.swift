/**
 * @file	KCListView.swift
 * @brief	Define KCListView class
 * @par Copyright
 *   Copyright (C) 2023  Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCListView: KCInterfaceView
{
	public typealias SelectionNotification = KCListViewCore.SelectionNotification
	public typealias UpdatedNotification   = KCListViewCore.UpdatedNotification

	#if os(OSX)
	public override init(frame : NSRect){
		super.init(frame: frame) ;
		setup() ;
	}
	#else
	public override init(frame: CGRect){
		super.init(frame: frame) ;
		setup()
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 156, height: 16)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 200, height: 32)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder) ;
		setup() ;
	}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCListView.self, nibName: "KCListViewCore") as? KCListViewCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCListViewCore")
		}
	}

	public var items: Array<String> { get {
		return coreView.items
	}}

	public func set(items itms: Array<String>) {
		coreView.set(items: itms)
	}

	public var selectionNotification: SelectionNotification? {
		get { return coreView.selectionNotification             }
		set(newfunc) { coreView.selectionNotification = newfunc }
	}

	public var updatedNotification: UpdatedNotification? {
		get          { return coreView.updatedNotification    }
		set(newfunc) { coreView.updatedNotification = newfunc }
	}

	public func selectedItem() -> String? {
		return coreView.selectedItem()
	}

	public var isEditable: Bool {
		get         { return coreView.isEditable   }
		set(newval) { coreView.isEditable = newval }
	}

	public var visibleRowCount: Int {
		get         { return coreView.visibleRowCount }
		set(newval) { coreView.visibleRowCount = newval }
	}

	public var subCellViews: Array<KCTableCellView> { get {
		return coreView.subCellViews
	}}

	open override func updateAppearance() {
		coreView.updateAppearance()
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(list: self)
	}

	private var coreView: KCListViewCore {
		get { return getCoreView() }
	}
}
