/**
 * @file	KCLayoutInvalidator.swift
 * @brief	Define KCLayoutInvalidator class
 * @par Copyright
 *   Copyright (C) 2021 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KCLayoutInvalidator: KCViewVisitor
{
	private var mTargetView: 	KCView
	private var mVisitResult:	Bool


	public init(target view: KCView){
		mTargetView  = view
		mVisitResult = false
	}

	private func doInvalidate(view v: KCView, doInvalidate doinv: Bool){
		if doinv {
			v.invalidateIntrinsicContentSize()
			v.requireLayout()
		}
	}

	private func checkTarget(view v: KCView) -> Bool {
		var result: Bool = false
		if v == mTargetView {
			result = true
		} else if let iv = v as? KCInterfaceView {
			if let cv: KCView = iv.getCoreView() {
				if cv == mTargetView {
					result = true
				}
			}
		}
		return result
	}

	public override func visit(root view: KCRootView){
		let doinv0: Bool
		if let core: KCView = view.getCoreView() {
			core.accept(visitor: self)
			doinv0 = mVisitResult
		} else {
			doinv0 = false
		}
		let doinv1 = doinv0 || checkTarget(view: view)
		doInvalidate(view: view, doInvalidate: doinv1)
		mVisitResult = doinv1
	}

	public override func visit(stack view: KCStackView){
		var doinv: Bool = false
		for subview in view.arrangedSubviews() {
			subview.accept(visitor: self)
			if mVisitResult {
				doinv = true
			}
		}
		doinv = doinv || checkTarget(view: view)
		doInvalidate(view: view, doInvalidate: doinv)
		mVisitResult = doinv
	}

	public override func visit(labeledStack view: KCLabeledStackView) {
		view.contentsView.accept(visitor: self)
		let doinv1 = mVisitResult
		let doinv2 = (view.labelView == mTargetView)
		let doinv3 = checkTarget(view: view)
		let doinv  = doinv1 || doinv2 || doinv3
		if doinv {
			view.labelView.invalidateIntrinsicContentSize()
		}
		doInvalidate(view: view, doInvalidate: doinv)
		mVisitResult = doinv
	}

	public override func visit(coreView view: KCInterfaceView){
		let doinv = checkTarget(view: view)
		doInvalidate(view: view, doInvalidate: doinv)
		mVisitResult = doinv
	}
}

