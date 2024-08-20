/**
 * @file KCPopupMenu.swift
 * @brief Define KCPopupMenu class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCPopupMenu : KCInterfaceView
{
	public typealias SelectionNotification = KCPopupMenuCore.SelectionNotification

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
		let frame = NSRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#else
		let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder) ;
		setup() ;
	}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCPopupMenuCore.self, nibName: "KCPopupMenuCore") as? KCPopupMenuCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCPopupMenuCore")
		}
	}

	public var selectionNotification: SelectionNotification? {
		get { return coreView.selectionNotification }
		set(newfunc) { coreView.selectionNotification = newfunc }
	}

	public func currentItem() -> Int? {
		return coreView.currentItem()
	}

	public func menuItems() -> Array<CNMenuItem> {
		return coreView.menuItems()
	}

        public func menuItem(at idx: Int) -> CNMenuItem? {
                return coreView.menuItem(at: idx)
        }

	public func set(menuItems src: Array<CNMenuItem>) {
		coreView.set(menuItems: src)
	}

	public func select(byValue val: Int) -> Bool {
		return coreView.select(byValue: val)
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(popupMenu: self)
	}

	private var coreView: KCPopupMenuCore {
		get { return getCoreView() }
	}
}

