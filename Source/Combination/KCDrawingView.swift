/**
 * @file KCDrawingView.swift
 * @brief Define KCDrawingView class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCDrawingView: KCStackView
{
	private var mMainToolsView:		KCCollectionView?
	private var mSubToolsView:		KCCollectionView?
	private var mStrokeColorView:		KCColorSelector?
	private var mFillColorView:		KCColorSelector?
	private var mVectorGraphicsView:	KCVectorGraphics?

	#if os(OSX)
	public override init(frame : NSRect){
		mMainToolsView		= nil
		mSubToolsView		= nil
		mStrokeColorView	= nil
		mFillColorView		= nil
		mVectorGraphicsView	= nil
		super.init(frame: frame) ;
		setup()
	}
	#else
	public override init(frame: CGRect){
		mMainToolsView		= nil
		mSubToolsView		= nil
		mStrokeColorView	= nil
		mFillColorView		= nil
		mVectorGraphicsView	= nil
		super.init(frame: frame)
		setup()
	}
	#endif

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 270)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 346)
		#endif
		self.init(frame: frame)
	}

	public required init?(coder: NSCoder) {
		mMainToolsView		= nil
		mSubToolsView		= nil
		mStrokeColorView	= nil
		mFillColorView		= nil
		mVectorGraphicsView	= nil
		super.init(coder: coder)
		setup()
	}

	public var mainToolType: KCVectorToolType {
		get {
			if let view = mVectorGraphicsView {
				return view.toolType
			} else {
				CNLog(logLevel: .error, message: "No graphics view (get)", atFunction: #function, inFile: #file)
				return .path(false)
			}
		}
		set(newval) {
			if let view = mVectorGraphicsView {
				view.toolType = newval
			} else {
				CNLog(logLevel: .error, message: "No graphics view (set)", atFunction: #function, inFile: #file)
			}
		}
	}

	public var strokeColor: CNColor {
		get {
			if let view = mVectorGraphicsView {
				return view.strokeColor
			} else {
				return CNColor.clear
			}
		}
		set(newval) {
			if let view = mVectorGraphicsView {
				view.strokeColor = newval
			}
		}
	}

	public var fillColor: CNColor {
		get {
			if let view = mVectorGraphicsView {
				return view.fillColor
			} else {
				return CNColor.clear
			}
		}
		set(newval) {
			if let view = mVectorGraphicsView {
				view.fillColor = newval
			}
		}
	}

	private func setup(){
		let initmaintools: Array<KCVectorToolType> = [
			.mover,
			.string,
			.path(false),
			.path(true),
			.rect(false, false),
			.rect(true,  false),
			.rect(false, true),
			.rect(true,  true),
			.oval(false),
			.oval(true)
		]

		/* Holizontal axis*/
		self.axis = .horizontal

		/* Allocate tool box */
		let toolbox = KCStackView()
		toolbox.axis = .vertical
		self.addArrangedSubView(subView: toolbox)

		/* Add main tool component */
		let maintool = KCCollectionView()
		maintool.set(icons: allocateMainToolImages(mainTools: initmaintools))
		maintool.set(selectionCallback: {
            (_ idnum: Int) -> Void in
			self.selectMainTool(idNumber: idnum)
		})
		toolbox.addArrangedSubView(subView: maintool)
		mMainToolsView = maintool

		/* Add sub tool component */
		let subtool = KCCollectionView()
        subtool.set(icons: allocateSubToolImages(toolType: initmaintools[0]))
		subtool.set(selectionCallback: {
            (_ idnum: Int) -> Void in
			self.selectSubTool(item: idnum)
		})
		toolbox.addArrangedSubView(subView: subtool)
		mSubToolsView = subtool

		/* Add color tool component */
		let strokeview   = KCColorSelector()
		strokeview.callbackFunc = {
			(_ color: CNColor) -> Void in
			self.strokeColor = color
		}
		mStrokeColorView = strokeview

		let fillview     = KCColorSelector()
		fillview.callbackFunc = {
			(_ color: CNColor) -> Void in
			self.fillColor = color
		}
		mFillColorView	 = fillview

		let colorbox    = KCStackView()
		colorbox.axis   = .horizontal
		colorbox.addArrangedSubView(subView: strokeview)
		colorbox.addArrangedSubView(subView: fillview)
		toolbox.addArrangedSubView(subView: colorbox)

		/* Add drawing area */
		let bezierview = KCVectorGraphics()
		self.addArrangedSubView(subView: bezierview)
		mVectorGraphicsView = bezierview

		/* assign initial tool */
		self.mainToolType = initmaintools[0]

		/* assign default color */
		strokeview.color = bezierview.strokeColor
		fillview.color   = bezierview.fillColor
	}

	private func allocateMainToolImages(mainTools tools: Array<KCVectorToolType>) -> Array<CNIcon> {
        var icons: Array<CNIcon> = []
		for tool in tools {
			let icon: CNIcon
			switch tool {
			case .mover:
                icon = CNIcon(tag: 0, symbol: .handRaised, title: "mover")
			case .path(let dofill):
				icon = CNIcon(tag: 1, symbol: .pencil(doFill: dofill), title: "path")
			case .rect(let dofill, let hasround):
				icon = CNIcon(tag: 2, symbol: .rectangle(doFill: dofill, hasRound: hasround), title: "rect")
			case .string:
                icon = CNIcon(tag: 3, symbol: .character, title: "strings")
			case .oval(let dofill):
				icon = CNIcon(tag: 4, symbol: .oval(doFill: dofill), title: "oval")
			}
			icons.append(icon)
		}
		return icons
	}

	private func selectMainTool(idNumber idnum: Int){
		let newtype: KCVectorToolType
		switch idnum {
		case 0: newtype = .mover
		case 1:	newtype = .string
		case 2: newtype = .path(false)
		case 3:	newtype = .path(true)
		case 4:	newtype = .rect(false, false)
		case 5:	newtype = .rect(true,  false)
		case 6: newtype = .rect(false, true)
		case 7: newtype = .rect(true,  true)
		case 8: newtype = .oval(false)
		case 9: newtype = .oval(true)
		default:
			CNLog(logLevel: .error, message: "Unexpected main tool item", atFunction: #function, inFile: #file)
			return
		}
		self.mainToolType = newtype
	}

	private func allocateSubToolImages(toolType tool: KCVectorToolType) -> Array<CNIcon> {
		let icons: Array<CNIcon>
		switch tool {
		case .mover, .path, .rect, .oval, .string:
            let item0 = CNIcon(tag: 0, symbol: .line_1p,  title: "line 1p")
            let item1 = CNIcon(tag: 1, symbol: .line_2p,  title: "line 2p")
            let item2 = CNIcon(tag: 2, symbol: .line_4p,  title: "line 4p")
            let item3 = CNIcon(tag: 3, symbol: .line_8p,  title: "line 8p")
            let item4 = CNIcon(tag: 4, symbol: .line_16p, title: "line 16p")
			icons = [item0, item1, item2, item3, item4]
		}
		return icons
	}

	private func selectSubTool(item itm: Int){
		switch self.mainToolType {
		case .mover, .path, .rect, .oval, .string:
			switch itm {
			case 0:	bezierLineWidth =  1.0	// line1P
			case 1: bezierLineWidth =  2.0	// line2P
			case 2: bezierLineWidth =  4.0	// line4P
			case 3: bezierLineWidth =  8.0	// line8P
			case 4: bezierLineWidth = 16.0	// line16P
			default:
				CNLog(logLevel: .error, message: "Unexpected item: \(itm)", atFunction: #function, inFile: #file)
			}
		}
	}

	public var drawingWidth: CGFloat? {
		get {
			if let view = mVectorGraphicsView {
				return view.width
			} else {
				return nil
			}
		}
		set(newval){
			if let view = mVectorGraphicsView {
				view.width = newval
			} else {
				CNLog(logLevel: .error, message: "No bezier view", atFunction: #function, inFile: #file)
			}
		}
	}

	public var drawingHeight: CGFloat? {
		get {
			if let view = mVectorGraphicsView {
				return view.height
			} else {
				return nil
			}
		}
		set(newval){
			if let view = mVectorGraphicsView {
				view.height = newval
			} else {
				CNLog(logLevel: .error, message: "No bezier view", atFunction: #function, inFile: #file)
			}
		}
	}

	private var bezierLineWidth: CGFloat {
		get {
			if let bezier = mVectorGraphicsView {
				return bezier.lineWidth
			} else {
				CNLog(logLevel: .error, message: "No bezier view", atFunction: #function, inFile: #file)
				return 0.0
			}
		}
		set(newval){
			if let bezier = mVectorGraphicsView {
				bezier.lineWidth = newval
			} else {
				CNLog(logLevel: .error, message: "No bezier view", atFunction: #function, inFile: #file)
			}
		}
	}

	public var firstResponderView: KCViewBase? { get {
		return mVectorGraphicsView
	}}

	/*
	 * load/store
	 */
	public func toValue() -> CNValue {
		if let view = mVectorGraphicsView {
			return view.toValue()
		} else {
			return CNValue.null
		}
	}

	public func load(from url: URL) -> Bool {
		if let view = mVectorGraphicsView {
			if let err = view.load(from: url) {
				CNLog(logLevel: .error, message: err.toString(), atFunction: #function, inFile: #file)
				return false
			} else {
				return true
			}
		} else {
			CNLog(logLevel: .error, message: "No vector graphics view", atFunction: #function, inFile: #file)
			return false
		}
	}
}

