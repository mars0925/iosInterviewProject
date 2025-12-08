//
//  UIViewLifeCycleDemoViewController.swift
//  InterviewDemoProject
//
//  UIView 生命週期演示
//

import UIKit

// MARK: - Custom View to Demonstrate Lifecycle
/// 自定義 View 用於演示生命週期的各個階段
/// 這個 View 會在每個生命週期方法被調用時記錄日誌
class LifeCycleView: UIView {
    
    // 用於識別不同的 View 實例
    let viewName: String
    
    // MARK: - Initialization
    /// 使用 frame 初始化（程式碼創建）
    init(frame: CGRect, name: String) {
        self.viewName = name
        super.init(frame: frame)
        log("init(frame:) - View 初始化完成")
        setupView()
    }
    
    /// 從 Storyboard/XIB 初始化
    required init?(coder: NSCoder) {
        self.viewName = "從 Storyboard 加載"
        super.init(coder: coder)
        log("init(coder:) - 從 Interface Builder 初始化")
        setupView()
    }
    
    /// 基本設置
    private func setupView() {
        backgroundColor = .systemBlue.withAlphaComponent(0.3)
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemBlue.cgColor
        layer.cornerRadius = 8
    }
    
    // MARK: - Superview Lifecycle
    /// 即將添加到父視圖或從父視圖移除
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let superview = newSuperview {
            log("willMove(toSuperview:) - 即將添加到父視圖: \(type(of: superview))")
        } else {
            log("willMove(toSuperview: nil) - 即將從父視圖移除")
        }
    }
    
    /// 已經添加到父視圖或已經從父視圖移除
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if let _ = superview {
            log("didMoveToSuperview() - 已添加到父視圖")
        } else {
            log("didMoveToSuperview() - 已從父視圖移除")
        }
    }
    
    // MARK: - Window Lifecycle
    /// 即將添加到 window 或從 window 移除
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if let _ = newWindow {
            log("willMove(toWindow:) - 即將添加到 Window（即將顯示在螢幕上）")
        } else {
            log("willMove(toWindow: nil) - 即將從 Window 移除（即將從螢幕消失）")
        }
    }
    
    /// 已經添加到 window 或已經從 window 移除
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if let _ = window {
            log("didMoveToWindow() - 已添加到 Window（已顯示在螢幕上）")
        } else {
            log("didMoveToWindow() - 已從 Window 移除（已從螢幕消失）")
        }
    }
    
    // MARK: - Layout Lifecycle
    /// 更新約束（Auto Layout）
    override func updateConstraints() {
        log("updateConstraints() - 更新約束")
        super.updateConstraints()
    }
    
    /// 佈局子視圖
    /// 這是設置子視圖 frame 的最佳時機
    override func layoutSubviews() {
        super.layoutSubviews()
        log("layoutSubviews() - 佈局子視圖，當前 frame: \(frame)")
        
        // 在這裡可以精確設置子視圖的位置
        // 注意：不要在這裡創建新的視圖，這個方法可能被多次調用
    }
    
    // MARK: - Drawing Lifecycle
    /// 繪製視圖內容
    /// 只有當需要自定義繪製時才需要重寫此方法
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        log("draw(_:) - 繪製視圖，rect: \(rect)")
        
        // 自定義繪製：在視圖中央畫一個圓點
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.setFillColor(UIColor.systemRed.cgColor)
        let circleRect = CGRect(
            x: bounds.width / 2 - 10,
            y: bounds.height / 2 - 10,
            width: 20,
            height: 20
        )
        context.fillEllipse(in: circleRect)
    }
    
    // MARK: - Deinitialization
    deinit {
        log("deinit - View 被銷毀")
    }
    
    // MARK: - Helper Methods
    /// 記錄日誌的輔助方法
    private func log(_ message: String) {
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        print("[\(timestamp)] [\(viewName)] \(message)")
    }
}

// MARK: - Demo View Controller
/// 演示 UIView 生命週期的 ViewController
class UIViewLifeCycleDemoViewController: UIViewController {
    
    // UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let logTextView = UITextView()
    private var demoView: LifeCycleView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "UIView 生命週期演示"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupButtons()
        
