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
    
    func gene(_ count:Int, preferReds:[Int]?, excludeReds:[Int]?, preferBlues:[Int]?, excludeBlues:[Int]?, algorithm:LotteryAlgorithm?) -> [[Int]] {
        var rs = [[Int]]()
        for _ in 0 ..< count {
            var reds = BaseAlgorithm.random(self.redBallCount(), min: self.redBallMinValue(), max:self.redBallMaxValue(), prefers: preferReds, excludes: excludeReds)
            let blues = BaseAlgorithm.random(self.blueBallCount(), min: self.blueBallMinValue(), max: self.blueBallMaxValue(), prefers: preferBlues, excludes: excludeBlues)
            reds.append(contentsOf: blues)
            rs.append(reds)
        }
        
        return rs
    }
}


enum LotteryAlgorithm : String {
    case Random = "random"
    case Prefer = "prefer"
    
}
