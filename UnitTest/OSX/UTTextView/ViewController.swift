//
//  ViewController.swift
//  UTTextView
//
//  Created by Tomoo Hamada on 2021/03/29.
//

import KiwiControls
import CoconutData
import Cocoa

class ViewController: NSViewController
{
	@IBOutlet weak var mTextView: KCTextView!

	override func viewDidLoad() {
		super.viewDidLoad()

		mTextView.isEditable = true

		var longstr: String = ""
		for i in 0..<40 {
			longstr += "\(i % 10)"
		}
		longstr += "\n"

		let codes: Array<CNEscapeCode> = [
			.string("Hello, World !!\n"),
			.boldCharacter(true),
			.string("Good "),
			.boldCharacter(false),
			.string("Morning,"),
			.foregroundColor(CNColor.yellow),
			.backgroundColor(CNColor.blue),
			.string("Good Evening\n"),
			.defaultForegroundColor,
			.defaultBackgroundColor,
			.string(longstr),
			.string(longstr),
			.string(longstr),
			.cursorUp(2),
			.cursorForward(20),
			.eraceEntireLine,
			.cursorForward(20),
			.eraceFromCursorToEnd,
			.string("*"),
			.cursorBackward(1),
			.eraceFromCursorToBegin,

		]
		mTextView.execute(escapeCodes: codes)

		let terminfo = mTextView.terminalInfo

		let width    = terminfo.width
		let height   = terminfo.height
		var codes2: Array<CNEscapeCode> = []
		codes2.append(.selectAltScreen(true))
		for y in 0..<height-1 {
			for x in 0..<width-1 {
				CNLog(logLevel: .detail, message: "cursorPosition(\(x), \(y))")
				let c = x % 10
				codes2.append(.cursorPosition(y+1, x+1))
				codes2.append(.string("\(c)"))
			}
		}
		mTextView.execute(escapeCodes: codes2)
	}

	override var representedObject: Any? {
		didSet {
		// Update the view, if already loaded.
		}
	}
}

