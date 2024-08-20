/**
 * @file	KCLayoutDeterminer.swift
 * @brief	Define KCLayoutDeterminer class
 * @par Copyright
 *   Copyright (C) 2024 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

public class KCLayoutDeterminer: KCViewVisitor
{
	open override func visit(root view: KCRootView){
		let coreview: KCInterfaceView = view.getCoreView()
		coreview.accept(visitor: self)
	}

	open override func visit(stack view: KCStackView){
		for subview in view.arrangedSubviews() {
			subview.accept(visitor: self)
		}
	}

	open override func visit(labeledStack view: KCLabeledStackView){
		for subview in view.arrangedSubviews() {
			subview.accept(visitor: self)
		}
	}

	open override func visit(console view: KCConsoleView){
		visit(textEditView: view)
	}

	open override func visit(terminal view: KCTerminalView){
		visit(textEditView: view)
	}

	private func visit(textEditView view: KCTextEdit){
		view.updateTerminalInfoByFrameSize(size: view.frame.size)
	}
}

