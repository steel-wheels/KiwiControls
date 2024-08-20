//
//  ViewController.swift
//  UTControl_iOS
//
//  Created by Tomoo Hamada on 2022/09/24.
//

import KiwiControls
import CoconutData
import UIKit


class ViewController: KCMultiViewController
{
	override func loadView() {
		super.loadView()
		let scontroller = SingleViewController(parentViewController: self)
		self.pushViewController(viewController: scontroller, callback: {
			(_ val: CNValue) -> Void in
			NSLog("single view controller: callback")
		})
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewDidAppear(_ doanimate: Bool) {
		super.viewDidAppear(doanimate)
	}
}


