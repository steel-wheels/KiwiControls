/**
 * @file	KCIconView.swift
 * @brief	Define KCIconView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(iOS)
	import UIKit
#else
	import Cocoa
#endif
import CoconutData

open class KCIconView: KCInterfaceView
{
    public typealias CallbackFunction = KCIconViewCore.CallbackFunction

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
		if let newview = loadChildXib(thisClass: KCIconView.self, nibName: "KCIconViewCore") as? KCIconViewCore {
			setCoreView(view: newview)
			newview.setup(frame: self.frame)
			allocateSubviewLayout(subView: newview)
		} else {
			fatalError("Can not load KCIconViewCore")
		}
	}

	public var buttonPressedCallback: CallbackFunction? {
		get	   { return coreView.buttonPressedCallback 	}
		set(newcb) { coreView.buttonPressedCallback = newcb	}
	}

	public var symbol: CNSymbol {
		get		{ return coreView.symbol   }
		set(newsym)	{ coreView.symbol = newsym }
	}

	public var title: String {
		get 		{ return coreView.title		}
		set(newstr)	{ coreView.title = newstr	}
	}

    public var targetSize: CGSize? {
        get        { return coreView.targetSize }
        set(newsz) { coreView.targetSize = newsz}
    }

    public var idNumber: Int {
        get      { return coreView.idNumber }
        set(val) { coreView.idNumber = val  }
    }

	open override func updateAppearance() {
		super.updateAppearance()
		coreView.updateAppearance()
	}

	open override func accept(visitor vis: KCViewVisitor){
		vis.visit(icon: self)
	}

	private var coreView: KCIconViewCore {
		get { return getCoreView() }
	}
}
