//
//  MainViewController.swift
//  BigBrotherClinet
//
//  Created by GongpingjiaNanjing on 15/10/8.
//  Copyright © 2015年 sunmin.me. All rights reserved.
//

import UIKit
import SMFoundation

class MainViewController: UIViewController {
    
    static let buttonTitles = ["大乐透精细选号", "福彩精细选号", "手气不错", "对冲摇号"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "首页"
        
        let slButton = UIButton()
        slButton.layer.cornerRadius = 5.0
        slButton.layer.borderColor = UIColor.gray.cgColor
        slButton.layer.borderWidth = 0.5
        slButton.setTitleColor(UIColor.gray, for: UIControlState())
        slButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        slButton.setTitle(MainViewController.buttonTitles[0], for: UIControlState())
        slButton.addTarget(self, action: #selector(MainViewController.supperLottoTapped), for: .touchUpInside)
        
        self.view.addSubview(slButton)
        
        let welButton = UIButton()
        welButton.layer.cornerRadius = 5.0
        welButton.layer.borderColor = UIColor.red.cgColor
        welButton.layer.borderWidth = 0.5
        welButton.setTitleColor(UIColor.gray, for: UIControlState())
        welButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        welButton.setTitle(MainViewController.buttonTitles[1], for: UIControlState())
        welButton.addTarget(self, action: #selector(MainViewController.welfareLottoTapped), for: .touchUpInside)

        self.view.addSubview(welButton)
        
        let luckyButton = UIButton()
        luckyButton.layer.cornerRadius = 5.0
        luckyButton.layer.borderColor = UIColor.blue.cgColor
        luckyButton.layer.borderWidth = 0.5
        luckyButton.setTitleColor(UIColor.gray, for: UIControlState())
        luckyButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        luckyButton.titleLabel?.numberOfLines = 2
        luckyButton.titleLabel?.textAlignment = .center
        
        let s = NSMutableAttributedString(string: "\(MainViewController.buttonTitles[2])\n", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 30)])
        s.append(NSAttributedString(string: "摇一摇即可直接获得赐号", attributes: [NSAttributedStringKey.foregroundColor : UIColor.gray, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)]))
        luckyButton.setAttributedTitle(s, for: UIControlState())
        luckyButton.addTarget(self, action: #selector(MainViewController.luckyTapped), for: .touchUpInside)
        self.view.addSubview(luckyButton)
        
        let hedgeButton = UIButton()
        hedgeButton.layer.cornerRadius = 5.0
        hedgeButton.layer.borderColor = UIColor.blue.cgColor
        hedgeButton.layer.borderWidth = 0.5
        hedgeButton.setTitleColor(UIColor.gray, for: UIControlState())
        hedgeButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        hedgeButton.titleLabel?.numberOfLines = 2
        hedgeButton.titleLabel?.textAlignment = .center
        hedgeButton.setTitle(MainViewController.buttonTitles[3], for: UIControlState())
        hedgeButton.addTarget(self, action: #selector(MainViewController.hedgeTapped), for: .touchUpInside)
        hedgeButton.addTarget(self, action: #selector(MainViewController.hedgeForceTapped), for: .touchUpOutside)
        self.view.addSubview(hedgeButton)
        
        slButton.snp.makeConstraints { (make) -> Void in
            _ = make.left.equalTo(30)
            _ = make.right.equalTo(-30)
            _ = make.top.equalTo(60)
            _ = make.height.equalTo(welButton)
        }
        
        welButton.snp.makeConstraints { (make) -> Void in
            _ = make.left.equalTo(slButton)
            _ = make.right.equalTo(slButton)
            _ = make.top.equalTo(slButton.snp.bottom).offset(80)
            _ = make.height.equalTo(luckyButton)
        }
        
        luckyButton.snp.makeConstraints { (make) -> Void in
            _ = make.left.equalTo(slButton)
            _ = make.right.equalTo(slButton)
            _ = make.top.equalTo(welButton.snp.bottom).offset(80)
            _ = make.height.equalTo(slButton)
        }
        
        hedgeButton.snp.makeConstraints { (make) in
            _ = make.left.equalTo(slButton)
            _ = make.right.equalTo(slButton)
            _ = make.top.equalTo(luckyButton.snp.bottom).offset(80)
            _ = make.height.equalTo(slButton)
            _ = make.bottom.equalTo(self.view).offset(-60)
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.luckyTapped()
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @objc fileprivate func supperLottoTapped() {
        let c = PreferViewController(type: .SuperLotto)
        c.navigationItem.title = MainViewController.buttonTitles[0]
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    
    @objc fileprivate func welfareLottoTapped() {
        let c = PreferViewController(type: .WelfareLottery)
        c.navigationItem.title = MainViewController.buttonTitles[1]
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    
    @objc fileprivate func luckyTapped() {
        let c = ResultViewController(type: self.todayIsSuperLottoDay() ? .SuperLotto : .WelfareLottery, algorithm: .Random, count: 0, preferReds: [], preferBlues: [])
        c.navigationItem.title = MainViewController.buttonTitles[2]
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    
    @objc fileprivate func hedgeTapped(_ button: UIButton) {
        let c = HedgeResultViewController(type: self.todayIsSuperLottoDay() ? .SuperLotto : .WelfareLottery, algorithm: .Random)
        c.navigationItem.title = MainViewController.buttonTitles[3]
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    @objc fileprivate func hedgeForceTapped(_ button: UIButton) {
        let c = HedgeResultViewController(type: .SuperLotto, algorithm: .Random)
        c.navigationItem.title = MainViewController.buttonTitles[3]
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    
    // 根据时间来给你选择不同的种类1，3，56是大乐透，2，4，7是福彩
    fileprivate func todayIsSuperLottoDay() -> Bool {
        let now = Date()
        let calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let unitFlags: NSCalendar.Unit = [.weekday]
        let comps = (calendar as NSCalendar?)?.components(unitFlags, from: now)
        let week = comps?.weekday
        // 不过这里1是周日，7是周六哦
        return (week == 6) || (week == 7) || (week == 2) || (week == 4)
    }
}
