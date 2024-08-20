/**
 * @file	SingleViewController.swift
 * @brief	Define SingleViewController class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import CoconutData
import UIKit

class SingleViewController: KCSingleViewController
{
	open override func loadViewContext(rootView root: KCRootView) -> KCSize {
		let stackview = KCStackView()
		stackview.axis = .vertical

		if true {
			let termpref = KCTerminalPreferenceView()
			stackview.addArrangedSubView(subView: termpref)
		} else {
			let colselector = KCColorSelector()
			stackview.addArrangedSubView(subView: colselector)
		}

		root.setup(childView: stackview)
		return stackview.fittingSize
	}
}

