//
//  Config.swift
//  RESET
//
//  Created by Wangyiwei on 2021/5/20.
//

import Foundation
import SwiftUI

let defs = UserDefaults.standard
let ver = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String? ?? "0"
let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String? ?? "0"

let images: [String] = [
    "trash",
    "folder.badge.gear",
    "bookmark",
    "heart",
    "bolt",
    "text.bubble",
    "paintbrush",
    "map",
    "cpu",
]

let colors: [Color] = [
    .gray, .yellow, .red
]

let texts: [String] = [
    "Fresh", "Attention", "Warning"
]

let scalar: [Double] = [
    3600, 3600 * 24, 3600 * 24 * 7, 3600 * 24 * 30
]

let timeScales: [String] = [
    "Hour", "Day", "Weak", "Month"
    //"时", "天", "周", "月"
]

let welcomeMsg = "- The Reset app tracks your repeated items.\n- Tap reset when you have done something."

let userColors: [UIColor] = [
    .systemBlue, .systemIndigo, .systemPurple, .systemPink, .systemGreen, .systemOrange, .systemGray2
]
