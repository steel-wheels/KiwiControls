/**
 * @file	KCConsoleManager.swift
 * @brief	Define KCConsoleManager class
 * @par Copyright
 *   Copyright (C) 2020 Steel Wheels Project
 */

import CoconutData
import Foundation

public class KCConsoleManager
{
	private var	mDefaultConsole:	CNFileConsole
	private var	mConsoleStack:		CNStack<CNFileConsole>

	public init(){
		mDefaultConsole		= CNFileConsole()
		mConsoleStack		= CNStack()
	}

	public var console: CNFileConsole {
		get {
			if let cons = mConsoleStack.peek() {
				return cons
			} else {
				return mDefaultConsole
			}
		}
	}

	public func push(console cons: CNFileConsole) {
		mConsoleStack.push(cons)
	}

	public func pop() -> CNFileConsole? {
		return mConsoleStack.pop()
	}
}
