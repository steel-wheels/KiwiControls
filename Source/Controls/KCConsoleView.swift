/**
 * @file	KCConsoleView.swift
 * @brief Define KCConsoleView class
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

#if os(OSX)
	import Cocoa
#else
	import UIKit
#endif
import CoconutData

open class KCConsoleView : KCTextEdit
{
	private var mOutputPipe:	Pipe
	private var mErrorPipe:		Pipe
	private var mOutputFile:	CNFile
	private var mErrorFile:		CNFile
	private var mConsole:		CNFileConsole

	public var console:		CNFileConsole { get { return mConsole }}

	#if os(OSX)
	public override init(frame : NSRect){
		mOutputPipe		= Pipe()
		mErrorPipe		= Pipe()
		mOutputFile		= mOutputPipe.fileForWriting(fileType: .standardIO)
		mErrorFile		= mErrorPipe.fileForWriting(fileType: .standardIO)
		mConsole		= CNFileConsole(input: CNStandardFiles.shared.input,
							output: mOutputFile,
							error: mErrorFile)
		super.init(frame: frame)
		setupView()
		setupFileStream()
	}
	#else
	public override init(frame: CGRect){
		mOutputPipe		= Pipe()
		mErrorPipe		= Pipe()
		mOutputFile		= mOutputPipe.fileForWriting(fileType: .standardIO)
		mErrorFile		= mErrorPipe.fileForWriting(fileType: .standardIO)
		mConsole		= CNFileConsole(input: CNStandardFiles.shared.input,
							output: mOutputFile,
							error: mErrorFile)
		super.init(frame: frame)
		setupView()
		setupFileStream()
	}
	#endif

	public required init?(coder: NSCoder) {
		mOutputPipe		= Pipe()
		mErrorPipe		= Pipe()
		mOutputFile		= mOutputPipe.fileForWriting(fileType: .standardIO)
		mErrorFile		= mOutputPipe.fileForWriting(fileType: .standardIO)
		mConsole		= CNFileConsole(input: CNStandardFiles.shared.input,
							output: mOutputFile,
							error: mErrorFile)
		super.init(coder: coder)
		setupView()
		setupFileStream()
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
		mOutputPipe.fileHandleForReading.readabilityHandler = nil
		mErrorPipe.fileHandleForReading.readabilityHandler  = nil
	}

	private func setupView() {
		/* Set font */
		let fstyle: CNEscapeCode = .setFontStyle(CNFont.Style.monospace.rawValue)
		let fsize:  CNEscapeCode = .setFontSize(CNFont.Size.small.rawValue)
		super.controller.execute(escapeCodes: [fstyle, fsize])
	}

	private func setupFileStream() {
		mOutputPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			let data = hdl.availableData
			if let str = String.stringFromData(data: data) {
				self.execute(string: str)
			}
		}
		mErrorPipe.fileHandleForReading.readabilityHandler = {
			(_ hdl: FileHandle) -> Void in
			let data = hdl.availableData
			if let str = String.stringFromData(data: data) {
				self.execute(string: str)
			}
		}
	}

	public func execute(string str: String) {
		switch CNEscapeCode.decode(string: str) {
		case .ok(let codes):
			super.controller.execute(escapeCodes: codes)
		case .error(let err):
			CNLog(logLevel: .error, message: "Failed to decode escape code: \(err.toString())")
		@unknown default:
			CNLog(logLevel: .error, message: "Failed to decode escape code: <unknown>")
		}
	}
}


