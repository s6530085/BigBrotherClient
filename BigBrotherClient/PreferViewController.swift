//
//  PreferViewController.swift
//  BigBrotherClinet
//
//  Created by GongpingjiaNanjing on 15/10/8.
//  Copyright © 2015年 sunmin.me. All rights reserved.
//

import UIKit
import SMFoundation

typealias funcBlock = () -> Void
class BlockLable : UILabel {
    var tapBlock : funcBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(BlockLable.selfTapped)))
        self.isUserInteractionEnabled = true
        NSLog("%@", "I Life")

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func selfTapped() {
        if self.tapBlock != nil {
            self.tapBlock!()
        }
    }
    
    
    deinit {
        NSLog("%@", "I die")
    }
}



class PreferViewController: UIViewController {
    
    fileprivate let blueBallTagIndex = 2000
    fileprivate let redBallTagIndex = 1000
    fileprivate let tagForBallLabel = 999

    fileprivate let type : LotteryType
    fileprivate lazy var preferReds = [Int]()
    fileprivate lazy var preferBlues = [Int]()
    fileprivate lazy var excludeReds = [Int]()
    fileprivate lazy var excludeBlues = [Int]()
    
    // 我本来也想不同尺寸显示不同的个数，但是如果出现未知尺寸我还是得改，那么还不如写死一个值
    fileprivate let oneLineBallCount = 7
    
    init(type : LotteryType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 这里隐藏条件是整体左右间隔各是20
    fileprivate func geneBallsView(isBlue : Bool, topView : UIView? = nil) -> UIView {
        
        let outterMargin = 20
        let innerMargin = 8
        let ballOuterWidth = (Int(kScreenWidth()) - (outterMargin * 2 + innerMargin * 2)) / oneLineBallCount
        let ballInnerWidth = ballOuterWidth - 10
        let maxValue = isBlue ? self.type.blueBallMaxValue() : self.type.redBallMaxValue()

        let ballsView = UIView()
        ballsView.layer.cornerRadius = 5.0
        ballsView.layer.borderColor = UIColor.gray.cgColor
        ballsView.layer.borderWidth = 0.5
        self.view.addSubview(ballsView)
        ballsView.snp.makeConstraints { (make) -> Void in
            _ = make.left.equalTo(outterMargin)
            _ = make.right.equalTo(-outterMargin)
            let h = innerMargin * 2 + ballOuterWidth * (maxValue / oneLineBallCount + (maxValue % oneLineBallCount != 0 ? 1 : 0))
            _ = make.height.equalTo(h)
//            _ = make.top.equalTo(topView)
            if topView != nil {
                _ = make.top.equalTo(topView!.snp.bottom).offset(30)
            }
            else {
                _ = make.top.equalTo(30)
            }
        }
        
        let title = String(format: "请选择%@球，不超过%d个", (isBlue ? "蓝" : "红"), (isBlue ? self.type.blueBallCount() : self.type.redBallCount()))
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.gray
        titleLabel.backgroundColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) -> Void in
            _ = make.left.equalTo(ballsView).offset(20)
            _ = make.top.equalTo(ballsView).offset(-10)
            _ = make.height.equalTo(20)
            _ = make.width.equalTo(150)
        }
        
        let borderColor = isBlue ? UIColor.blue.cgColor : UIColor.red.cgColor
        let beginTagIndex = isBlue ? blueBallTagIndex : redBallTagIndex
        
