//
//  ViewController.swift
//  UTListView
//
//  Created by Tomoo Hamada on 2023/06/04.
//

import KiwiControls
import CoconutData
import Cocoa

class ViewController: NSViewController {

	@IBOutlet weak var mListView: KCListView!

	override func viewDidLoad() {
		super.viewDidLoad()

		mListView.selectionNotification = {
			(_ str: String) -> Void in
			NSLog("selected: \(str)")
		}
		mListView.set(items: [
			"a",
			"b",
			"c",
			"d",
			"e"
		])
		mListView.isEditable = true

		// Do any additional setup after loading the view.
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

