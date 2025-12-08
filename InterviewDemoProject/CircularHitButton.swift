//
//  CircularHitButton.swift
//  InterviewDemoProject
//
//  自定義按鈕：方形按鈕中只有中間圓形部分可以響應
//

import UIKit

/// 圓形響應區域按鈕
/// 按鈕外觀是方形，但只有中間的圓形區域可以響應點擊事件
class CircularHitButton: UIButton {
    
    // MARK: - Properties
    
    /// 日誌代理
    weak var logDelegate: LogDelegate?
    
    /// 按鈕名稱
    var buttonName: String = "Circular Button"
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        // 設置按鈕外觀
        backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
        layer.cornerRadius = 0 // 方形外觀
        
        // 設置標題
        setTitle("點我", for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        
        // 添加圓形內邊框以便視覺化響應區域
        addCircularGuide()
    }
    
    /// 添加圓形參考線，幫助用戶看到真實的響應區域
    private func addCircularGuide() {
        // 在布局完成後繪製圓形
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 移除舊的圓形層（如果存在）
            self.layer.sublayers?.forEach { layer in
                if layer.name == "circularGuide" {
                    layer.removeFromSuperlayer()
                }
            }
            
            // 計算圓形半徑（使用較小的邊長）
            let radius = min(self.bounds.width, self.bounds.height) / 2
            let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height / 2)
            
            // 創建圓形路徑
            let circlePath = UIBezierPath(
                arcCenter: center,
                radius: radius,
                startAngle: 0,
                endAngle: .pi * 2,
                clockwise: true
            )
            
            // 創建圓形邊框層
            let circleLayer = CAShapeLayer()
            circleLayer.path = circlePath.cgPath
            circleLayer.fillColor = UIColor.white.withAlphaComponent(0.2).cgColor
            circleLayer.strokeColor = UIColor.white.cgColor
            circleLayer.lineWidth = 2
            circleLayer.lineDashPattern = [5, 3] // 虛線效果
            circleLayer.name = "circularGuide"
            
            self.layer.insertSublayer(circleLayer, at: 0)
        }
    }
    
    // MARK: - Hit-Testing Override
    
    /// 重寫 point(inside:with:) 方法
    /// 只有當點擊位置在圓形區域內時才返回 true
    ///
    /// 核心原理：
    /// 1. 計算按鈕的中心點
    /// 2. 計算點擊位置到中心點的距離
    /// 3. 判斷距離是否小於圓的半徑
    ///
    /// - Parameters:
    ///   - point: 觸摸點在按鈕坐標系中的位置
    ///   - event: 觸摸事件對象
    /// - Returns: 如果點在圓形區域內返回 true，否則返回 false
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 計算按鈕的中心點
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        
        // 計算圓的半徑（使用較小的邊長）
        let radius = min(bounds.width, bounds.height) / 2
        
        // 計算觸摸點到中心點的距離
        let dx = point.x - center.x
        let dy = point.y - center.y
        let distance = sqrt(dx * dx + dy * dy)
        
        // 判斷距離是否小於半徑
        let isInside = distance <= radius
        
        // 記錄日誌
        logDelegate?.log("🔘 [\(buttonName)] point(inside:) 檢測")
        logDelegate?.log("   ├─ 觸摸點: (\(Int(point.x)), \(Int(point.y)))")
        logDelegate?.log("   ├─ 中心點: (\(Int(center.x)), \(Int(center.y)))")
        logDelegate?.log("   ├─ 半徑: \(Int(radius)), 距離: \(Int(distance))")
        logDelegate?.log("   └─ 結果: \(isInside ? "✅ 在圓形內" : "❌ 在圓形外")")
        
        return isInside
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // 重新繪製圓形參考線（當按鈕大小改變時）
        addCircularGuide()
    }
    
    // MARK: - Touch Feedback
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        logDelegate?.log("✅ [\(buttonName)] 按鈕被點擊！")
        
        // 添加視覺反饋
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // 恢復原始大小
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        // 恢復原始大小
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
        }
    }
}

// MARK: - 面試要點總結

/*
 
 📚 面試要點：方形按鈕指定區域響應
 
 1️⃣ 核心原理：
    - 重寫 point(inside:with:) 方法
    - 自定義判斷邏輯，決定哪些區域可以響應
 
 2️⃣ 圓形區域判斷算法：
    - 計算觸摸點到圓心的距離
    - 使用勾股定理：distance = √(dx² + dy²)
    - 判斷 distance ≤ radius
 
 3️⃣ 應用場景：
    - 不規則形狀的按鈕
    - 圓形按鈕（方形容器）
    - 特殊響應區域的控件
    - 遊戲中的碰撞檢測
 
 4️⃣ 注意事項：
    - point(inside:) 影響所有觸摸事件的檢測
    - 返回 false 時，按鈕不會接收任何觸摸事件
    - 需要考慮按鈕的大小變化（layoutSubviews）
 
 5️⃣ 擴展思考：
    - 如何實現其他形狀？（三角形、星形等）
    - 如何實現多個不連續的響應區域？
    - 如何實現帶間隙的響應區域？
 
 */