        for var ballIndex in 1 ... maxValue {
            let ballView = UIView()
            ballView.tag = beginTagIndex + ballIndex
            ballView.isUserInteractionEnabled = true
            let singleTapped = UITapGestureRecognizer(target: self, action: #selector(PreferViewController.ballTapped(_:)))
            ballView.addGestureRecognizer(singleTapped)
            let longTapped = UILongPressGestureRecognizer(target: self, action: #selector(PreferViewController.ballLongTapped(_:)))
            ballView.addGestureRecognizer(longTapped)
            singleTapped.require(toFail: longTapped)
            ballIndex -= 1
            ballsView.addSubview(ballView)
            ballView.snp.makeConstraints{ (make) -> Void in
                _ = make.top.equalTo(innerMargin + ballOuterWidth * (ballIndex / oneLineBallCount))
                _ = make.left.equalTo(innerMargin + ballOuterWidth * (ballIndex % oneLineBallCount))
                _ = make.width.equalTo(ballOuterWidth)
                _ = make.height.equalTo(ballOuterWidth)
            }
            
            let ballLabel = UILabel()
            ballLabel.tag = tagForBallLabel
            ballIndex += 1
            ballLabel.text = "\(ballIndex)"
            ballLabel.textAlignment = .center
            ballLabel.font = UIFont.systemFont(ofSize: 12)
            ballLabel.backgroundColor = UIColor.white
            ballLabel.layer.borderWidth = 1
            ballLabel.layer.borderColor = borderColor
            ballLabel.layer.cornerRadius = CGFloat(ballInnerWidth/2)
            ballLabel.clipsToBounds = true
            ballView.addSubview(ballLabel)
            ballLabel.snp.makeConstraints{ (make) -> Void in
                _ = make.centerX.equalTo(ballView)
                _ = make.centerY.equalTo(ballView)
                _ = make.width.equalTo(ballInnerWidth)
                _ = make.height.equalTo(ballInnerWidth)
            }
            
        }
        
        
        return ballsView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = UIRectEdge();
        
        self.view.backgroundColor = UIColor.white
        
        let redBallsView = self.geneBallsView(isBlue:false)
        
        let blueBallsView = self.geneBallsView(isBlue: true, topView: redBallsView)

        let commitButton = UIButton()
        commitButton.layer.cornerRadius = 5.0
        commitButton.layer.borderColor = UIColor.gray.cgColor
        commitButton.layer.borderWidth = 0.5
        commitButton.setTitleColor(UIColor.gray, for: UIControlState())
        commitButton.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        commitButton.setTitle("跪求大仙做法", for: UIControlState())
        commitButton.addTarget(self, action: #selector(PreferViewController.commitTapped(_:)), for: .touchUpInside)
        
        self.view.addSubview(commitButton)
        commitButton.snp.makeConstraints { (make) -> Void in
            _ = make.left.equalTo(30)
            _ = make.right.equalTo(-30)
            _ = make.top.equalTo(blueBallsView.snp.bottom).offset(20)
            _ = make.height.equalTo(44)
        }
        
    }
    
    
    // 长按可以选的长按和取消已经长按的，但是和单击无关，穿插就没反应
    func ballLongTapped(_ gr : UIGestureRecognizer) {
        if gr.state != .began {
            return
        }

        sm_dispatch_execute_in_main_queue_after(0.5) { () -> Void in
            gr.view!.isUserInteractionEnabled = true
        }
        
        let tag = gr.view!.tag
        if tag > blueBallTagIndex {
            let index = tag - blueBallTagIndex
            if let ss = excludeBlues.index(of: index) {
                excludeBlues.remove(at: ss)
                gr.view?.viewWithTag(tagForBallLabel)?.backgroundColor = UIColor.white
            }
            else if preferBlues.index(of: index) == nil {
                if excludeBlues.count < self.type.blueBallMaxValue() - self.type.blueBallCount() {
                    excludeBlues.append(index)
                    gr.view?.viewWithTag(self.tagForBallLabel)?.backgroundColor = UIColor.black
                }
            }
        }
        else {
            let index = tag - redBallTagIndex
            if let ss = excludeReds.index(of: index) {
                excludeReds.remove(at: ss)
                gr.view?.viewWithTag(tagForBallLabel)?.backgroundColor = UIColor.white
            }
            else if preferReds.index(of: index) == nil {
                if excludeReds.count < self.type.redBallMaxValue() - self.type.redBallCount() {
                    excludeReds.append(index)
                    gr.view?.viewWithTag(self.tagForBallLabel)?.backgroundColor = UIColor.black
                }
            }
        }
    }
    
    
    func ballTapped(_ gr : UIGestureRecognizer) {
        gr.view!.isUserInteractionEnabled = false
        sm_dispatch_execute_in_main_queue_after(0.5) { () -> Void in
            gr.view!.isUserInteractionEnabled = true
        }
        let tag = gr.view!.tag
        if tag > blueBallTagIndex {
            let index = tag - blueBallTagIndex
            if let ss = preferBlues.index(of: index) {
                preferBlues.remove(at: ss)
                gr.view?.viewWithTag(tagForBallLabel)?.backgroundColor = UIColor.white
            }
            else if excludeBlues.index(of: index) == nil {
                if preferBlues.count < self.type.blueBallCount() {
                    preferBlues.append(index)
                    gr.view?.viewWithTag(tagForBallLabel)?.backgroundColor = UIColor.blue
                }
            }
        }
        else {
            let index = tag - redBallTagIndex
            if let ss = preferReds.index(of: index) {
                preferReds.remove(at: ss)
                gr.view?.viewWithTag(tagForBallLabel)?.backgroundColor = UIColor.white
            }
            else if excludeReds.index(of: index) == nil {
                if preferReds.count < self.type.redBallCount() {
                    preferReds.append(index)
                    gr.view?.viewWithTag(tagForBallLabel)?.backgroundColor = UIColor.red
                }
            }
        }
    }
    
    
    func commitTapped(_ button : UIButton) {
        
        button.isUserInteractionEnabled = false
        sm_dispatch_execute_in_main_queue_after(1.0) { () -> Void in
            button.isUserInteractionEnabled = true
        }
        
        if (preferBlues.count >= self.type.blueBallCount()) && (preferReds.count >= self.type.redBallCount()) {
            self.view.alert("妈的智障你全选好了还赐号个屁")
            return
        }
        
        let c = ResultViewController(type: self.type, algorithm: .Prefer, count: 0, preferReds: preferReds, preferBlues: preferBlues, excludeReds: excludeReds, excludeBlues : excludeBlues)
        self.navigationController?.pushViewController(c, animated: true)
    }
    
    
}
