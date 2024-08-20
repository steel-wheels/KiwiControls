//
//  ViewController.swift
//  UTLayout
//
//

import KiwiControls
import CoconutData
import Cocoa

class ViewController: KCMultiViewController
{
	//@IBOutlet weak var mRootView: KCRootView!

	override func viewDidAppear() {
		super.viewDidAppear()

		let cons   = CNDefaultConsole()
		self.set(console: cons)

		let vcont  = SingleViewController(parentViewController: self, console: cons)
		self.add(name: "vcont", viewController: vcont)
		let _ = self.pushViewController(byName: "vcont")
	}
}


