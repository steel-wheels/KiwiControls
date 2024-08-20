/**
 * @file	KCViewVisitor.swift
 * @brief	Define KCViewVisitor class
 * @par Copyright
 *   Copyright (C) 2018 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KCViewVisitor
{
	public init(){
	}

	open func visit(bitmap view: KCBitmapView){
		visit(coreView: view)
	}

	open func visit(button view: KCButton){
		visit(coreView: view)
	}

	open func visit(checkBox view: KCCheckBox){
		visit(coreView: view)
	}

	open func visit(collection view: KCCollectionView){
		visit(coreView: view)
	}

	open func visit(colorSelector view: KCColorSelector){
		visit(coreView: view)
	}

	open func visit(console view: KCConsoleView){
		visit(coreView: view)
	}

	open func visit(graphics2D view: KCGraphics2DView){
	}

	open func visit(icon view: KCIconView){
		visit(coreView: view)
	}

	open func visit(image view: KCImageView){
		visit(coreView: view)
	}

	open func visit(label view: KCLabelView){
		visit(coreView: view)
	}

	open func visit(labeledStack view: KCLabeledStackView) {
		visit(coreView: view)
	}

	open func visit(list view: KCListView){
		visit(coreView: view)
	}

	open func visit(navigationBar view: KCNavigationBar){
		visit(coreView: view)
	}

	open func visit(popupMenu view: KCPopupMenu){
		visit(coreView: view)
	}

	open func visit(radioButton view: KCRadioButton){
		visit(coreView: view)
	}

	open func visit(root view: KCRootView){
		visit(coreView: view)
	}

	open func visit(sprite view: KCSpriteView){
		visit(coreView: view)
	}

	open func visit(stack view: KCStackView){
		visit(coreView: view)
	}

	open func visit(stepper view: KCStepper){
		visit(coreView: view)
	}

	open func visit(table view: KCTableView){
		visit(coreView: view)
	}

	open func visit(terminal view: KCTerminalView){
		visit(coreView: view)
	}

	open func visit(textEdit view: KCTextEdit){
		visit(coreView: view)
	}

	open func visit(textField view: KCTextField){
		visit(coreView: view)
	}

	open func visit(vectorGraphics view: KCVectorGraphics){
	}

	open func visit(coreView view: KCInterfaceView){
	}
}

