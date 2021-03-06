// 
//  KeyboardLayoutTests.swift
//
//  SauceTests
//  GitHub: https://github.com/clipy
//  HP: https://clipy-app.com
// 
//  Copyright © 2015-2020 Clipy Project.
//

import XCTest
import Carbon
@testable import Sauce

final class KeyboardLayoutTests: XCTestCase {

    // MARK: - Properties
    private let ABCKeyboardID = "com.apple.keylayout.ABC"
    private let japaneseKeyboardID = "com.apple.inputmethod.Kotoeri.Japanese"
    private let kotoeriKeyboardID = "com.apple.inputmethod.Kotoeri"
    private let dvorakKeyboardID = "com.apple.keylayout.Dvorak"
    private let modifierTransformer = ModifierTransformer()
    private let QWERTYVKeyCode = 9
    private let DvorakVKeyCode = 47 // swiftlint:disable:this identifier_name

    // MARK: - Tests
    func testKeyCodesForABCKeyboard() {
        let isInstalledABCKeyboard = isInstalledInputSource(id: ABCKeyboardID)
        XCTAssertTrue(installInputSource(id: ABCKeyboardID))
        XCTAssertTrue(selectInputSource(id: ABCKeyboardID))
        let keyboardLayout = KeyboardLayout()
        let vKeyCode = keyboardLayout.currentKeyCode(by: .v)
        XCTAssertEqual(vKeyCode, CGKeyCode(QWERTYVKeyCode))
        let vKey = keyboardLayout.currentKey(by: QWERTYVKeyCode)
        XCTAssertEqual(vKey, .v)
        let vCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: 0)
        XCTAssertEqual(vCharacter, "v")
        let vShiftCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: .shift))
        XCTAssertEqual(vShiftCharacter, "V")
        let vOptionCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: [.option]))
        XCTAssertEqual(vOptionCharacter, "√")
        let vShiftOptionCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: [.shift, .option]))
        XCTAssertEqual(vShiftOptionCharacter, "◊")
        guard !isInstalledABCKeyboard else { return }
        uninstallInputSource(id: ABCKeyboardID)
    }

    func testKeyCodesForDvorakKeyboard() {
        let isInstalledDvorakKeyboard = isInstalledInputSource(id: dvorakKeyboardID)
        XCTAssertTrue(installInputSource(id: dvorakKeyboardID))
        XCTAssertTrue(selectInputSource(id: dvorakKeyboardID))
        let keyboardLayout = KeyboardLayout()
        let vKeyCode = keyboardLayout.currentKeyCode(by: .v)
        XCTAssertEqual(vKeyCode, CGKeyCode(DvorakVKeyCode))
        let vKey = keyboardLayout.currentKey(by: DvorakVKeyCode)
        XCTAssertEqual(vKey, .v)
        let vCharacter = keyboardLayout.currentCharacter(by: DvorakVKeyCode, carbonModifiers: 0)
        XCTAssertEqual(vCharacter, "v")
        let vShiftCharacter = keyboardLayout.currentCharacter(by: DvorakVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: .shift))
        XCTAssertEqual(vShiftCharacter, "V")
        let vOptionCharacter = keyboardLayout.currentCharacter(by: DvorakVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: [.option]))
        XCTAssertEqual(vOptionCharacter, "√")
        let vShiftOptionCharacter = keyboardLayout.currentCharacter(by: DvorakVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: [.shift, .option]))
        XCTAssertEqual(vShiftOptionCharacter, "◊")
        guard !isInstalledDvorakKeyboard else { return }
        uninstallInputSource(id: dvorakKeyboardID)
    }

    func testKeyCodesJapanesesAndDvorakOnlyKeyboard() {
        let installedInputSources = fetchInputSource(includeAllInstalled: false)
        let isInstalledJapaneseKeyboard = isInstalledInputSource(id: japaneseKeyboardID)
        let isInstalledKotoeriKeyboard = isInstalledInputSource(id: kotoeriKeyboardID)
        let isInstalledDvorakKeyboard = isInstalledInputSource(id: dvorakKeyboardID)
        XCTAssertTrue(installInputSource(id: ABCKeyboardID))
        XCTAssertTrue(installInputSource(id: dvorakKeyboardID))
        XCTAssertTrue(installInputSource(id: kotoeriKeyboardID))
        XCTAssertTrue(installInputSource(id: japaneseKeyboardID))
        XCTAssertTrue(selectInputSource(id: ABCKeyboardID))
        XCTAssertTrue(selectInputSource(id: japaneseKeyboardID))
        XCTAssertTrue(uninstallInputSource(id: ABCKeyboardID))
        installedInputSources.filter { $0.id != japaneseKeyboardID && $0.id != dvorakKeyboardID && !$0.id.contains("Japanese") && !$0.id.contains("Kotoeri") }
            .forEach { uninstallInputSource(id: $0.id) }
        let keyboardLayout = KeyboardLayout()
        let vKeyCode = keyboardLayout.currentKeyCode(by: .v)
        XCTAssertEqual(vKeyCode, CGKeyCode(QWERTYVKeyCode))
        let vKey = keyboardLayout.currentKey(by: QWERTYVKeyCode)
        XCTAssertEqual(vKey, .v)
        let vCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: 0)
        XCTAssertEqual(vCharacter, "v")
        let vShiftCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: .shift))
        XCTAssertEqual(vShiftCharacter, "V")
        let vOptionCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: [.option]))
        XCTAssertEqual(vOptionCharacter, "√")
        let vShiftOptionCharacter = keyboardLayout.currentCharacter(by: QWERTYVKeyCode, carbonModifiers: modifierTransformer.carbonFlags(from: [.shift, .option]))
        XCTAssertEqual(vShiftOptionCharacter, "◊")
        installedInputSources.forEach { installInputSource(id: $0.id) }
        if !isInstalledJapaneseKeyboard {
            uninstallInputSource(id: japaneseKeyboardID)
        }
        if !isInstalledDvorakKeyboard {
            uninstallInputSource(id: dvorakKeyboardID)
        }
        if !isInstalledKotoeriKeyboard {
            uninstallInputSource(id: kotoeriKeyboardID)
        }
    }

    // MARK: - Util
    private func fetchInputSource(includeAllInstalled: Bool) -> [InputSource] {
        guard let sources = TISCreateInputSourceList([:] as CFDictionary, includeAllInstalled).takeUnretainedValue() as? [TISInputSource] else { return [] }
        return sources.map { InputSource(source: $0) }
    }

    private func isInstalledInputSource(id: String) -> Bool {
        return fetchInputSource(includeAllInstalled: false).contains(where: { $0.id == id })
    }

    @discardableResult
    private func installInputSource(id: String) -> Bool {
        let allInputSources = fetchInputSource(includeAllInstalled: true)
        guard let targetInputSource = allInputSources.first(where: { $0.id == id }) else { return false }
        return TISEnableInputSource(targetInputSource.source) == noErr
    }

    @discardableResult
    private func uninstallInputSource(id: String) -> Bool {
        let installedInputSources = fetchInputSource(includeAllInstalled: false)
        guard let targetInputSource = installedInputSources.first(where: { $0.id == id }) else { return false }
        return TISDisableInputSource(targetInputSource.source) == noErr
    }

    private func selectInputSource(id: String) -> Bool {
        let installedInputSources = self.fetchInputSource(includeAllInstalled: false)
        guard let targetInputSource = installedInputSources.first(where: { $0.id == id }) else { return false }
        return TISSelectInputSource(targetInputSource.source) == noErr
    }

}
