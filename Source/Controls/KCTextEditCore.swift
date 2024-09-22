/**
 * @file	KCTextEdit.swift
 * @brief	Define KCTextEdit class
 * @par Copyright
 *   Copyright (C) 2023-2024 Steel Wheels Project
 */

#if os(OSX)
import Cocoa
#else
import UIKit
#endif
import CoconutData

open class KCTextEditCore : KCCoreView, KCTextViewDelegate, NSTextStorageDelegate, CNTerminalController
{
	#if os(OSX)
	@IBOutlet var		mTextView:	NSTextView!
	@IBOutlet weak var	mScrollView:	NSScrollView!
	#else
	@IBOutlet weak var	mTextView:	UITextView!
	#endif

	public typealias EditedCallback = (_ ecodes: Array<CNEscapeCode>) -> Void

	public struct TerminalSize {
		public var width:	Int
		public var height:	Int
		public init(width: Int, height: Int) {
			self.width  = width
			self.height = height
		}
	}

	private var mTerminalSize		= TerminalSize(width: 80, height: 20)
	private var mTerminalInfo 		= CNTerminalInfo(width: 80, height: 20)
	private var mIsAlternativeScreen	= false
	private var mStorage			= NSTextStorage()
	private var mFontStyle			: CNFont.Style = .normal
	private var mFontSize			: CNFont.Size  = .regular
	private var mIndex			: Int = 0
	private var mSavedIndex			: Array<Int> = [0, 0]
	private var mHasInsetionPoint		: Bool = false
	private var mEditedCallback		: EditedCallback? = nil
	private var mTextEditListners		: Array<CNObserverDictionary.ListnerHolder> = []

	public func setup(frame frm: CGRect){
		#if os(OSX)
		super.setup(isSingleView: true, coreView: mScrollView)
		KCView.setAutolayoutMode(views: [self, mScrollView])
		#else
		super.setup(isSingleView: true, coreView: mTextView)
		KCView.setAutolayoutMode(views: [self, mTextView])
		#endif

		/* Set default font */
		setFont(style: mFontStyle, size: mFontSize)

		/* Set delegate */
		mTextView.delegate = self
		#if os(OSX)
			setupForMacOS()
		#else
			setupForiOS()
		#endif

		/* Set initial terminal info */
		updateTerminalInfoByFrameSize(size: mTextView.frame.size)

		/* Setup observers */
		let tpref = CNPreference.shared.terminalPreference
		mTextEditListners.append(
			tpref.addObsertverForWidth(callback: {
				(_ width: Int) -> Void in
				self.updateTerminal(width: width, height: nil, fontStyle: nil, fontSize: nil)
			})
		)
		mTextEditListners.append(
			tpref.addObsertverForHeight(callback: {
				(_ height: Int) -> Void in
				self.updateTerminal(width: nil, height: height, fontStyle: nil, fontSize: nil)
			})
		)
		mTextEditListners.append(
			tpref.addObsertverForFontStyle(callback: {
				(_ fstyle: CNFont.Style) -> Void in
				self.updateTerminal(width: nil, height: nil, fontStyle: fstyle, fontSize: nil)
			})
		)
		mTextEditListners.append(
			tpref.addObsertverForFontStyle(callback: {
				(_ fstyle: CNFont.Style) -> Void in
				self.updateTerminal(width: nil, height: nil, fontStyle: fstyle, fontSize: nil)
			})
		)
	}

	deinit {
		for listner in mTextEditListners {
			let spref = CNPreference.shared.systemPreference
			spref.removeObserver(listnerHolder: listner)
		}
	}

	#if os(OSX)
	private func setupForMacOS() {
		mStorage = NSTextStorage()

		let layoutManager = NSLayoutManager()
		mStorage.addLayoutManager(layoutManager)

		if let container = mTextView.textContainer {
			layoutManager.addTextContainer(container)
		} else {
			NSLog("No text container")
		}

		/* https://stackoverflow.com/questions/58426739/nstextview-scrolling */
		mScrollView.translatesAutoresizingMaskIntoConstraints = false
		mScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
		mScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
		mScrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
		mScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
	}
	#endif

	#if os(iOS)
	private func setupForiOS() {
		mStorage = mTextView.textStorage
	}
	#endif

