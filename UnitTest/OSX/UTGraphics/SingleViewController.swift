/**
 * @file SingleView0Controller.swift
 * @brief Define SingleView0Controller. class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import KiwiControls
import Cocoa
import Foundation

public class SingleViewController: KCSingleViewController
{
	private var mDrawingView: KCDrawingView? = nil

	public override init(parentViewController parent: KCMultiViewController){
		super.init(parentViewController: parent)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	public override func loadContext() -> KCView? {
		let drawv   = KCDrawingView()
		drawv.drawingWidth  = 600.0
		drawv.drawingHeight = 600.0
		mDrawingView = drawv

		let savebutton = KCButton()
		savebutton.value = .text("Save")
		savebutton.buttonPressedCallback = {
			() -> Void in
			self.saveDrawings(drawingView: drawv)
		}

		let loadbutton = KCButton()
		loadbutton.value = .text("Load")
		loadbutton.buttonPressedCallback = {
			() -> Void in
			self.loadDrawings(drawingView: drawv)
		}
		let buttons  = KCStackView()
		buttons.axis = .horizontal
		buttons.addArrangedSubView(subView: savebutton)
		buttons.addArrangedSubView(subView: loadbutton)

		let result = KCStackView()
		result.axis = .vertical
		result.addArrangedSubView(subView: drawv)
		result.addArrangedSubView(subView: buttons)

		return result
	}

	private func loadDrawings(drawingView dview: KCDrawingView) {
		URL.openPanel(title: "Select vector file to load", type: .File, extensions: ["json"], callback: {
			(_ url: URL?) -> Void in
			if let u = url {
				if dview.load(from: u) {
					NSLog("Load ... done")
				} else {
					NSLog("Load ... failed")
				}
			}
		})
	}

	private func saveDrawings(drawingView dview: KCDrawingView) {
		URL.savePanel(title: "Select vector file to save", outputDirectory: nil, callback: {
			(_ url: URL?) -> Void in
			if let u = url {
				let val = dview.toValue()
				if u.storeValue(value: val) {
					NSLog("Save ... done")
				} else {
					NSLog("Save ... failed")
				}
			}
		})
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
		if let view = mDrawingView {
			NSLog("drawing view: frame=\(view.frame.description)")
		}
	}
	#else
	public override func viewDidAppear(_ animated: Bool) {
		CNLog(logLevel: .detail, message: "viewDidAppear")
		super.viewDidAppear(animated)
		doDumpView(message: "Last viewDidAppear")
	}
	#endif

	private func doDumpView(message msg: String){
		if let view = self.rootView {
			if CNPreference.shared.systemPreference.logLevel.isIncluded(in: .detail) {
				let cons = CNLogManager.shared.console
				cons.print(string: msg + "\n")
				let dumper = KCViewDumper()
				dumper.dump(view: view, console: cons)
			}
		} else {
			fatalError("No root view")
		}
	}
}

