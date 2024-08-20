/**
 * @file	KCLayoutChecker.swift
 * @brief	Define KCLayoutChecker class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

public class KCLayoutChecker : KCViewVisitor
{
	open override func visit(root view: KCRootView){
		let coreview: KCInterfaceView = view.getCoreView()
		coreview.accept(visitor: self)
		self.visit(coreView: view)
	}

	open override func visit(stack view: KCStackView){
		for subview in view.arrangedSubviews() {
			subview.accept(visitor: self)
		}
		self.visit(coreView: view)
	}

	open override func visit(labeledStack view: KCLabeledStackView){
		view.contentsView.accept(visitor: self)
		self.visit(coreView: view)
	}

	open override func visit(coreView view: KCInterfaceView){
		checkSize(coreView: view)
	}

	private func checkSize(coreView view: KCInterfaceView) {
		let csize = view.intrinsicContentSize
		if csize.width > view.limitSize.width {
			CNLog(logLevel: .error,
			      message: "Contents width over limit size (\(csize.width) > \(view.limitSize.width)): at \(view)",
			      atFunction: #function, inFile: #file)
		}
		if csize.height > view.limitSize.height {
			CNLog(logLevel: .error,
			      message: "Contents height over limit size (\(csize.height) > \(view.limitSize.height)): at \(view)",
			      atFunction: #function, inFile: #file)
		}
	}
}

