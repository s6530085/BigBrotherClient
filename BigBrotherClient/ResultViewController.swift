//
//  ResultViewController.swift
//  BigBrotherClinet
//
//  Created by GongpingjiaNanjing on 15/9/22.
//  Copyright (c) 2015年 sunmin.me. All rights reserved.
//

import UIKit
import SnapKit
import SMFoundation
import SwiftyJSON

fileprivate let hostName : String = "lottery.sunmin.me"
fileprivate let countLimit : UInt32 = 5


class XBA : UIViewController, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

class ResultViewController: UIViewController {

    fileprivate var tableView : UITableView?
    fileprivate var lotteries = [JSON]()
    fileprivate var getting = false
    
    fileprivate let type : LotteryType
    fileprivate let algorithm : LotteryAlgorithm
    // 如果是0则由本界面随机，否则是指定个数
    fileprivate var count = 0
    fileprivate let preferReds : [Int]
    fileprivate let preferBlues : [Int]
    fileprivate let excludeReds : [Int]
    fileprivate let excludeBlues : [Int]
    fileprivate var selectedIndex : Int = 0
    
    init(type : LotteryType, algorithm : LotteryAlgorithm, count : Int, preferReds : [Int], preferBlues : [Int], excludeReds :[Int] = [], excludeBlues : [Int] = []) {
        self.type = type
        self.algorithm = algorithm
        self.count = count
        self.preferReds = preferReds
        self.preferBlues = preferBlues
        self.excludeBlues = excludeBlues
        self.excludeReds = excludeReds
        super.init(nibName: nil, bundle: nil)
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge();
        self.view.backgroundColor = UIColor.white
        self.title = "手气不错"
        let l = UILabel()
        l.text = "再摇一摇即有大仙为您赐号"
        l.textAlignment = .center
        l.textColor = UIColor.red
        l.font = UIFont.systemFont(ofSize: 20)
        self.view.addSubview(l)
        l.snp.makeConstraints{ make in
            _ = make.top.equalTo(20)
            _ = make.left.equalTo(0)
            _ = make.right.equalTo(0)
        }
        
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView?.tableFooterView = UIView()
        tableView?.delegate = self
        tableView?.dataSource = self
        self.view.addSubview(tableView!)
        tableView?.snp.makeConstraints{ make in
            _ = make.top.equalTo(l.snp.bottom).offset(10)
            _ = make.left.equalTo(0)
            _ = make.right.equalTo(0)
            _ = make.bottom.equalTo(self.view)
        }
        
        let lgr = UILongPressGestureRecognizer(target: self, action: #selector(ResultViewController.longPressed(_:)))
        lgr.minimumPressDuration = 1.0
        tableView?.addGestureRecognizer(lgr)
        
        self.getLottery()
    }
    
    
    override var canBecomeFirstResponder : Bool {
        // 摇动中就不要再摇啦
        return !self.getting
    }
    
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            self.getLottery()
        }
    }
    
    
    fileprivate func getLottery() {
        
        var thisCount = self.count
        if thisCount == 0 {
            thisCount = Int(arc4random()%countLimit) + 1
        }
        // 网站没了,改为本地获取
        var js = [JSON]()
        let result = self.type.gene(thisCount, preferReds: preferReds, excludeReds: excludeReds, preferBlues: preferBlues, excludeBlues: excludeBlues, algorithm: nil)
        for index in 0 ..< result.count {
            js.append(JSON(result[index]))
        }
        self.lotteries = js
        self.tableView?.reloadData()
        
//        self.getting = true
//        self.view.showWait(withMessage: "大仙作法中...")
//        let reds = preferReds.map{"\($0)"}.joined(separator: ",")
//        let blues = preferBlues.map{"\($0)"}.joined(separator: ",")
//        let ereds = excludeReds.map{"\($0)"}.joined(separator: ",")
//        let eblues = excludeBlues.map{"\($0)"}.joined(separator: ",")
//
//        let urlString = "http://\(hostName)/lottery?type=\(type.rawValue)&algorithm=\(algorithm.rawValue)&count=\(thisCount)&preferreds=\(reds)&preferblues=\(blues)&excludereds=\(ereds)&excludeblues=\(eblues)"
//        let s = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data : Data?, response, error) -> Void in
//            self.getting = false
//            sm_dispatch_execute_in_main_queue_after(0.0, { () -> Void in
//                self.view.hideWait()
//                if (error == nil  && data != nil) {
//                    let json = try! JSON(data: data!)
//                    self.lotteries = json["lottery_list"].arrayValue
//                    self.tableView?.reloadData()
//                }
//            })
//        })
//        s.resume()
    }
    
    
    @objc fileprivate func longPressed(_ gr : UIGestureRecognizer) {
        let point = gr.location(in: gr.view!)
        if let indexPath = self.tableView?.indexPathForRow(at: point) {
            if gr.state == .began {
                self.selectedIndex = (indexPath as NSIndexPath).row
                self.becomeFirstResponder()
                let menu = UIMenuController.shared
                menu.menuItems = [UIMenuItem(title: "复制单条", action: #selector(ResultViewController.copyOneItem)), UIMenuItem(title: "复制全部", action: #selector(ResultViewController.copyAllItems))]
                menu.setTargetRect(CGRect(x: point.x, y: point.y, width: 0, height: 0), in: self.tableView!)
                menu.setMenuVisible(true, animated: true)
                NSLog("longPressed trigger")
            }
        }
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(ResultViewController.copyOneItem) || action == #selector(ResultViewController.copyAllItems) {
            return true
        }
        return false
    }

    
    @objc fileprivate func copyOneItem() {
        let p = UIPasteboard.general
        p.string = self.selectedLotteryOutput(self.selectedIndex)
        self.view.alert("已复制到剪切板")
        self.resignFirstResponder()
    }
    
    
    @objc fileprivate func copyAllItems() {
        let p = UIPasteboard.general
        let s = NSMutableString()
        for index in 0..<self.lotteries.count {
            s.append(self.selectedLotteryOutput(index) + (index == (self.lotteries.count-1) ? "" : "\n"))
        }
        p.string = s as String
        self.view.alert("已复制到剪切板")
        self.resignFirstResponder()
    }
    
    
    fileprivate func selectedLotteryOutput(_ selectedLotteryIndex : Int) -> String {
        let lo = self.lotteries[selectedLotteryIndex].arrayValue
        var lotteryText = ""
        if self.type == .SuperLotto {
            lotteryText = String(format: "红球: %@, %@, %@, %@, %@, 蓝球: %@, %@", lo[0].stringValue, lo[1].stringValue, lo[2].stringValue, lo[3].stringValue, lo[4].stringValue, lo[5].stringValue, lo[6].stringValue)
        }
        else {
            lotteryText = String(format: "红球: %@, %@, %@, %@, %@, %@, 蓝球: %@", lo[0].stringValue, lo[1].stringValue, lo[2].stringValue, lo[3].stringValue, lo[4].stringValue, lo[5].stringValue, lo[6].stringValue)
        }
        return lotteryText
    }
    
}