	public func updateAppearance() {
		let vpref = CNPreference.shared.viewPreference
                let fgcolor = vpref.terminalForegroundColor()
		let bgcolor = vpref.terminalBackgroundColor()
		self.pExecute(escapeCode: .foregroundColor(fgcolor))
		self.pExecute(escapeCode: .backgroundColor(bgcolor))

		/* Replace all background color */
		mStorage.setOverallBackgroundColor(color: bgcolor)
	}

	public func updateTerminal(width wval: Int?, height hval: Int?, fontStyle fstyle: CNFont.Style?, fontSize fsize: CNFont.Size?) {
		if let width = wval {
			if mTerminalInfo.width != width {
				execute(escapeCode: .screenSize(width, mTerminalInfo.height))
			}
		}
		if let height = hval {
			if mTerminalInfo.height != height {
				execute(escapeCode: .screenSize(mTerminalInfo.width, height))
			}
		}
		if let style = fstyle {
			if mFontStyle != style {
				execute(escapeCode: .setFontStyle(style.rawValue))
			}
		}
		if let size = fsize {
			if mFontSize != size {
				execute(escapeCode: .setFontSize(size.rawValue))
			}
		}
	}

	public func updateTerminalInfoByFrameSize(size sz: CGSize) {
		let fsize = fontSize(font: self.font)
		mTerminalInfo.width  = Int(sz.width  / fsize.width)
		mTerminalInfo.height = Int(sz.height / fsize.height)
	}

	public var terminalInfo: CNTerminalInfo { get {
		return mTerminalInfo
	}}

	public var isEditable: Bool {
		get { return mTextView.isEditable }
		set(newval) { mTextView.isEditable = newval }
	}

	public var hasInsetionPoint: Bool {
		get         { return mHasInsetionPoint		}
		set(newval) { mHasInsetionPoint = newval	}
	}

	public func set(editedCallback cbfunc: @escaping EditedCallback) {
		mEditedCallback = cbfunc
	}

