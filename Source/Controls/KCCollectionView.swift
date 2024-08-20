/**
 * @file	KCCollectionView.swift
 * @brief	Define KCCollectionView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif
import CoconutData

open class KCCollectionView: KCInterfaceView
{
	public typealias CallbackFunction = KCCollectionViewCore.CallbackFunction

	#if os(OSX)
	public override init(frame : NSRect){
		super.init(frame: frame)
		setup(frame: frame)
	}
	#else
	public override init(frame: CGRect){
		super.init(frame: frame)
		setup(frame: frame)
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 188, height: 21)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 32)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup(frame: self.frame)
	}

	private func setup(frame frm: CGRect){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCCollectionView.self, nibName: "KCCollectionViewCore") as? KCCollectionViewCore {
			setCoreView(view: newview)
			newview.setup(frame: frm)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCCollectionViewCore")
		}
	}

	public func numberOfItems(inSection sec: Int) -> Int {
		return coreView.numberOfItems(inSection: sec)
	}

    public func set(icons itms: Array<CNIcon>){
        coreView.set(icons: itms)
    }

    public func set(selectionCallback cbfunc: @escaping CallbackFunction) {
        coreView.set(selectionCallback: cbfunc)
    }

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(collection: self)
	}

	private var coreView: KCCollectionViewCore {
		get { return getCoreView() }
	}
}

