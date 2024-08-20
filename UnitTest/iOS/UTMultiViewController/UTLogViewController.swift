/**
 * @file UTLogViewController.swift
 * @brief Define UTLogViewControllers class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import KiwiControls
import CoconutData
import Foundation

public class UTLogViewController: KCLogViewController
{
	private var mConsole = CNFileConsole()

	public override func viewWillAppear(_ animated: Bool) {
		NSLog("\(#function): viewWillAppear")
		super.viewWillAppear(animated)
		doDumpView()
	}

	public override func viewDidAppear(_ animated: Bool) {
		NSLog("\(#function): viewDidAppear")
		super.viewDidAppear(animated)
		doDumpView()
	}

	private func doDumpView(){
		if let view = self.rootView {
			let dumper = KCViewDumper(console: mConsole)
			dumper.dump(view: view)
		} else {
			fatalError("No root view")
		}
	}
}