	public var font: CNFont { get {
		if let font = mTextView.font {
			return font
		} else {
			CNLog(logLevel: .error, message: "Can not happen", atFunction: #function, inFile: #file)
			return CNFont.systemFont(ofSize: CNFont.systemFontSize)
		}
	}}

	public func execute(escapeCode ecode: CNEscapeCode) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.mStorage.beginEditing()
			self.pExecute(escapeCode: ecode)
			self.mStorage.endEditing()

			/* Update selected range */
			self.updateSelection()
		})
	}

	public func execute(escapeCodes ecodes: Array<CNEscapeCode>) {
		CNExecuteInMainThread(doSync: false, execute: {
			() -> Void in
			self.mStorage.beginEditing()
			for ecode in ecodes {
				self.pExecute(escapeCode: ecode)
			}
			self.mStorage.endEditing()

			/* Update selected range */
			self.updateSelection()
		})
	}

	private func pExecute(escapeCode code: CNEscapeCode) {
		var didchanged = false
		switch code {
		case .string(let str):
			mIndex = write(string: str, currentIndex: mIndex)
			didchanged = true
		case .eot:
			break // ignore this command
		case .newline:
			mIndex = append(string: "\n", currentIndex: mIndex)
			didchanged = true
		case .tab:
			mIndex = append(string: "\t", currentIndex: mIndex)
			didchanged = true
		case .backspace:
			mIndex = mStorage.moveCursorBackward(from: mIndex, number: 1)
		case .delete:
			mIndex = mStorage.deleteBackwardCharacters(from: mIndex, number: 1)
			didchanged = true
		case .insertSpace(let num):
			let spaces = String(repeating: " ", count: num)
			mIndex = mStorage.insert(string: spaces, at: mIndex, font: self.font, terminalInfo: mTerminalInfo)
			didchanged = true
		case .cursorUp(let num):
			mIndex = mStorage.moveCursorUpOrDown(from: mIndex, doUp: true, number: num)
		case .cursorDown(let num):
			mIndex = mStorage.moveCursorUpOrDown(from: mIndex, doUp: false, number: num)
		case .cursorForward(let colnum):
			mIndex = mStorage.moveCursorForward(from: mIndex, number: colnum)
		case .cursorBackward(let colnum):
			mIndex = mStorage.moveCursorBackward(from: mIndex, number: colnum)
		case .cursorNextLine(let rownum):
			mIndex = cursorNextLine(rowNum: rownum, currentIndex: mIndex)
		case .cursorPreviousLine(let rownum):
			mIndex = cursorPreviousLine(rowNum: rownum, currentIndex: mIndex)
		case .cursorHolizontalAbsolute(let dpos):
			mIndex = cursorHorizontalAbsolute(deltaPosition: dpos, currentIndex: mIndex)
		case .cursorVisible(let flag):
			self.hasInsetionPoint = flag
		case .saveCursorPosition:
			if mTerminalInfo.isAlternative {
				mSavedIndex[1] = mIndex
			} else {
				mSavedIndex[0] = mIndex
			}
		case .restoreCursorPosition:
			mIndex = restoreCurrentPosition()
		case .cursorPosition(let row, let col):
			mIndex = setCursorPosition(rowIndex: row, columnIndex: col, currentIndex: mIndex)
		case .eraceFromCursorToEnd:
			mIndex = eraceFromCursorToTextEnd(currentIndex: mIndex)
			didchanged = true
		case .eraceFromCursorToBegin:
			mIndex = eraceFromCursorToTextStart(currentIndex: mIndex)
			didchanged = true
		case .eraceFromCursorToRight:
			mIndex = eraceFromCursorToLineEnd(currentIndex: mIndex)
			didchanged = true
		case .eraceFromCursorToLeft:
			mIndex = eraceFromCursorToLineStart(currentIndex: mIndex)
			didchanged = true
		case .eraceEntireBuffer:
			mIndex = eraceAll()
			didchanged = true
		case .eraceEntireLine:
			mIndex = eraceEntireLine(currentIndex: mIndex)
			didchanged = true
		case .scrollUp(let line):
			scrollUp(lineCount: line)
		case .scrollDown(let line):
			scrollDown(lineCount: line)
		case .resetAll:
			mIndex = resetAll()
		case .resetCharacterAttribute:
			mTerminalInfo.reset()
		case .boldCharacter(let flag):
			mTerminalInfo.doBold = flag
		case .underlineCharacter(let flag):
			mTerminalInfo.doUnderline = flag
		case .blinkCharacter(let flag):
			mTerminalInfo.doBlink = flag
		case .reverseCharacter(let flag):
			mTerminalInfo.doReverse = flag
		case .foregroundColor(let col):
			mTerminalInfo.foregroundColor = col
		case .defaultForegroundColor:
			mTerminalInfo.foregroundColor = mTerminalInfo.defaultForegroundColor
		case .backgroundColor(let col):
			mTerminalInfo.backgroundColor = col
		case .defaultBackgroundColor:
			mTerminalInfo.backgroundColor = mTerminalInfo.defaultBackgroundColor
		case .requestScreenSize:
			break
		case .screenSize(let width, let height):
			setScreenSize(width: width, height: height)
		case .selectAltScreen(let flag):
			CNLog(logLevel: .error, message: "Unsupported sequence: selectAltScreen(\(flag)", atFunction: #function, inFile: #file)
		case .setFontStyle(let styleno):
			if let style = CNFont.Style(rawValue: styleno) {
				mFontStyle = style
				setFont(style: mFontStyle, size: mFontSize)
			} else {
				CNLog(logLevel: .error, message: "Unknown font style", atFunction: #function, inFile: #file)
			}
		case .setFontSize(let sizeno):
			if let size = CNFont.Size(rawValue: sizeno) {
				mFontSize = size
				setFont(style: mFontStyle, size: mFontSize)
			} else {
				CNLog(logLevel: .error, message: "Unknown font style", atFunction: #function, inFile: #file)
			}
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown code", atFunction: #function, inFile: #file)
		}
		if didchanged {
			mTextView.invalidateIntrinsicContentSize()
		}
	}

	private func updateSelection() {
		/* Update selected range */
		let range = NSRange(location: self.mIndex, length: 0)
		self.setSelectedRange(range: range)
		self.mTextView.scrollRangeToVisible(range)
	}

	public func screenSize() -> (Int, Int) {
		return (mTerminalInfo.width, mTerminalInfo.height)
	}

	private func write(string str: String, currentIndex curidx: Int) -> Int {
		return mStorage.write(string: str, at: curidx, font: self.font, terminalInfo: mTerminalInfo)
	}

	private func append(string str: String, currentIndex curidx: Int) -> Int {
		return mStorage.append(string: str, font: self.font, terminalInfo: self.mTerminalInfo)
	}

	private func cursorNextLine(rowNum rownum: Int, currentIndex curidx: Int) -> Int {
		let (nextidx, donewline) = mStorage.moveCursorToNextLineStart(from: curidx, number: rownum)
		let newidx: Int
		if donewline {
			if !mIsAlternativeScreen {
				newidx = append(string: "\n", currentIndex: nextidx)
			} else {
				newidx = nextidx
			}
		} else {
			newidx = nextidx
		}
		return newidx
	}

	private func cursorPreviousLine(rowNum rownum: Int, currentIndex curidx: Int) -> Int {
		return  mStorage.moveCursorToPreviousLineStart(from: curidx, number: rownum)
	}

	private func cursorHorizontalAbsolute(deltaPosition pos: Int, currentIndex curidx: Int) -> Int {
		let newidx: Int
		if pos >= 1 {
			newidx = mStorage.moveCursorTo(from: curidx, x: pos-1)
		} else {
			CNLog(logLevel: .error, message: "cursorHolizontalAbsolute: Underflow", atFunction: #function, inFile: #file)
			newidx = curidx
		}
		return newidx
	}

	private func restoreCurrentPosition() -> Int {
		let newidx = mTerminalInfo.isAlternative ? mSavedIndex[1] : mSavedIndex[0]
		return adjustIndex(currentIndex: newidx)
	}

	private func setCursorPosition(rowIndex row: Int, columnIndex col: Int, currentIndex curidx: Int) -> Int {
		let newidx: Int
		if row>=1 && col>=1 && row <= mTerminalInfo.height && col <= mTerminalInfo.width {
			if mTerminalInfo.isAlternative {
				newidx = ((mTerminalInfo.width + 1) * (row - 1)) + (col - 1)
			} else {
				newidx = mStorage.moveCursorTo(x: col-1, y: row-1)
			}
		} else {
			CNLog(logLevel: .error, message: "cursorPosition: Underflow", atFunction: #function, inFile: #file)
			newidx = curidx
		}
		return adjustIndex(currentIndex: newidx)
	}

	private func adjustIndex(currentIndex curidx: Int) -> Int {
		let str     = mStorage.string
		let endidx  = str.distance(from: str.startIndex, to: str.endIndex)
		return min(curidx, endidx)
	}

	private func eraceFromCursorToLineEnd(currentIndex curidx: Int) -> Int {
		return mStorage.deleteFromCursorToLineEnd(from: curidx)
	}

	private func eraceFromCursorToTextEnd(currentIndex curidx: Int) -> Int {
		return mStorage.deleteFromCursorToTextEnd(from: curidx)
	}

	private func eraceFromCursorToLineStart(currentIndex curidx: Int) -> Int {
		return mStorage.deleteFromCursorToLineStart(from: curidx)
	}

	private func eraceFromCursorToTextStart(currentIndex curidx: Int) -> Int {
		return mStorage.deleteFromCursorToTextStart(from: curidx)
	}

	private func eraceEntireLine(currentIndex curidx: Int) -> Int {
		return mStorage.deleteEntireLine(from: curidx)
	}

	private func eraceAll() -> Int {
		mStorage.clear(font: self.font, terminalInfo: mTerminalInfo)
		return 0
	}

	private func scrollUp(lineCount lcnt: Int) {
		let idx = mStorage.moveCursorToPreviousLineStart(from: mIndex, number: lcnt)
		scrollTo(index: idx)
	}

	private func scrollDown(lineCount lcnt: Int) {
		let (idx, _) = mStorage.moveCursorToNextLineStart(from: mIndex, number: lcnt)
		scrollTo(index: idx)
	}

	private func scrollTo(index idx: Int) {
		let target = NSRange(location: 0, length: idx)
		mTextView.scrollRangeToVisible(target)
	}

	private func resetAll() -> Int {
		mTerminalInfo.reset()
		return eraceAll()
	}

	private func setScreenSize(width w: Int, height h: Int) {
		guard mTerminalSize.width != w || mTerminalSize.height != h else {
			return // Needless to update
		}

		mTerminalSize.width  = w
		mTerminalSize.height = h

		self.invalidateIntrinsicContentSize()
		self.requireLayout()
	}

	private func setFont(style stl: CNFont.Style, size sz: CNFont.Size) {
		switch stl {
		case .normal:
			mTextView.font = CNFont.systemFont(ofSize: sz.toSize())
		case .monospace:
			mTextView.font = CNFont.monospacedSystemFont(ofSize: sz.toSize(), weight: CNFont.Weight.regular)
		@unknown default:
			CNLog(logLevel: .error, message: "Unknown font style", atFunction: #function, inFile: #file)
		}
	}

	#if os(OSX)
	public override var acceptsFirstResponder: Bool { get {
		return mTextView.acceptsFirstResponder
	}}
	#endif

	public override func becomeFirstResponder() -> Bool {
		return mTextView.becomeFirstResponder()
	}

	#if os(OSX)
	public func textView(_ textView: NSTextView, shouldChangeTextIn range: NSRange, replacementString: String?) -> Bool {
		if let str = replacementString {
			shouldChangeText(in: range, replacementString: str)
		}
		return false
	}
	#else
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		shouldChangeText(in: range, replacementString: text)
		return false
	}
	#endif

	private func shouldChangeText(in range: NSRange, replacementString str: String) {
		var ecodes: Array<CNEscapeCode> = []
		if range.location != mIndex {
			let newloc = range.location
			if newloc > mIndex {
				ecodes.append(.cursorForward(newloc - mIndex))
			} else {
				ecodes.append(.cursorBackward(mIndex - newloc))
			}
		}
		if range.length > 0 {
			let len = range.length
			ecodes.append(.cursorForward(len))
			for _ in 0..<len {
				ecodes.append(.delete)
			}
		}
		if !str.isEmpty {
			ecodes.append(.string(str))
		}

		if let cbfunc = mEditedCallback {
			if ecodes.count > 0 {
				cbfunc(ecodes)
			}
		}
	}

	/* Delegate of text view */
	#if os(OSX)
	public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		var result = false
		if let keybind = CNKeyBinding.decode(selectorName: commandSelector.description) {
			if let ecodes = keybind.toEscapeCode() {
				if let cbfunc = mEditedCallback {
					if ecodes.count > 0 {
						cbfunc(ecodes)
						result = true // the dommand is processed by this function
					}
				}
			}
		}
		return result
	}
	#endif

	open override var intrinsicContentSize: CGSize { get {
	    return CGSize.minSize(contentsSize(), self.limitSize)
	}}

	#if os(OSX)
        open override var fittingSize: CGSize { get {
                return contentsSize()
        }}
	#else
	open override func sizeThatFits(_ size: CGSize) -> CGSize {
		return adjustContentsSize(size: size)
	}
	#endif

	public override func contentsSize() -> CGSize {
		let fsize = fontSize(font: self.font)
		let width  = CGFloat(mTerminalSize.width)  * fsize.width
		let height = CGFloat(mTerminalSize.height) * fsize.height
		let scroll = scrollBarWidth()
		let tsize  = CGSize(width: width + scroll, height: height)
		return CGSize.minSize(tsize, self.limitSize)
	}

	public override func adjustContentsSize(size sz: CGSize) -> CGSize {
	    let cursize = self.contentsSize()
	    if cursize.width <= sz.width && cursize.height <= sz.height {
            return sz
	    } else {
            CNLog(logLevel: .error, message: "Size underflow", atFunction: #function, inFile: #file)
            return cursize
	    }
	}

	public override func setFrameSize(_ newsize: CGSize) {
		super.setFrameSize(newsize)
		updateTerminalInfoByFrameSize(size: newsize)
	}

	private func scrollBarWidth() -> CGFloat {
		#if os(OSX)
			if let scrl = mScrollView.verticalScroller {
				return scrl.frame.size.width
			} else {
				return 0.0
			}
		#else
			return 0.0
		#endif
	}

	private func setSelectedRange(range rng: NSRange){
		#if os(OSX)
			mTextView.setSelectedRange(rng)
		#else
			mTextView.selectedRange = rng
		#endif
	}
}

