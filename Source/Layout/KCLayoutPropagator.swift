/**
 * @file	KCLayoutPropagator.swift
 * @brief	Define KCLayoutPropagator class
 * @par Copyright
 *   Copyright (C) 2022 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

public class KCLayoutPropagator : KCViewVisitor
{
	private var mLimitSize: CGSize

	public init(limitSize sz: CGSize) {
		mLimitSize = sz
	}

	open override func visit(root view: KCRootView){
		let coreview: KCInterfaceView = view.getCoreView()
		coreview.accept(visitor: self)
		#if os(iOS)
			self.visit(coreView: view)
		#endif
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
		view.setLimitSize(size: mLimitSize)
	}
}

