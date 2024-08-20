/**
 * @file	KCFirstResponderDecider.swift
 * @brief	Define KCFirstResponderDecider class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

#if os(OSX)

import CoconutData
import AppKit
import Foundation

/* Make first responder
 * reference: https://stackoverflow.com/questions/7263482/problems-setting-firstresponder-in-cocoa-mac-osx
 */
public class KCFirstResponderDecider: KCViewVisitor
{
	private var mWindow:		KCWindow
	private var mDidDecided:	Bool

	public init(window win: KCWindow){
		mWindow		= win
		mDidDecided	= false
	}

	public func decideFirstResponder(rootView view: KCRootView) -> Bool {
		view.accept(visitor: self)
		return mDidDecided
	}

	open override func visit(root view: KCRootView){
		let coreview: KCInterfaceView = view.getCoreView()
		coreview.accept(visitor: self)
	}

	open override func visit(bitmap view: KCBitmapView){
		decide(forView: view)
	}

	open override func visit(button view: KCButton){
		decide(forView: view)
	}

	open override func visit(checkBox view: KCCheckBox){
		decide(forView: view)
	}

	open override func visit(collection view: KCCollectionView){
		decide(forView: view)
	}

	open override func visit(colorSelector view: KCColorSelector){
		decide(forView: view)
	}

	open override func visit(console view: KCConsoleView){
		decide(forView: view)
	}

	open override func visit(graphics2D view: KCGraphics2DView){
		decide(forView: view)
	}

	open override func visit(icon view: KCIconView){
		decide(forView: view)
	}

	open override func visit(image view: KCImageView){
		decide(forView: view)
	}

	open override func visit(label view: KCLabelView){
		decide(forView: view)
	}

	open override func visit(labeledStack view: KCLabeledStackView) {
		view.contentsView.accept(visitor: self)
	}

	open override func visit(navigationBar view: KCNavigationBar){
		decide(forView: view)
	}

	open override func visit(popupMenu view: KCPopupMenu){
		decide(forView: view)
	}

	open override func visit(radioButton view: KCRadioButton){
		decide(forView: view)
	}

	open override func visit(sprite view: KCSpriteView){
		decide(forView: view)
	}

	open override func visit(stack view: KCStackView){
		for subview in view.arrangedSubviews() {
			if mDidDecided {
				break
			}
			subview.accept(visitor: self)
		}
	}

	open override func visit(stepper view: KCStepper){
		decide(forView: view)
	}

	open override func visit(table view: KCTableView){
		decide(forView: view)
	}

	open override func visit(terminal view: KCTerminalView){
		decide(forView: view)
	}

	open override func visit(textEdit view: KCTextEdit){
		decide(forView: view)
	}

	open override func visit(textField view: KCTextField){
		decide(forView: view)
	}

	open override func visit(vectorGraphics view: KCVectorGraphics){
		if view.acceptsFirstResponder {
			mWindow.makeFirstResponder(view)
			mDidDecided = true
		}
	}

	open override func visit(coreView view: KCInterfaceView){
		/* Nothing have to do */
	}

	private func decide(forView view: KCInterfaceView) {
		if view.isVisible && view.acceptsFirstResponder {
			mWindow.makeFirstResponder(view)
			mDidDecided = true
		}
	}
}

#endif // os(OSX)

