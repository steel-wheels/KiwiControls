//
//  SingleViewController.swift
//  UTLayout
//
//  Created by Tomoo Hamada on 2019/05/20.
//  Copyright © 2019 Steel Wheels Project. All rights reserved.
//

import KiwiControls
import CoconutData
import Foundation

public class SingleViewController: KCSingleViewController
{
	public override func loadViewContext(rootView root: KCRootView) -> KCSize {
		let topview = KCStackView()

		//allocateContents0(topView: topview)
		//allocateContents1(topView: topview)
		//allocateContents2(topView: topview)
		allocateContents3(topView: topview)
		root.setup(childView: topview)

		return topview.fittingSize
	}

	private func allocateContents0(topView topview: KCStackView){
		let dmyrect   = KCRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)

		//let imgname = "WideImage-1"
		let imgname = "TallImage-1"
		if let imgurl = CNFilePath.URLForResourceFile(fileName: imgname, fileExtension: "png") {
			if let imgdata = CNImage(contentsOf: imgurl) {
				NSLog("image-size: original -> \(imgdata.size)")
				let imgview = KCImageView()
				imgview.set(image: imgdata)
				topview.addArrangedSubView(subView: imgview)
			}
		}

		let button0   = KCButton(frame: dmyrect)
		button0.title = "OK"
		topview.addArrangedSubView(subView: button0)
	}

	private func allocateContents1(topView topview: KCStackView){
		let dmyrect = KCRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
		let hbox    = KCStackView(frame: dmyrect)
		hbox.axis   = .horizontal

		let text0   = KCTextField(frame: dmyrect)
		text0.text  = "Hello-------------------------------------------------------------"
		let text1   = KCTextField(frame: dmyrect)
		text1.text  = "Good morning"

		hbox.addArrangedSubViews(subViews: [text0, text1])

		topview.addArrangedSubView(subView: hbox)
	}

	private func allocateContents2(topView topview: KCStackView){
		let dmyrect = KCRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)

		let text0   = KCTextField(frame: dmyrect)
		text0.text  = "Hello-------------------------------------------------------------"
		let text1   = KCTextField(frame: dmyrect)
		text1.text  = "Good morning"
		let vbox0    = KCStackView(frame: dmyrect)
		vbox0.axis   = .vertical
		vbox0.addArrangedSubViews(subViews: [text0, text1])

		let text2   = KCTextField(frame: dmyrect)
		text2.text  = "Hello-------------------------------------------------------------"
		let text3   = KCTextField(frame: dmyrect)
		text3.text  = "Good morning"
		let vbox1    = KCStackView(frame: dmyrect)
		vbox1.axis   = .vertical
		vbox1.addArrangedSubViews(subViews: [text3, text2])

		let hbox = KCStackView(frame: dmyrect)
		hbox.axis   = .horizontal
		hbox.addArrangedSubViews(subViews: [vbox0, vbox1])

		topview.addArrangedSubView(subView: hbox)
	}

	private func allocateContents3(topView topview: KCStackView){
		let dmyrect  = KCRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
		let consview0 = KCConsoleView(frame: dmyrect)
		let consview1 = KCConsoleView(frame: dmyrect)

		let hbox = KCStackView(frame: dmyrect)
		hbox.axis   = .horizontal
		hbox.addArrangedSubViews(subViews: [consview0, consview1])
		topview.addArrangedSubView(subView: hbox)

		let console0 = consview0.consoleConnection
		let console1 = consview1.consoleConnection

		console0.print(string: "Hello, world. This message is written into the console0.")
		console1.print(string: "Good morning, world. This message is written into the console1.")
	}

	private func doDumpView(message msg: String){
		if let view = self.rootView, let cons = console {
			log(type: .debug, string: msg, file: #file, line: #line, function: #function)
			let dumper = KCViewDumper(console: cons)
			dumper.dump(view: view)
		} else {
			fatalError("No root view or console")
		}
	}
}

