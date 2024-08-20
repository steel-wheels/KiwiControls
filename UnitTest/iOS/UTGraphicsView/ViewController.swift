/**
 * @file	ViewController.swift
 * @brief	View controller for UTGraphicsView
 * @par Copyright
 *   Copyright (C) 2017 Steel Wheels Project
 */

import UIKit
import KiwiGraphics
import KiwiControls

private class UTVertexDrawer
{
	private var mEclipse:	KGEclipse
	private var mGradient:	CGGradient

	public init(bounds b: CGRect, color c: CGColor){
		let center = b.center
		let radius = min(b.size.width, b.size.height)/2.0
		mEclipse  = KGEclipse(center: center, innerRadius: radius*0.5, outerRadius: radius)
		mGradient = KGGradientTable.sharedGradientTable.gradient(forColor: c)
	}

	public func drawContent(context ctxt:CGContext){
		ctxt.setStrokeColor(KCColorTable.white.cgColor)
		ctxt.draw(eclipse: mEclipse, withGradient: mGradient)
	}
}

class ViewController: UIViewController
{

	@IBOutlet weak var mGraphicsView: KCLayerView!
	@IBOutlet weak var mSymbol0View: KCLayerView!
	@IBOutlet weak var mSymbol1View: KCLayerView!
	@IBOutlet weak var mSymbol2View: KCLayerView!
	@IBOutlet weak var mSymbol3View: KCLayerView!
	@IBOutlet weak var mSelectionView: KCLayerView!

	private var mSelectionLayer: KCSelectionLayer? = nil

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	public override func viewDidLayoutSubviews() {
		setupGraphicsView()
		setupSymbolViews()
		setupSelectionView()
		setupTimer()
	}

	private func setupGraphicsView()
	{
		Swift.print("View did layout")
		let bounds     = mGraphicsView.bounds

		/* Background layer */
		let background = KCBackgroundLayer(frame: bounds, color: KCColorTable.black.cgColor)
		mGraphicsView.rootLayer.addSublayer(background)

		/* Image drawer */
		let origin = KGOrigin(origin: CGPoint.zero, size: bounds.size, frame: bounds)
		let contentrect = CGRect(origin: origin, size: bounds.size)
		let drawer = KCImageDrawerLayer(frame: bounds, contentRect: contentrect)
		drawer.imageDrawer = {
			(context: CGContext, bounds: CGRect) -> Void in
			Swift.print("Graphics Layer: draw in content:\(contentrect.description) bounds:\(bounds.description)")
			let vertex = UTVertexDrawer(bounds: bounds, color: KCColorTable.blue.cgColor)
			vertex.drawContent(context: context)
		}
		background.addSublayer(drawer)

		/* Repetitive layer */
		let elmsize = CGSize(width: bounds.size.width/10.0, height: bounds.size.height/10.0)
		var elmorigin : Array<CGPoint> = []
		for i in 0..<10 {
			let origin = CGPoint(x: bounds.size.width/10.0*CGFloat(i), y:bounds.size.height/10.0*CGFloat(i))
			elmorigin.append(origin)
		}
		let repetitive = KCRepetitiveLayer(frame: bounds, elementSize: elmsize, elementOrigins: elmorigin, elementDrawer: {
			(context: CGContext, bounds: CGRect) -> Void in
			Swift.print("Graphics Layer: draw in bounds:\(bounds.description)")
			let vertex = UTVertexDrawer(bounds: bounds, color: KCColorTable.yellow.cgColor)
			vertex.drawContent(context: context)
		})
		drawer.addSublayer(repetitive)

		background.doUpdate()
	}

	private func setupSymbolViews()
	{
		for symid in 0..<4 {
			let view: KCLayerView
			switch symid {
			case 0:		view = mSymbol0View
			case 1:		view = mSymbol1View
			case 2:		view = mSymbol2View
			default:	view = mSymbol3View
			}

			let bounds     = view.bounds
			let background = KCBackgroundLayer(frame: bounds, color: KCColorTable.black.cgColor)

			view.rootLayer.addSublayer(background)
			let symbounds = view.bounds
			let drawrect = CGRect(origin: CGPoint.zero, size: symbounds.size)
			let symlayer = UTAllocateSymbol(symbolId: symid, frame: symbounds, contentRect: drawrect)
			background.addSublayer(symlayer)

			background.doUpdate()
		}
	}

	private func setupSelectionView()
	{
		let selbounds	= mSelectionView.bounds

		let background = KCBackgroundLayer(frame: selbounds, color: KCColorTable.black.cgColor)
		mSelectionView.rootLayer.addSublayer(background)

		let sellayer	= KCSelectionLayer(frame: selbounds)
		for i in 0...3 {
			let drawrect = CGRect(origin: CGPoint.zero, size: selbounds.size)
			let symbol = UTAllocateSymbol(symbolId: i, frame: selbounds, contentRect: drawrect)
			sellayer.addSublayer(symbol)
		}
		sellayer.visibleIndex = 0
		background.addSublayer(sellayer)
		mSelectionLayer = sellayer

		background.doUpdate()
	}

	public func setupTimer(){
		let timer = KCTimer()
		timer.addUpdateCallback(interval: 0.0, callback: {
			(time:TimeInterval) -> Void in
			if let selection = self.mSelectionLayer {
				if selection.visibleIndex == KCSelectionLayer.None {
					selection.visibleIndex = 0
				} else {
					let count = selection.count - 1
					let next  = (selection.visibleIndex + 1) % count
					selection.visibleIndex = next
				}
				selection.doUpdate()
			}
		})
		timer.start(startValue: 0.0, stopValue: 10.0, stepValue: 0.4)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
}


