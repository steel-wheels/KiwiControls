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
	open override func loadContext() -> KCView? {
		let stackview = KCStackView()
		stackview.axis = .vertical

		let labview = KCLabelView()
		labview.text = "label"
		stackview.addArrangedSubView(subView: labview)

		let iconview = KCIconView()
		iconview.symbol = .character
		iconview.title  = "icon view"
		stackview.addArrangedSubView(subView: iconview)

		let symbol  = CNSymbol.character
		let imgview = KCImageView()
		imgview.image = symbol.load(size: .regular)
		stackview.addArrangedSubView(subView: imgview)

		let collectdata = CNCollection()
		collectdata.add(header: "", footer: "", items: [
			.chevronBackward,
			.chevronForward
		])

		let collectview = KCCollectionView()
		collectview.store(data: collectdata)
		collectview.isSelectable = true
		collectview.set(selectionCallback: {
			(_ section: Int, _ item: Int) -> Void in
			NSLog("selected section=\(section), item=\(item)")
		})
		stackview.addArrangedSubView(subView: collectview)

		let radio     = KCRadioButtons()
		radio.columnNum = 3
		radio.setLabels(labels: [
			KCRadioButtons.Label(title: "a", id: 0),
			KCRadioButtons.Label(title: "b", id: 1),
			KCRadioButtons.Label(title: "c", id: 2)
		])
		radio.setState(labelId: 0, state: .on)
		radio.setState(labelId: 1, state: .off)
		radio.setState(labelId: 2, state: .off)
		radio.callback = {
			(_ index: Int?) -> Void in
			NSLog("Radio index: \(String(describing: index))")
		}
		stackview.addArrangedSubView(subView: radio)


		let stepper  = KCStepper()
		stepper.minValue     = -1.0
		stepper.maxValue     = +1.0
		stepper.stepValue    = 0.1
		stepper.currentValue = 0.0
		stackview.addArrangedSubView(subView: stepper)

		let buttonview = KCButton()
		buttonview.value = .text("Hello")
		stackview.addArrangedSubView(subView: buttonview)

		return stackview
	}
}

