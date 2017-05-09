//
//  Lottery.swift
//  BigBrotherClinet
//
//  Created by GongpingjiaNanjing on 15/10/9.
//  Copyright © 2015年 sunmin.me. All rights reserved.
//

import Foundation

enum LotteryType : String {
    case SuperLotto = "superlotto"
    case WelfareLottery = "welfarelottery"
    
    func blueBallCount() -> Int {
        switch self {
        case .SuperLotto:
            return 2
            
        case .WelfareLottery:
            return 1
        }
    }
    
    
    func redBallCount() -> Int {
        switch self {
        case .SuperLotto:
            return 5
            
        case .WelfareLottery:
            return 6
        }
    }
    
    
    func blueBallMinValue() -> Int {
        return 1
    }
    
    
    func blueBallMaxValue() -> Int {
        switch self {
        case .SuperLotto:
            return 12
            
        case .WelfareLottery:
            return 16
        }
    }
    
    
    func redBallMinValue() -> Int {
        return 1
    }
    
    
    func redBallMaxValue() -> Int {
        switch self {
        case .SuperLotto:
            return 35
            
        case .WelfareLottery:
            return 33
        }
    }
    
}


enum LotteryAlgorithm : String {
    case Random = "random"
    case Prefer = "prefer"
    
}
