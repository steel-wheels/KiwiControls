/**
 * @file	KCDistributionDecider.swift
 * @brief	Define KCDistributionDecider class
 * @par Copyright
 *   Copyright (C) 2018-2021 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

public class KCDistributionDecider: KCViewVisitor
{
	open override func visit(root view: KCRootView){
		let coreview: KCInterfaceView = view.getCoreView()
		coreview.accept(visitor: self)
	}

	open override func visit(stack view: KCStackView){
		/* First, resize members */
		for subview in view.arrangedSubviews() {
			subview.accept(visitor: self)
		}
		/* Resize it self */
		decideDistribution(stackView: view)
	}

	open override func visit(labeledStack view: KCLabeledStackView){
		view.contentsView.accept(visitor: self)
	}

	open override func visit(coreView view: KCInterfaceView){
		/* Do nothing */
	}

	private func decideDistribution(stackView view: KCStackView){
		let dist: CNDistribution
		let subviews = view.arrangedSubviews()
		if subviews.count < 2 {
			dist = .fill
		} else {
			var issame = true
			for i in 1..<subviews.count {
				if !KCIsSameView(view0: subviews[0], view1: subviews[i]){
					issame = false
					break
				}
			}
			dist = issame ? .fillEqually : .fill
		}
		view.distribution = dist
	}
}