        print("\n=== UIView 生命週期演示開始 ===\n")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup log text view
        logTextView.translatesAutoresizingMaskIntoConstraints = false
        logTextView.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        logTextView.isEditable = false
        logTextView.backgroundColor = .systemGray6
        logTextView.layer.cornerRadius = 8
        logTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        contentView.addSubview(logTextView)
        
        // Constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            logTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 220),
            logTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logTextView.heightAnchor.constraint(equalToConstant: 300),
            logTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupButtons() {
        let buttonTitles = [
            "創建並添加 View",
            "改變 View Frame",
            "觸發重繪",
            "移除 View",
            "清空日誌"
        ]
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        for (index, title) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    // MARK: - Button Actions
    @objc private func buttonTapped(_ sender: UIButton) {
        logToTextView("\n--- 按鈕操作: \(sender.titleLabel?.text ?? "") ---")
        
        switch sender.tag {
        case 0: // 創建並添加 View
            createAndAddView()
        case 1: // 改變 View Frame
            changeViewFrame()
        case 2: // 觸發重繪
            triggerRedraw()
        case 3: // 移除 View
            removeView()
        case 4: // 清空日誌
            logTextView.text = "日誌已清空\n"
        default:
            break
        }
    }
    
    // MARK: - Demo Actions
    /// 創建並添加 View
    /// 演示: init -> willMove(toSuperview:) -> didMoveToSuperview() -> willMove(toWindow:) -> didMoveToWindow() -> layoutSubviews() -> draw()
    private func createAndAddView() {
        guard demoView == nil else {
            logToTextView("⚠️ View 已存在，請先移除")
            return
        }
        
        logToTextView("開始創建 View...")
        
        // 創建 View（觸發 init）
        demoView = LifeCycleView(
            frame: CGRect(x: 50, y: 280, width: view.bounds.width - 100, height: 150),
            name: "Demo View"
        )
        
        // 添加到視圖層級（觸發 willMove/didMove 系列方法）
        if let demoView = demoView {
            view.addSubview(demoView)
            // 添加標籤
            let label = UILabel()
            label.text = "這是演示 View"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            demoView.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: demoView.centerXAnchor),
                label.bottomAnchor.constraint(equalTo: demoView.bottomAnchor, constant: -16)
            ])
        }
        
        logToTextView("✅ View 創建並添加完成")
    }
    
    /// 改變 View 的 Frame
    /// 演示: layoutSubviews() 會被調用
    private func changeViewFrame() {
        guard let demoView = demoView else {
            logToTextView("⚠️ 請先創建 View")
            return
        }
        
        logToTextView("改變 View Frame...")
        
        UIView.animate(withDuration: 0.3) {
            // 改變 frame 會觸發 layoutSubviews
            let randomHeight = CGFloat.random(in: 100...200)
            demoView.frame.size.height = randomHeight
        }
        
        logToTextView("✅ Frame 改變完成")
    }
    
    /// 觸發重繪
    /// 演示: draw(_:) 會被調用
    private func triggerRedraw() {
        guard let demoView = demoView else {
            logToTextView("⚠️ 請先創建 View")
            return
        }
        
        logToTextView("觸發 View 重繪...")
        
        // 使用 setNeedsDisplay() 標記需要重繪
        demoView.setNeedsDisplay()
        
        logToTextView("✅ 重繪觸發完成（draw 方法將在下一個繪製週期被調用）")
    }
    
    /// 移除 View
    /// 演示: willMove(toWindow: nil) -> didMoveToWindow() -> willMove(toSuperview: nil) -> didMoveToSuperview()
    private func removeView() {
        guard let demoView = demoView else {
            logToTextView("⚠️ 沒有可移除的 View")
            return
        }
        
        logToTextView("移除 View...")
        
        // 從父視圖移除（觸發移除相關的生命週期方法）
        demoView.removeFromSuperview()
        self.demoView = nil
        
        logToTextView("✅ View 移除完成")
    }
    
    // MARK: - Helper
    private func logToTextView(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
            self?.logTextView.text += "[\(timestamp)] \(message)\n"
            
            // 自動滾動到底部
            let range = NSRange(location: (self?.logTextView.text.count ?? 0) - 1, length: 1)
            self?.logTextView.scrollRangeToVisible(range)
        }
    }
}

