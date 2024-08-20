/**
 * @file	ViewController.swift
 * @brief	Define ViewController class
 * @par Copyright
 *   Copyright (C) 2022  Steel Wheels Project
 */

import CoconutData
import KiwiControls
import UIKit

class ViewController: KCMultiViewController
{
	private var mFirstView:  SingleViewController? = nil
	private var mSecondView: SingleViewController? = nil
	private var mIsFirstAppearing = true

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if mIsFirstAppearing {
			viewDidFirstAppear()
		}
	}

	private func viewDidFirstAppear() {
		/* Add first view */
		let firstcont = SingleViewController(viewType: .firstView, parentViewController: self)
		mFirstView = firstcont

		let secondcont = SingleViewController(viewType: .secondView, parentViewController:self)
		mSecondView = secondcont

		/* Push first view */
		super.pushViewController(viewController: firstcont, callback: {
			(_ val: CNValue) -> Void in
			NSLog("result: \(val.description)")
		})
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}

//
//  ViewController.swift
//  UTPickerView
//
//  Created by Tomoo Hamada on 2022/10/31.
//

/*
import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}


}
*/

