/**
 * @file	KCTerminalView.swift
 * @brief Define KCTerminalView class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCTerminalView : KCTextEdit
{
	private var mInputPipe:		Pipe
	private var mOutputPipe:	Pipe
	private var mErrorPipe:		Pipe

	private var mInputFile:		CNInputFile
	private var mOutputFile:	CNOutputFile
	private var mErrorFile:		CNOutputFile

	private var mConsole:		CNFileConsole

	public var console: CNFileConsole { get { return mConsole }}

#if os(OSX)
	public override init(frame : NSRect){
		mInputPipe	= Pipe()
		mOutputPipe	= Pipe()
		mErrorPipe	= Pipe()
		mInputFile	= mInputPipe.fileForReading(fileType:  .standardIO)
		mOutputFile	= mOutputPipe.fileForWriting(fileType: .standardIO)
		mErrorFile 	= mErrorPipe.fileForWriting(fileType:  .standardIO)
		mConsole	= CNFileConsole(input: mInputFile, output: mOutputFile, error: mErrorFile)
		super.init(frame: frame)
		setup()
	}
#else
	public override init(frame: CGRect){
		mInputPipe	= Pipe()
		mOutputPipe	= Pipe()
		mErrorPipe	= Pipe()
		mInputFile	= mInputPipe.fileForReading(fileType:  .standardIO)
		mOutputFile	= mOutputPipe.fileForWriting(fileType: .standardIO)
		mErrorFile 	= mErrorPipe.fileForWriting(fileType:  .standardIO)
		mConsole	= CNFileConsole(input: mInputFile, output: mOutputFile, error: mErrorFile)
		super.init(frame: frame)
		setup()
	}
#endif

	public required init?(coder: NSCoder) {
		mInputPipe	= Pipe()
		mOutputPipe	= Pipe()
		mErrorPipe	= Pipe()
		mInputFile	= mInputPipe.fileForReading(fileType: .standardIO)
		mOutputFile	= mOutputPipe.fileForWriting(fileType: .standardIO)
		mErrorFile 	= mErrorPipe.fileForWriting(fileType: .standardIO)
		mConsole	= CNFileConsole(input: mInputFile, output: mOutputFile, error: mErrorFile)
		super.init(coder: coder)
		setup()
	}

	public convenience init(){
		#if os(OSX)
			let frame = NSRect(x: 0.0, y: 0.0, width: 480, height: 270)
		#else
			let frame = CGRect(x: 0.0, y: 0.0, width: 375, height: 22)
		#endif
		self.init(frame: frame)
	}

	deinit {
		removeObservers()
	}

	private func removeObservers() {
		mOutputPipe.fileHandleForReading.readabilityHandler = nil
		mErrorPipe.fileHandleForReading.readabilityHandler  = nil

		mOutputPipe.fileHandleForReading.setRawMode(enable: false)
		mErrorPipe.fileHandleForReading.setRawMode(enable: false)
	}

	private func setup() {
		/* set file mode */
		mOutputPipe.fileHandleForReading.setRawMode(enable: true)
		mErrorPipe.fileHandleForReading.setRawMode(enable: true)

		/* Set font */
		let fstyle: CNEscapeCode = .setFontStyle(CNFont.Style.monospace.rawValue)
		let fsize:  CNEscapeCode = .setFontSize(CNFont.Size.small.rawValue)
		super.controller.execute(escapeCodes: [fstyle, fsize])

		mOutputPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			let data = hdl.availableData
			self.execute(data: data)
		}
		mErrorPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			let data = hdl.availableData
			self.execute(data: data)
		}
		super.set(editedCallback: {
			(_ ecodes: Array<CNEscapeCode>) -> Void in
			var line: String = ""
			for ecode in ecodes {
				line += ecode.encode()
			}
			self.mInputPipe.fileHandleForWriting.write(string: line)
		})
	}

	public func execute(data src: Data) {
		if let str = String.stringFromData(data: src) {
			switch CNEscapeCode.decode(string: str) {
			case .ok(let codes):
				super.controller.execute(escapeCodes: codes)
			case .error(let err):
				CNLog(logLevel: .error, message: "Failed to decode escape code: \(err.toString())")
			@unknown default:
				CNLog(logLevel: .error, message: "Failed to decode escape code: <unknown>")
			}
		} else {
			CNLog(logLevel: .error, message: "Failed to decode data")
		}
	}
}


