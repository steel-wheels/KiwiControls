//
//  ViewController.swift
//  UTTable
//
//  Created by Tomoo Hamada on 2021/05/14.
//

import KiwiControls
import CoconutData
import Cocoa

class ViewController: KCViewController, KCViewControlEventReceiver
{
	@IBOutlet weak var mTableView: KCTableView!
	@IBOutlet weak var mAddButton: KCButton!
	@IBOutlet weak var mSaveButton: KCButton!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupTableView()
		self.setupUpdateButton()
		self.setupSaveButton()
	}

	private func setupTableView() {
		/* Start logging */
		NSLog("Start logging ... begin")
		let _ = KCLogWindowManager.shared // init
		CNPreference.shared.systemPreference.logLevel = .debug
		NSLog("Start logging ... end")

		/* Set editable */
		mTableView.hasGrid   = true
		mTableView.hasHeader = true

		mTableView.isEnableCallback = {
			(_ row: Int) -> Bool in
			let result = (row % 2) == 1
			NSLog("isEnable for row \(row) -> \(result)")
			return result
		}

		guard let table = loadTable(name: "table0") else {
			NSLog("Failed to load table0")
			return
		}
		let recnum  = table.recordCount
		NSLog("record count: \(recnum)")

		NSLog("Set visible fields")
		CNLog(logLevel: .debug, message: "reload data", atFunction: #function, inFile: #file)
		mTableView.dataTable = table
		mTableView.filterFunction = {
			(_ rec: CNRecord) -> Bool in
			for field in rec.fieldNames {
				var fval:  String = "?"
				if let fld = rec.value(ofField: field) {
					fval = fld.description
				}
				NSLog("recordMapping: field=\(field), value=\(fval)")
			}
			return true
		}
		NSLog("reload table")
		mTableView.reload()
	}

	private func setupUpdateButton() {
		mAddButton.value = .text("Update")
		mAddButton.buttonPressedCallback = {
			() -> Void in
			NSLog("Button pressed callback")

			guard let table = self.loadTable(name: "table1") else {
				NSLog("Failed to load table1.json")
				return
			}

			let recnum  = table.recordCount
			NSLog("record count: \(recnum)")

			self.mTableView.hasGrid = true
			CNLog(logLevel: .debug, message: "reload data", atFunction: #function, inFile: #file)

			self.mTableView.dataTable = table
			self.mTableView.reload()
		}
	}

	private func setupSaveButton() {
		mSaveButton.value = .text("Save")
		mSaveButton.buttonPressedCallback = {
			/*
			let url = URL(fileURLWithPath: "new-table1.json")
			let val: CNValue = .dictionaryValue(self.mTableView.dataTable.toValue())
			if let err = CNSaveValueFile(destinationURL: url, value: val) {
				NSLog("save ... error: \(err.toString())")
			} else {
				NSLog("save ... ok")
			}*/
		}
	}

	private func loadTable(name nm: String) -> CNVirtualTable? {
		CNLog(logLevel: .debug, message: "setup value table", atFunction: #function, inFile: #file)

		guard let srcfile = CNFilePath.URLForResourceFile(fileName: nm, fileExtension: "json", subdirectory: "Data", forClass: ViewController.self) else {
			NSLog("Failed to get URL of storage.json")
			return nil
		}
		switch CNValueTable.load(from: srcfile) {
		case .success(let tbl):
			let vtable = CNVirtualTable(sourceTable: tbl)
			return vtable
		case .failure(let err):
			NSLog("[Error] \(err.toString())")
			return nil
		}
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	public override func viewDidLayout() {
		/* Init window */
		if let win = self.view.window {
			NSLog("Initialize window attributes")
			initWindowAttributes(window: win)
		} else {
			NSLog("[Error] No window")
		}
	}

	public override func viewDidAppear() {
	}

	public func notifyControlEvent(viewControlEvent event: KCViewControlEvent) {
		switch event {
		case .none:
			CNLog(logLevel: .detail, message: "Control event: none", atFunction: #function, inFile: #file)
		case .updateSize(let targview):
			CNLog(logLevel: .detail, message: "Update window size: \(targview.description)", atFunction: #function, inFile: #file)
		case .switchFirstResponder(let newview):
			if let window = self.view.window {
				if !window.makeFirstResponder(newview) {
					CNLog(logLevel: .error, message: "makeFirstResponder -> Fail", atFunction: #function, inFile: #file)
				}
			} else {
				CNLog(logLevel: .error, message: "Failed to switch first responder", atFunction: #function, inFile: #file)
			}
		}
	}
}

