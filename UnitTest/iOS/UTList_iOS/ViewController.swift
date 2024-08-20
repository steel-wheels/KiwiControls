//
//  ViewController.swift
//  UTList_iOS
//
//  Created by Tomoo Hamada on 2023/06/04.
//

import KiwiControls
import CoconutData
import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var mListView: KCListView!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		mListView.selectionNotification = {
			(_ idx: String) -> Void in NSLog("selected: \(idx)")
		}
		mListView.set(items: [
			"a",
			"b",
			"c"
		])
		//mListView.isEditable = true
		//mListView.edit(enable: true)
	}
}

