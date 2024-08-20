//
//  ViewController.swift
//  UTTextEdit_iOS
//
//  Created by Tomoo Hamada on 2023/01/21.
//

import KiwiControls
import CoconutData
import UIKit

class ViewController: UIViewController
{
	@IBOutlet weak var mTextEdit: KCTextEdit!

	private var mTerminalInfo = CNTerminalInfo(width: 80, height: 25)
	private var mFont = CNFont.systemFont(ofSize: 24.0)
	private var mIndex: Int = 0

	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		mTextEdit.isEditable = true
		mTextEdit.entireBackgroundColor = CNColor.blue

		let hdr = mTextEdit.handler
		//hdr.backgroundColor(CNColor.blue)
		//hdr.foregroundColor(CNColor.yellow)
		hdr.string("Hello")
		hdr.newline()
		hdr.string("Good morning,")
		hdr.tab()
		hdr.string("Good evening")
		hdr.backspace()
		hdr.string("G!")
		hdr.delete()
		hdr.string(".")
		hdr.newline()
		hdr.string("0123456789")
		hdr.newline()
		hdr.string("abcdefghij")
		hdr.cursorBackward(5)
		hdr.string("F")
		hdr.cursorForward(1)
		hdr.string("G")
		hdr.cursorNextLine(1)
		hdr.string("N")
		hdr.cursorPreviousLine(1)
		hdr.string("P")
		hdr.cursorForward(4)
		hdr.cursorHolizontalAbsolute(2)
		hdr.string("Q")
		hdr.cursorUp(1)
		hdr.string("R")
		hdr.eraceFromCursorToLeft()
		hdr.eraceFromCursorToRight()
		hdr.string("SS")
		hdr.cursorForward(1)
		hdr.insertSpace(2)
		hdr.execute()
	}


}

