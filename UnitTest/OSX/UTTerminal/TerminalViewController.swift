/*
 * @file	TerminalViewController.swift
 * @brief	Define TerminalViewController class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import KiwiControls
import CoconutData
import CoconutShell
import Foundation

open class UTShellThread: CNShellThread
{
	public var terminalView: KCTerminalView? = nil

	open override func execute(command cmd: String) {
		#if false
		CNExecuteInMainThread(doSync: true, execute: {
			() -> Void in
			if let view = self.terminalView {
				let offset = view.verticalOffset()
				self.console.print(string: "vOffset = \(offset)\n")
			}
		})
		#endif
	}
}

public class TerminalViewController: KCSingleViewController
{
	private var mTerminalView:	KCTerminalView? = nil
	private var mShell:		UTShellThread?  = nil

	open override func loadContext() -> KCView? {
		let termview = KCTerminalView()
		/* Allocate shell */
		CNLog(logLevel: .detail, message: "Launch terminal")
		let procmgr : CNProcessManager = CNProcessManager()
		let infile  : CNFile = termview.inputFile
		let outfile : CNFile = termview.outputFile
		let errfile : CNFile = termview.errorFile
		let terminfo         = CNTerminalInfo(width: 80, height: 25)
		let environment      = CNEnvironment()
		CNLog(logLevel: .detail, message: "Allocate shell")
		let shell     = UTShellThread(processManager: procmgr, input: infile, output: outfile, error: errfile, terminalInfo: terminfo, environment: environment)
		mShell        = shell
		shell.terminalView = termview
		mTerminalView = termview

		#if true
			let box = KCStackView()
			box.axis = .vertical
			box.addArrangedSubView(subView: termview)
			return box
		#else
			return termview
		#endif
	}

	public override func viewDidAppear() {
		super.viewDidAppear()

		guard let termview = mTerminalView else {
			CNLog(logLevel: .error, message: "No terminal view")
			return
		}

		/* Start shell */
		if let shell = mShell {
			CNLog(logLevel: .detail, message: "Start shell")
			shell.start(argument: CNValue.null)
		}

		/* Receive key input */
		let infile  = termview.inputFile
		let outfile = termview.outputFile
		let errfile = termview.errorFile

		/* Print to output */
		let red = CNEscapeCode.foregroundColor(CNColor.red).encode()
		outfile.put(string: red + "Red\n")

		let blue = CNEscapeCode.foregroundColor(CNColor.blue).encode()
		outfile.put(string: blue + "Blue\n")

		let green = CNEscapeCode.foregroundColor(CNColor.green).encode()
		outfile.put(string: green + "Green\n")

		let reset = CNEscapeCode.resetCharacterAttribute.encode()
		let under = CNEscapeCode.underlineCharacter(true).encode()
		outfile.put(string: reset + under + "Underline\n")

		let bold = CNEscapeCode.boldCharacter(true).encode()
		outfile.put(string: bold + "Bold\n" + reset)

		let terminfo = termview.terminalInfo
		//let width  = terminfo.width
		//let height = terminfo.height
		let console  = CNFileConsole(input: infile, output: outfile, error: errfile)
		let curses   = CNCurses(console: console, terminalInfo: terminfo)
		curses.begin()
		curses.fill(x: 0, y: 0, width: terminfo.width, height: terminfo.height, char: "x")
		/*
		for i in 0..<10 {
			curses.moveTo(x: i, y: i)
			curses.put(string: "o")
		}
		for x in 0..<width {
			curses.moveTo(x: x, y: 0)
			console.print(string: "+")

			curses.moveTo(x: x, y: height-1)
			console.print(string: "+")
		}*/
	}

}