extension ResultViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LotteryCell.standardHeight()
    }
    
}


extension ResultViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.lotteries.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: LotteryCell.cellReuseIdentifier()) as? LotteryCell
        if cell == nil {
            cell = LotteryCell(style: .default, reuseIdentifier: LotteryCell.cellReuseIdentifier(), type: self.type)
        }
        cell!.updateWithLottery(self.lotteries[indexPath.row].arrayObject as! Array<Int>)
        return cell!
    }
    
}


// 和上面基本一样，直接构建无需过多参数，在获取的时候还直接取个反来搞
class HedgeResultViewController : ResultViewController {
    
    init(type : LotteryType, algorithm : LotteryAlgorithm) {
        super.init(type: type, algorithm: algorithm, count: 1, preferReds: [], preferBlues: [], excludeReds: [], excludeBlues: [])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override fileprivate func getLottery() {
        var js = [JSON]()
        let result = self.type.gene(1, preferReds: preferReds, excludeReds: excludeReds, preferBlues: preferBlues, excludeBlues: excludeBlues, algorithm: nil)
        let baseInts :[Int] = result[0];
        js.append(JSON(baseInts))
        
        let ereds = Array(self.type == .SuperLotto ? baseInts[0..<5] : baseInts[0..<6])
        let eblues = Array(self.type == .SuperLotto ? baseInts[5..<7] : baseInts[6..<7])
        
        let result2 = self.type.gene(1, preferReds: preferReds, excludeReds: ereds, preferBlues: preferBlues, excludeBlues: eblues, algorithm: nil)
        js.append(JSON(result2[0]))
        
        self.lotteries = js
        self.tableView?.reloadData()
        
        
//        self.getting = true
//        self.view.showWait(withMessage: "大仙作法中...")
//        let urlString = "http://\(hostName)/lottery?type=\(type.rawValue)&algorithm=\(algorithm.rawValue)&count=1"
//        let s = URLSession.shared.dataTask(with: URL(string: urlString)!, completionHandler: { (data : Data?, response, error) -> Void in
//            self.getting = false
//            sm_dispatch_execute_in_main_queue_after(0.0, { () -> Void in
//                if (error == nil  && data != nil) {
//                    let json = try! JSON(data: data!)
//                    // 然后再对冲一下
//                    let baseLotteries = json["lottery_list"].arrayValue
//                    if baseLotteries.count > 0 {
//                        let baseInts = baseLotteries[0].arrayObject as! Array<Int>
//                        let ereds = self.type == .SuperLotto ? baseInts[0..<5].map{"\($0)"}.joined(separator: ",") : baseInts[0..<6].map{"\($0)"}.joined(separator: ",")
//                        let eblues = self.type == .SuperLotto ? baseInts[5..<7].map{"\($0)"}.joined(separator: ",") : baseInts[6..<7].map{"\($0)"}.joined(separator: ",")
//                        let urlString2 = "http://\(hostName)/lottery?type=\(self.type.rawValue)&algorithm=prefer&count=1&excludereds=\(ereds)&excludeblues=\(eblues)"
//                        let s2 = URLSession.shared.dataTask(with:URL(string: urlString2)!, completionHandler: { (data2 : Data?, response2, error2) in
//                            sm_dispatch_execute_in_main_queue_after(0.0, {
//                                self.view.hideWait()
//                                if (error2 == nil && data2 != nil ) {
//                                    let json2 = try! JSON(data: data2!)
//                                    self.lotteries = baseLotteries + json2["lottery_list"].arrayValue
//                                    self.tableView?.reloadData()
//                                }
//                                else {
//                                    self.view.alert("获取失败，重新摇摇试试吧")
//                                }
//                            })
//
//                        })
//                        s2.resume()
//                    }
//                    else {
//                        self.view.alert("获取失败，重新摇摇试试吧")
//                    }
//                }
//                else {
//                    self.view.alert("获取失败，重新摇摇试试吧")
//                }
//            })
//        })
//        s.resume()
    }

}
