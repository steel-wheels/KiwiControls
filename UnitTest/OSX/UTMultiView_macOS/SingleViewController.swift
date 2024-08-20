/**
 * @file SingleView0Controller.swift
 * @brief Define SingleView0Controller. class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import KiwiControls
import Cocoa
import Foundation

public class SingleViewController: KCSingleViewController
{
	public enum Mode {
		case vertBox
		case horizBox
	}

	private var mMode:		Mode
	private var mTableView:		KCTableView

	public init(parentViewController parent: KCMultiViewController, mode md: Mode){
		mMode      = md
		mTableView = KCTableView()
		super.init(parentViewController: parent)
	}

	public required init?(coder: NSCoder) {
		mMode      = .vertBox
		mTableView = KCTableView()
		super.init(coder: coder)
	}

	public override func loadContext() -> KCView? {
		let result: KCView?
		switch mMode {
		case .vertBox:
			result = loadVertContext()
		case .horizBox:
			result = loadHolizContext()
		}
		return result
	}

	private func loadVertContext() -> KCView? {
		let label0    = KCTextField()
		label0.text   = "Hello, world. This is label0"

		let button0   = KCButton()
		button0.value = .text("OK")

		let box0 = KCStackView()
		box0.axis		= .horizontal
		box0.alignment		= .fill
		box0.distribution	= .fillEqually
		box0.addArrangedSubViews(subViews: [label0, button0])

		let edit1   = KCTextField()
		let icon1   = allocateIcon()
		let box1    = KCStackView()
		box1.axis		= .vertical
		box1.alignment		= .fill
		box1.distribution	= .fillEqually
		box1.addArrangedSubViews(subViews: [box0, icon1, edit1])

		return box1
	}

	private func loadHolizContext() -> KCView? {
		guard let imgurl = CNFilePath.URLForResourceFile(fileName: "steel-wheels", fileExtension: "png", subdirectory: nil, forClass: SingleViewController.self) else {
			CNLog(logLevel: .error, message: "No resource file", atFunction: #function, inFile: #file)
			return nil
		}
		guard let img0 = NSImage(contentsOf: imgurl) else {
			CNLog(logLevel: .error, message: "No image at \(imgurl.path)", atFunction: #function, inFile: #file)
			return nil
		}
		let imgview0 = KCImageView()
		imgview0.image = img0
		imgview0.scale = 0.2

		let radio     = KCRadioButtons()
		radio.columnNum = 3
		radio.setLabels(labels: [
			KCRadioButtons.Label(title: "a", id: 0),
			KCRadioButtons.Label(title: "b", id: 1),
			KCRadioButtons.Label(title: "c", id: 2)
		])
		radio.setState(labelId: 0, state: .on)
		radio.setState(labelId: 1, state: .off)
		radio.setState(labelId: 2, state: .off)
		radio.callback = {
			(_ index: Int?) -> Void in
			NSLog("Radio index: \(String(describing: index))")
		}

		let edit1  = KCTextField()
		edit1.isEditable = false
		edit1.text       = "This is text edit"

		let label1  = KCLabelView()
		label1.isEnabled  = true
		label1.text       = "This is label"

		let pmenu   = allocatePopupMenu()


		let button1   = KCButton()
		button1.value = .text("Select Home Directory")

		let box1 = KCStackView()
		box1.axis		    = .horizontal
		box1.alignment		= .fill
		box1.distribution	= .fillProportinally
		box1.addArrangedSubViews(subViews: [edit1, label1, pmenu, button1]) // gr2d1

		//let icon1     = allocateIcon()
		let button2   = KCButton()
		button2.value = .text("OK")

		//let labstack = KCLabeledStackView()
		//labstack.title = "Labeled Stack"

		let button30 = KCButton()
		button30.value = .text("First name")
		let button31 = KCButton()
		button31.value = .text("Given name")
		let box3 = KCStackView()
		box3.axis = .horizontal
		box3.addArrangedSubViews(subViews: [button30, button31])
		//labstack.addArrangedSubViews(subViews: [box3])
		let lstview = allocateListView()

		let box2 = KCStackView()
		box2.axis = .vertical
		box2.addArrangedSubViews(subViews: [imgview0, lstview, radio, box1, button2])

		return box2
	}

	private func allocateIcon() -> KCIconView {
		let icon   = KCIconView()
		icon.title = "Icon Title"
		icon.symbol = CNSymbol.character
		icon.size   = .regular
		icon.buttonPressedCallback = {
			() -> Void in
			CNLog(logLevel: .detail, message: "Icon pressed")
		}
		return icon
	}

	/*
	private func allocateGraphics2DView() -> KCGraphics2DView {
		let newview = UTGraphics2DView()
		//newview.setTimer(doUse: true, interval: 1.0)
		return newview
	}*/

	private func allocatePopupMenu() -> KCPopupMenu {
		let newmenu = KCPopupMenu()
		let items: Array<CNMenuItem> = [
			CNMenuItem(title: "hello",		value: 0),
			CNMenuItem(title: "good morning",	value: 1)
		]
		newmenu.set(menuItems: items)
		newmenu.selectionNotification = {
			(_ val: Int) -> Void in
			CNLog(logLevel: .error, message: "PopupMenu: value=\(val)")
		}
		return newmenu ;
	}

	private func allocateListView() -> KCListView {
		let newlist = KCListView()
		//newlist.addItems(values: [
		//	.stringValue("a"),
		//	.stringValue("b")
		//])
		return newlist
	}

	public override func viewDidLoad() {
		CNLog(logLevel: .detail, message: "viewDidLoad")
		super.viewDidLoad()
	}

	#if os(OSX)
	public override func viewWillAppear() {
		CNLog(logLevel: .detail, message: "viewWillAppear")
		super.viewWillAppear()
		doDumpView(message: "Last viewWillAppear")
	}
	#else
	public override func viewWillAppear(_ animated: Bool) {
		CNLog(logLevel: .detail, message: "viewWillAppear")
		super.viewWillAppear(animated)
		doDumpView(message: "Last viewWillAppear")
	}
	#endif

	#if os(OSX)
	public override func viewDidAppear() {
		CNLog(logLevel: .detail, message: "viewDidAppear")
		super.viewDidAppear()
		doDumpView(message: "Last viewDidAppear")
	}
	#else
	public override func viewDidAppear(_ animated: Bool) {
		CNLog(logLevel: .detail, message: "viewDidAppear")
		super.viewDidAppear(animated)
		doDumpView(message: "Last viewDidAppear")
	}
	#endif

	private func doDumpView(message msg: String){
		if CNPreference.shared.systemPreference.logLevel.isIncluded(in: .detail) {
			let cons = CNLogManager.shared.console
			cons.print(string: msg + "\n")
			super.dumpView(console: cons)
		}

	}
}


public class UTGraphics2DView: KCGraphics2DView {
	open override func draw(graphicsContext ctxt: CNGraphicsContext, count cnt: Int32) {
		CNLog(logLevel: .detail, message: "UTGraphics2DView: \(cnt)")
	}
}
