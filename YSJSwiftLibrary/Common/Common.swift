//
//  Common.swift
//  YSJSwiftLibrary
//
//  Created by ysj on 2017/4/27.
//  Copyright © 2017年 ysj. All rights reserved.
//

import Foundation
import UIKit

public let WidthScreen: CGFloat = UIScreen.main.bounds.size.width
public let HeightScreen: CGFloat = UIScreen.main.bounds.size.height
public let HeightNavBar: CGFloat = 44
public let HeightSystemStatus: CGFloat = 20
public let HeightTabBar: CGFloat = 49

private func adjustValue(_ value: CGFloat) -> CGFloat{
    var result = floor(value)
    let interval: CGFloat = 0.5
    let gap = value - result
    if gap >= 0.5 {
        result += interval
    }
    return result
}

// ratio (以375的屏宽为基准)
public let Ratio_Scale: CGFloat = WidthScreen / CGFloat(375)
