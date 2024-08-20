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
	public override init(parentViewController parent: KCMultiViewController){
		super.init(parentViewController: parent)
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	public override func loadContext() -> KCView? {
		NSLog("load context")
		let result = KCCollectionView()
		let newval = allocateValue()
		result.isSelectable = true
		result.store(data: newval)
		result.set(selectionCallback:{
			(_ section: Int, _ item: Int) -> Void in
			NSLog("selected section=\(section), item=\(item)")
		})
		return result
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

	private func allocateValue() -> CNCollection {
		let newelm0: Array<CNCollection.Item> = [
			.image(CNSymbol.shared.URLOfSymbol(type: .chevronForward)),
			.image(CNSymbol.shared.URLOfSymbol(type: .chevronBackward)),
			.image(CNSymbol.shared.URLOfSymbol(type: .rectangle(false, false))),
			.image(CNSymbol.shared.URLOfSymbol(type: .rectangle(false, true))),
			.image(CNSymbol.shared.URLOfSymbol(type: .rectangle(true, false))),
			.image(CNSymbol.shared.URLOfSymbol(type: .rectangle(true, true))),
		]
		let newelm1: Array<CNCollection.Item> = [
			.image(CNSymbol.shared.URLOfSymbol(type: .handRaised)),
			.image(CNSymbol.shared.URLOfSymbol(type: .paintbrush)),
			.image(CNSymbol.shared.URLOfSymbol(type: .oval(false))),
			.image(CNSymbol.shared.URLOfSymbol(type: .oval(true)))
		]
		let cdata = CNCollection()
		cdata.add(header: "header0", footer: "footer0", items: newelm0)
		cdata.add(header: "header1", footer: "footer1", items: newelm1)
		return cdata
	}

	private func doDumpView(message msg: String){
		if let view = self.view as? KCRootView {
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

