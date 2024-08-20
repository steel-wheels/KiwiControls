/**
 * @file KCNavigationBar.swift
 * @brief Define KCNavigationBar class
 * @par Copyright
 *   Copyright (C) 2019 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCNavigationBar : KCInterfaceView
{
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
		if let newview = loadChildXib(thisClass: KCNavigationBar.self, nibName: "KCNavigationBarCore") as? KCNavigationBarCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCNavigationBarCore")
		}
	}

	public var title: String {
		get { return coreView.title }
		set(str) { coreView.title = str }
	}

	public var isLeftButtonEnabled: Bool {
		get { return coreView.isLeftButtonEnabled }
		set(enable) { coreView.isLeftButtonEnabled = enable }
	}

	public var leftButtonTitle: String {
		get { return coreView.leftButtonTitle }
		set(str) { coreView.leftButtonTitle = str }
	}

	public var leftButtonPressedCallback: (() -> Void)? {
		get { return coreView.leftButtonPressedCallback }
		set(cbfunc) { coreView.leftButtonPressedCallback = cbfunc }
	}

	public var isRightButtonEnabled: Bool {
		get { return coreView.isRightButtonEnabled }
		set(enable) { coreView.isRightButtonEnabled = enable }
	}

	public var rightButtonTitle: String {
		get { return coreView.rightButtonTitle }
		set(str) { coreView.rightButtonTitle = str }
	}

	public var rightButtonPressedCallback: (() -> Void)? {
		get { return coreView.rightButtonPressedCallback }
		set(cbfunc) { coreView.rightButtonPressedCallback = cbfunc }
	}

    open override func updateAppearance() {
        super.updateAppearance()
        coreView.updateAppearance()
    }

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(navigationBar: self)
	}

	private var coreView: KCNavigationBarCore {
		get { return getCoreView() }
	}
}

