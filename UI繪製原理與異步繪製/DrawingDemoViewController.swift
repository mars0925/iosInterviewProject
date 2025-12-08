//
//  DrawingDemoViewController.swift
//  InterviewDemoProject
//
//  UI 繪製演示：對比同步繪製和異步繪製的性能差異

import UIKit

class DrawingDemoViewController: UIViewController {
    
    // MARK: - UI Components
    
    /// 標題標籤
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "UI 繪製原理演示"
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 說明標籤
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "拖動滑桿測試繪製性能\n觀察主線程是否卡頓"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 同步繪製容器
    private let syncContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemRed.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 同步繪製標籤
    private let syncLabel: UILabel = {
        let label = UILabel()
        label.text = "🔴 同步繪製（會卡頓）"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .systemRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 同步繪製 View
    private let syncDrawingView: SyncDrawingView = {
        let view = SyncDrawingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 異步繪製容器
    private let asyncContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.systemGreen.cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 異步繪製標籤
    private let asyncLabel: UILabel = {
        let label = UILabel()
        label.text = "🟢 異步繪製（流暢）"
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .systemGreen
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 異步繪製 View
    private let asyncDrawingView: AsyncDrawingView = {
        let view = AsyncDrawingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 控制面板
    private let controlPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// 滑桿標籤
    private let sliderLabel: UILabel = {
        let label = UILabel()
        label.text = "拖動滑桿測試主線程響應："
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 測試滑桿：用於檢測主線程是否卡頓
    private let testSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.value = 50
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()
    
    /// 滑桿數值標籤
    private let sliderValueLabel: UILabel = {
        let label = UILabel()
        label.text = "50"
        label.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 刷新按鈕
    private let refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("🔄 觸發重繪", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// 切換複雜繪製開關
    private let complexDrawingSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.translatesAutoresizingMaskIntoConstraints = false
        return toggle
    }()
    
    /// 複雜繪製標籤
    private let complexDrawingLabel: UILabel = {
        let label = UILabel()
        label.text = "繪製複雜圖形"
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 重繪計數器
    private var redrawCount = 0
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加所有子視圖
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        
        view.addSubview(syncContainerView)
        syncContainerView.addSubview(syncLabel)
        syncContainerView.addSubview(syncDrawingView)
        
        view.addSubview(asyncContainerView)
        asyncContainerView.addSubview(asyncLabel)
        asyncContainerView.addSubview(asyncDrawingView)
        
        view.addSubview(controlPanel)
        controlPanel.addSubview(sliderLabel)
        controlPanel.addSubview(testSlider)
        controlPanel.addSubview(sliderValueLabel)
        controlPanel.addSubview(refreshButton)
        controlPanel.addSubview(complexDrawingLabel)
        controlPanel.addSubview(complexDrawingSwitch)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // 標題
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 說明
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 同步繪製容器
            syncContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            syncContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            syncContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            syncContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            // 同步繪製標籤
            syncLabel.topAnchor.constraint(equalTo: syncContainerView.topAnchor, constant: 8),
            syncLabel.leadingAnchor.constraint(equalTo: syncContainerView.leadingAnchor, constant: 12),
            
            // 同步繪製視圖
            syncDrawingView.topAnchor.constraint(equalTo: syncLabel.bottomAnchor, constant: 8),
            syncDrawingView.leadingAnchor.constraint(equalTo: syncContainerView.leadingAnchor, constant: 8),
            syncDrawingView.trailingAnchor.constraint(equalTo: syncContainerView.trailingAnchor, constant: -8),
            syncDrawingView.bottomAnchor.constraint(equalTo: syncContainerView.bottomAnchor, constant: -8),
            
            // 異步繪製容器
            asyncContainerView.topAnchor.constraint(equalTo: syncContainerView.bottomAnchor, constant: 20),
            asyncContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            asyncContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            asyncContainerView.heightAnchor.constraint(equalToConstant: 200),
            
            // 異步繪製標籤
            asyncLabel.topAnchor.constraint(equalTo: asyncContainerView.topAnchor, constant: 8),
            asyncLabel.leadingAnchor.constraint(equalTo: asyncContainerView.leadingAnchor, constant: 12),
            
            // 異步繪製視圖
            asyncDrawingView.topAnchor.constraint(equalTo: asyncLabel.bottomAnchor, constant: 8),
            asyncDrawingView.leadingAnchor.constraint(equalTo: asyncContainerView.leadingAnchor, constant: 8),
            asyncDrawingView.trailingAnchor.constraint(equalTo: asyncContainerView.trailingAnchor, constant: -8),
            asyncDrawingView.bottomAnchor.constraint(equalTo: asyncContainerView.bottomAnchor, constant: -8),
            
            // 控制面板
            controlPanel.topAnchor.constraint(equalTo: asyncContainerView.bottomAnchor, constant: 20),
            controlPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            controlPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            controlPanel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            // 滑桿標籤
            sliderLabel.topAnchor.constraint(equalTo: controlPanel.topAnchor, constant: 16),
            sliderLabel.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            sliderLabel.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            
            // 測試滑桿
            testSlider.topAnchor.constraint(equalTo: sliderLabel.bottomAnchor, constant: 8),
            testSlider.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            testSlider.trailingAnchor.constraint(equalTo: sliderValueLabel.leadingAnchor, constant: -8),
            
            // 滑桿數值
            sliderValueLabel.centerYAnchor.constraint(equalTo: testSlider.centerYAnchor),
            sliderValueLabel.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            sliderValueLabel.widthAnchor.constraint(equalToConstant: 40),
            
            // 複雜繪製標籤
            complexDrawingLabel.topAnchor.constraint(equalTo: testSlider.bottomAnchor, constant: 16),
            complexDrawingLabel.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            
            // 複雜繪製開關
            complexDrawingSwitch.centerYAnchor.constraint(equalTo: complexDrawingLabel.centerYAnchor),
            complexDrawingSwitch.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            
            // 刷新按鈕
            refreshButton.topAnchor.constraint(equalTo: complexDrawingLabel.bottomAnchor, constant: 16),
            refreshButton.leadingAnchor.constraint(equalTo: controlPanel.leadingAnchor, constant: 16),
            refreshButton.trailingAnchor.constraint(equalTo: controlPanel.trailingAnchor, constant: -16),
            refreshButton.heightAnchor.constraint(equalToConstant: 44),
            refreshButton.bottomAnchor.constraint(equalTo: controlPanel.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupActions() {
        // 滑桿事件：用於測試主線程響應
        testSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        
        // 刷新按鈕：觸發重繪
        refreshButton.addTarget(self, action: #selector(refreshButtonTapped), for: .touchUpInside)
        
        // 複雜繪製開關
        complexDrawingSwitch.addTarget(self, action: #selector(complexDrawingSwitchChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    /// 滑桿值改變：更新顯示，同時測試主線程響應
    /// 如果滑桿拖動不流暢，說明主線程被阻塞
    @objc private func sliderValueChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        sliderValueLabel.text = "\(value)"
        
        // 這個操作在主線程執行，如果繪製阻塞了主線程，滑桿會卡頓
    }
    
    /// 刷新按鈕點擊：觸發兩個視圖重繪
    @objc private func refreshButtonTapped() {
        redrawCount += 1
        
        // 生成新的測試內容
        let newText = generateTestText()
        let newColor = generateRandomColor()
        
        print("\n" + String(repeating: "=", count: 50))
        print("第 \(redrawCount) 次重繪開始")
        print(String(repeating: "=", count: 50))
        
        // 同時觸發兩個視圖的重繪
        // 觀察控制台輸出的耗時差異
        syncDrawingView.updateContent(text: newText, color: newColor)
        asyncDrawingView.updateContent(text: newText, color: newColor)
        
        // 添加觸覺反饋
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    /// 複雜繪製開關改變
    @objc private func complexDrawingSwitchChanged(_ sender: UISwitch) {
        syncDrawingView.drawComplexShapes = sender.isOn
        asyncDrawingView.drawComplexShapes = sender.isOn
        
        print("複雜繪製：\(sender.isOn ? "開啟" : "關閉")")
    }
    
    // MARK: - Helper Methods
    
    /// 生成測試文字
    private func generateTestText() -> String {
        let templates = [
            "這是第 \(redrawCount) 次繪製測試\n拖動下方滑桿可以測試主線程響應性\n同步繪製會阻塞主線程導致卡頓",
            "UI 繪製性能測試 #\(redrawCount)\n觀察兩種繪製方式的差異\n異步繪製在後台線程執行",
            "繪製測試 Round \(redrawCount)\n注意觀察控制台的耗時輸出\n紅色框：同步  綠色框：異步",
            "Performance Test \(redrawCount)\n同步繪製：主線程執行\n異步繪製：後台線程執行",
        ]
        return templates[redrawCount % templates.count]
    }
    
    /// 生成隨機顏色
    private func generateRandomColor() -> UIColor {
        let colors: [UIColor] = [
            .black, .darkGray, .systemBlue, .systemPurple,
            .systemIndigo, .systemBrown, .systemTeal
        ]
        return colors[redrawCount % colors.count]
    }
}

