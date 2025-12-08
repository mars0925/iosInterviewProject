//
//  CustomView.swift
//  InterviewDemoProject
//
//  Created for demonstrating UIView event handling mechanism
//

import UIKit

// MARK: - Log Delegate Protocol
// 用於將日誌信息傳遞給 ViewController
protocol LogDelegate: AnyObject {
    func log(_ message: String)
}

// MARK: - Custom View Class
/// 自定義 UIView 子類，用於演示事件傳遞和響應鏈機制
class CustomView: UIView {
    
    // MARK: - Properties
    
    /// 視圖的名稱，用於在日誌中識別
    var viewName: String = "Unknown View"
    
    /// 日誌代理，用於將日誌信息傳遞給 ViewController
    weak var logDelegate: LogDelegate?
    
    /// 層級深度，用於格式化日誌輸出
    var depth: Int = 0
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // 啟用用戶交互
        isUserInteractionEnabled = true
        
        // 添加邊框以便視覺區分
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
    
    // MARK: - Hit-Testing Methods (事件傳遞階段)
    
    /// Hit-Testing 的核心方法
    /// 這個方法決定了哪個視圖應該接收觸摸事件
    /// 調用順序：從父視圖到子視圖（由外向內）
    ///
    /// - Parameters:
    ///   - point: 觸摸點在當前視圖坐標系中的位置
    ///   - event: 觸摸事件對象
    /// - Returns: 應該接收事件的最深層級的視圖，如果不應該接收則返回 nil
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let indent = String(repeating: "  ", count: depth)
        logDelegate?.log("\(indent)⬇️ [\(viewName)] hitTest 被調用 - point: (\(Int(point.x)), \(Int(point.y)))")
        
        // Step 1: 首先檢查當前視圖是否可以接收事件
        // 如果視圖被隱藏、不可交互或透明度太低，則不處理
        if !isUserInteractionEnabled || isHidden || alpha < 0.01 {
            logDelegate?.log("\(indent)   └─ [\(viewName)] 不可交互，返回 nil")
            return nil
        }
        
        // Step 2: 檢查觸摸點是否在當前視圖範圍內
        // 這裡會調用 point(inside:with:) 方法
        if !self.point(inside: point, with: event) {
            logDelegate?.log("\(indent)   └─ [\(viewName)] 點不在範圍內，返回 nil")
            return nil
        }
        
        // Step 3: 逆序遍歷子視圖（後添加的先遍歷）
        // 這是因為後添加的視圖通常在上層，應該優先接收事件
        logDelegate?.log("\(indent)   └─ [\(viewName)] 點在範圍內，開始檢查子視圖...")
        
        for subview in subviews.reversed() {
            // 將觸摸點轉換到子視圖的坐標系
            let convertedPoint = convert(point, to: subview)
            
            // 遞歸調用子視圖的 hitTest
            if let hitView = subview.hitTest(convertedPoint, with: event) {
                logDelegate?.log("\(indent)   └─ [\(viewName)] 找到目標視圖，返回: \((hitView as? CustomView)?.viewName ?? "系統視圖")")
                return hitView
            }
        }
        
        // Step 4: 如果沒有子視圖處理事件，則當前視圖自己處理
        logDelegate?.log("\(indent)   └─ [\(viewName)] 沒有子視圖處理，返回自己")
        return self
    }
    
    /// 判斷觸摸點是否在視圖範圍內
    /// 這個方法在 hitTest 中被調用
    ///
    /// - Parameters:
    ///   - point: 觸摸點在當前視圖坐標系中的位置
    ///   - event: 觸摸事件對象
    /// - Returns: 如果點在視圖範圍內返回 true，否則返回 false
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let indent = String(repeating: "  ", count: depth)
        let isInside = super.point(inside: point, with: event)
        logDelegate?.log("\(indent)   🎯 [\(viewName)] point(inside:) 被調用 - 結果: \(isInside ? "✅ 在範圍內" : "❌ 不在範圍內")")
        return isInside
    }
    
    // MARK: - Touch Event Methods (事件響應階段)
    
    /// 觸摸開始
    /// 調用順序：從最終響應的視圖開始，沿著響應鏈向上傳遞（由內向外）
    /// 如果不調用 super.touchesBegan，事件將不會繼續向上傳遞
    ///
    /// - Parameters:
    ///   - touches: 觸摸對象集合
    ///   - event: 觸摸事件對象
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let indent = String(repeating: "  ", count: depth)
        logDelegate?.log("\(indent)⬆️ [\(viewName)] touchesBegan 被調用 - 開始響應事件")
        
        // 添加視覺反饋：短暫高亮
        highlightView()
        
        // 調用 super 將事件繼續向上傳遞到響應鏈的下一個響應者
        // 如果註釋掉這行，事件將不會繼續向上傳遞
        super.touchesBegan(touches, with: event)
        
        logDelegate?.log("\(indent)   └─ [\(viewName)] 事件已傳遞給下一個響應者")
    }
    
    /// 觸摸移動
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 為了避免日誌過多，這裡不記錄移動事件
        super.touchesMoved(touches, with: event)
    }
    
    /// 觸摸結束
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let indent = String(repeating: "  ", count: depth)
        logDelegate?.log("\(indent)⬆️ [\(viewName)] touchesEnded 被調用 - 結束響應事件")
        super.touchesEnded(touches, with: event)
    }
    
    /// 觸摸取消（例如來電話時）
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        let indent = String(repeating: "  ", count: depth)
        logDelegate?.log("\(indent)⬆️ [\(viewName)] touchesCancelled 被調用")
        super.touchesCancelled(touches, with: event)
    }
    
    // MARK: - Visual Feedback
    
    /// 高亮視圖，提供視覺反饋
    private func highlightView() {
        let originalAlpha = alpha
        
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.5
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.alpha = originalAlpha
            }
        }
    }
    
    // MARK: - Responder Chain
    
    /// 返回響應鏈中的下一個響應者
    /// 響應鏈順序：View → SuperView → ... → ViewController → Window → UIApplication
    override var next: UIResponder? {
        let nextResponder = super.next
        let nextName: String
        
        if let view = nextResponder as? CustomView {
            nextName = view.viewName
        } else if nextResponder is UIViewController {
            nextName = "ViewController"
        } else if nextResponder is UIWindow {
            nextName = "UIWindow"
        } else if nextResponder is UIApplication {
            nextName = "UIApplication"
        } else {
            nextName = "Unknown"
        }
        
        // 可以在這裡記錄響應鏈信息
        return nextResponder
    }
}

