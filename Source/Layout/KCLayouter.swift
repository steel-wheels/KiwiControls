/**
 * @file	KCLayouter.swift
 * @brief	Define KCLayouter class
 * @par Copyright
 *   Copyright (C) 2015-2022 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KCLayouter
{
	public init(){
	}

	public func preLayout(rootView view: KCRootView, maxSize maxsz: CGSize){
		CNLog(logLevel: .detail, message: "[Layout] Preprocessor")
		let propagator = KCLayoutPropagator(limitSize: maxsz)
		view.accept(visitor: propagator)

#if true
		CNLog(logLevel: .detail, message: "[Layout] Adjust size ")
		let adjsize = KCLayoutAdjuster(maxSize: maxsz)
		view.accept(visitor: adjsize)
#endif

		CNLog(logLevel: .detail, message: "[Layout] Adjust expandability")
		let adjuster = KCExpansionAdjuster()
		view.accept(visitor: adjuster)

		CNLog(logLevel: .detail, message: "[Layout] Decide distribution")
		let distdecider = KCDistributionDecider()
		view.accept(visitor: distdecider)
	}

	public func postLayout(rootView view: KCRootView, maxSize maxsz: CGSize){
#if os(iOS)
		CNLog(logLevel: .detail, message: "[Layout] Update window size")
		view.setFrameSize(maxsz)
#endif
		CNLog(logLevel: .detail, message: "[Layout] Determine the size")
		let determ = KCLayoutDeterminer()
		view.accept(visitor: determ)

		CNLog(logLevel: .detail, message: "[Layout] Check layout")
		let checker = KCLayoutChecker()
		view.accept(visitor: checker)
	}
}

