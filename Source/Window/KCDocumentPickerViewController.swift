/**
 * @file	KCDocumentPickerViewController.swift
 * @brief	Define KCDocumentPickerViewController class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

#if os(iOS)

import CoconutData
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices
import Foundation

@objc public class KCDocumentPickerViewController: UIDocumentPickerViewController, UIDocumentPickerDelegate
{
	public typealias CallbackFunction = (_ url: URL?) -> Void

	private var mParentViewController:	KCMultiViewController
	private var mCallback:			CallbackFunction?

	public init(parentViewController parent: KCMultiViewController) {
		mParentViewController	= parent
		mCallback		= nil

		var uttypes: Array<UTType> = [ UTType.folder ]
		if let pkg = UTType("com.github.steelwheels.jstools.script-package") {
			uttypes.append(pkg)
		}
		super.init(forOpeningContentTypes: uttypes, asCopy: false)

		self.delegate			= self
		self.modalPresentationStyle	= .fullScreen
		self.allowsMultipleSelection	= false

	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setCallbackFunction(callback cbfunc: @escaping CallbackFunction){
		mCallback = cbfunc
	}

	public func openPicker(URL url: URL) {
		self.directoryURL 		= url
		mParentViewController.present(self, animated: true, completion: nil)
	}

	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		CNLog(logLevel: .detail, message: "Selected")
		if let cbfunc = mCallback {
			if let url = urls.first {
				if url.startAccessingSecurityScopedResource() {
					cbfunc(url)
					url.stopAccessingSecurityScopedResource()
				} else {
					CNLog(logLevel: .error, message: "Failed to access sequrity resource", atFunction: #function, inFile: #file)
					cbfunc(nil)
				}
			} else {
				cbfunc(nil)
			}
		} else {
			CNLog(logLevel: .error, message: "No callback", atFunction: #function, inFile: #file)
		}
	}

	public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		CNLog(logLevel: .detail, message: "Canceled")
		if let cbfunc = mCallback {
			cbfunc(nil)
		} else {
			CNLog(logLevel: .error, message: "No callback", atFunction: #function, inFile: #file)
		}
	}
}

/*
@objc public class KCDocumentPickerViewController: NSObject, UIDocumentPickerDelegate
{
	public typealias CallbackFunction = (_ url: URL?) -> Void

	private var mParentViewController:	KCMultiViewController
	private var mPickerView:		UIDocumentPickerViewController?
	private var mCallback:			CallbackFunction?

	public init(parentViewController parent: KCMultiViewController) {
		mParentViewController	= parent
		mPickerView		= nil
		mCallback		= nil
	}

	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public func setCallbackFunction(callback cbfunc: @escaping CallbackFunction){
		mCallback = cbfunc
	}

	public func openPicker(URL url: URL) {
		/* Open document picker */
		let picker: UIDocumentPickerViewController
		if let p = mPickerView {
			picker = p
		} else {
			var uttypes: Array<UTType> = [ UTType.folder ]
			if let pkg = UTType("com.github.steelwheels.jstools.script-package") {
				uttypes.append(pkg)
			}
			picker = UIDocumentPickerViewController(forOpeningContentTypes: uttypes)
			mPickerView = picker
		}
		picker.delegate			= self
		picker.modalPresentationStyle	= .fullScreen
		picker.allowsMultipleSelection	= false
		picker.directoryURL 		= url
		mParentViewController.present(picker, animated: true, completion: nil)
	}

	public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		CNLog(logLevel: .detail, message: "Selected")
		if let cbfunc = mCallback {
			if let url = urls.first {
				if url.startAccessingSecurityScopedResource() {
					cbfunc(url)
					url.stopAccessingSecurityScopedResource()
				} else {
					CNLog(logLevel: .error, message: "Failed to access sequrity resource", atFunction: #function, inFile: #file)
					cbfunc(nil)
				}
			} else {
				cbfunc(nil)
			}
		} else {
			CNLog(logLevel: .error, message: "No callback", atFunction: #function, inFile: #file)
		}
	}

	public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		CNLog(logLevel: .detail, message: "Canceled")
		if let cbfunc = mCallback {
			cbfunc(nil)
		} else {
			CNLog(logLevel: .error, message: "No callback", atFunction: #function, inFile: #file)
		}
	}
}*/

#endif // os(iOS)

