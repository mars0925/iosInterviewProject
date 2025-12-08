//
//  SyncDrawingView.swift
//  InterviewDemoProject
//
//  同步繪製演示：在主線程執行繪製，會阻塞主線程導致卡頓

import UIKit

class SyncDrawingView: UIView {
    
    // MARK: - Properties
    
    /// 要顯示的文字內容
    var text: String = "同步繪製測試\n這是一段較長的文字內容，用於測試同步繪製的性能。\n當文字量很大時，同步繪製會阻塞主線程，導致界面卡頓。" {
        didSet {
            // 當文字改變時，標記需要重繪
            setNeedsDisplay()
        }
    }
    
    /// 文字顏色
    var textColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 文字字體
    var font: UIFont = .systemFont(ofSize: 16) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 是否繪製複雜圖形（模擬耗時操作）
    var drawComplexShapes: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }
    
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
        // 設置背景色為白色
        backgroundColor = .white
        
        // 設置為不透明，優化渲染性能
        isOpaque = true
    }
    
    // MARK: - Drawing
    
    /// 核心繪製方法：在主線程同步執行，會阻塞主線程
    override func draw(_ rect: CGRect) {
        // 獲取當前繪製上下文
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 記錄繪製開始時間，用於測量性能
        let startTime = CFAbsoluteTimeGetCurrent()
        
        // 1. 繪製背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(rect)
        
        // 2. 繪製複雜圖形（模擬耗時操作）
        if drawComplexShapes {
            drawComplexGraphics(in: context, rect: rect)
        }
        
        // 3. 繪製文字
        drawText(in: rect)
        
        // 4. 繪製邊框
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.stroke(rect.insetBy(dx: 0.5, dy: 0.5))
        
        // 計算並打印繪製耗時
        let elapsedTime = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        print("🔴 同步繪製耗時: \(String(format: "%.2f", elapsedTime))ms")
    }
    
    /// 繪製複雜圖形：繪製大量圓形和線條，模擬耗時操作
    private func drawComplexGraphics(in context: CGContext, rect: CGRect) {
        // 設置繪製參數
        context.setLineWidth(0.5)
        context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.3).cgColor)
        
        // 繪製大量圓形（模擬複雜繪製）
        let circleCount = 50
        for i in 0..<circleCount {
            let x = CGFloat(arc4random_uniform(UInt32(rect.width)))
            let y = CGFloat(arc4random_uniform(UInt32(rect.height)))
            let radius = CGFloat(arc4random_uniform(20)) + 5
            
            let circlePath = UIBezierPath(
                arcCenter: CGPoint(x: x, y: y),
                radius: radius,
                startAngle: 0,
                endAngle: CGFloat.pi * 2,
                clockwise: true
            )
            
            // 設置隨機顏色
            let hue = CGFloat(i) / CGFloat(circleCount)
            let color = UIColor(hue: hue, saturation: 0.5, brightness: 0.9, alpha: 0.3)
            context.setFillColor(color.cgColor)
            
            context.addPath(circlePath.cgPath)
            context.drawPath(using: .fillStroke)
        }
        
        // 繪製網格線
        context.setStrokeColor(UIColor.systemGray.withAlphaComponent(0.1).cgColor)
        let gridSpacing: CGFloat = 20
        
        // 垂直線
        var x: CGFloat = 0
        while x <= rect.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: rect.height))
            x += gridSpacing
        }
        
        // 水平線
        var y: CGFloat = 0
        while y <= rect.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: rect.width, y: y))
            y += gridSpacing
        }
        
        context.strokePath()
    }
    
    /// 繪製文字內容
    private func drawText(in rect: CGRect) {
        // 設置文字繪製屬性
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        // 計算文字繪製區域（留出內邊距）
        let textRect = rect.insetBy(dx: 20, dy: 20)
        
        // 繪製文字
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        attributedString.draw(in: textRect)
    }
    
    // MARK: - Public Methods
    
    /// 更新顯示內容（會觸發同步重繪）
    func updateContent(text: String? = nil, color: UIColor? = nil) {
        if let newText = text {
            self.text = newText
        }
        if let newColor = color {
            self.textColor = newColor
        }
        // setNeedsDisplay() 標記需要重繪
        // 實際重繪會在下一個 RunLoop 週期執行
        // 但執行時是在主線程同步完成的
        setNeedsDisplay()
    }
}

