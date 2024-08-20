/**
 * @file KCLabel..swift
 * @brief Define KCLabel class
 * @par Copyright
 *   Copyright (C) 2018-2022 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCLabelView: KCInterfaceView
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
        if let newview = loadChildXib(thisClass: KCLabelViewCore.self, nibName: "KCLabelViewCore") as? KCLabelViewCore {
            setCoreView(view: newview)
            newview.setup(frame: self.frame)
            allocateSubviewLayout(subView: newview)
        } else {
            fatalError("Can not load KCLabelViewCore")
        }
    }

    public var isEnabled: Bool {
        get         { return coreView.isEnabled }
        set(newval) { coreView.isEnabled = newval }
    }

    public var alignment: NSTextAlignment {
        get         { return coreView.alignment   }
        set(newval) { coreView.alignment = newval }
    }

    public var text: String {
        get         { return coreView.text   }
        set(newval) { coreView.text = newval }
    }

    public var number: NSNumber? {
        get         { return coreView.number   }
        set(newval) { coreView.number = newval }
    }

	open override func updateAppearance() {
		super.updateAppearance()
		coreView.updateAppearance()
	}

    open override func accept(visitor vis: KCViewVisitor){
        vis.visit(label: self)
    }

    private var coreView: KCLabelViewCore {
        get { return getCoreView() }
    }
}

