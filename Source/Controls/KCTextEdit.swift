/**
 * @file	KCTextEdit.swift
 * @brief	Define KCTextEdit class
 * @par Copyright
 *   Copyright (C) 2018-2023 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCTextEdit : KCInterfaceView
{
	public typealias EditedCallback = KCTextEditCore.EditedCallback

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
		let frame = CGRect(x: 0.0, y: 0.0, width: 160, height: 60)
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder) ;
		setup() ;
	}

	public var isEditable: Bool {
		get         { return coreView.isEditable }
		set(newval) { coreView.isEditable = newval }
	}

	public func set(editedCallback cbfunc: @escaping EditedCallback) {
		coreView.set(editedCallback: cbfunc)
	}

	public var terminalInfo: CNTerminalInfo { get {
		return coreView.terminalInfo
	}}

	public var controller: CNTerminalController { get {
		return coreView
	}}

	private func setup(){
		KCView.setAutolayoutMode(view: self)
		if let newview = loadChildXib(thisClass: KCTextEdit.self, nibName: "KCTextEditCore") as? KCTextEditCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCTextEditCore")
		}
	}

	open override func updateAppearance() {
		super.updateAppearance()
		coreView.updateAppearance()
	}

	public func updateTerminalInfoByFrameSize(size sz: CGSize) {
		coreView.updateTerminalInfoByFrameSize(size: sz)
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(textEdit: self)
	}

	private var coreView: KCTextEditCore {
		get { return getCoreView() }
	}
}

