//
//  MVCDemoViewController.swift
//  InterviewDemoProject
//
//  MVC 架構演示
//  展示 Model-View-Controller 三個組件如何協作
//

import UIKit

// MARK: - Model（模型層）
// 負責：數據管理和業務邏輯

/// User 模型 - 代表用戶的數據結構
class UserInfo {
    // 用戶屬性
    var name: String
    var email: String
    var age: Int
    
    // 初始化方法
    init(name: String, email: String, age: Int) {
        self.name = name
        self.email = email
        self.age = age
    }
    
    // 業務邏輯：驗證用戶年齡是否為成年人
    func isAdult() -> Bool {
        return age >= 18
    }
    
    // 業務邏輯：驗證 email 格式
    func isValidEmail() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    // 業務邏輯：格式化用戶信息
    func getFormattedInfo() -> String {
        return """
        姓名：\(name)
        郵箱：\(email)
        年齡：\(age) 歲
        狀態：\(isAdult() ? "成年" : "未成年")
        """
    }
}

// MARK: - View（視圖層）
// 負責：UI 呈現和用戶交互

/// UserView - 自定義視圖，用於顯示用戶信息
class UserView: UIView {
    
    // MARK: - UI Components
    
    // 顯示用戶信息的標籤
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 狀態指示器（顯示是否成年）
    private let statusIndicator: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 狀態標籤
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    /// 設置 UI 佈局
    private func setupUI() {
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        
        // 添加子視圖
        addSubview(infoLabel)
        addSubview(statusIndicator)
        statusIndicator.addSubview(statusLabel)
        
        // 設置約束
        NSLayoutConstraint.activate([
            // 信息標籤約束
            infoLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            infoLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            // 狀態指示器約束
            statusIndicator.topAnchor.constraint(equalTo: infoLabel.bottomAnchor, constant: 16),
            statusIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusIndicator.widthAnchor.constraint(equalToConstant: 120),
            statusIndicator.heightAnchor.constraint(equalToConstant: 32),
            statusIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
            // 狀態標籤約束
            statusLabel.centerXAnchor.constraint(equalTo: statusIndicator.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: statusIndicator.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    /// 配置視圖顯示內容
    /// - Parameters:
    ///   - info: 要顯示的用戶信息
    ///   - isValid: email 是否有效
    ///   - isAdult: 是否為成年人
    func configure(info: String, isValid: Bool, isAdult: Bool) {
        // View 只負責顯示，不包含業務邏輯
        infoLabel.text = info
        
        // 根據狀態設置顏色
        if !isValid {
            statusIndicator.backgroundColor = UIColor.systemRed.withAlphaComponent(0.2)
            statusLabel.textColor = .systemRed
            statusLabel.text = "郵箱無效"
        } else if isAdult {
            statusIndicator.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.2)
            statusLabel.textColor = .systemGreen
            statusLabel.text = "✓ 已驗證"
        } else {
            statusIndicator.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            statusLabel.textColor = .systemOrange
            statusLabel.text = "未成年"
        }
    }
}

// MARK: - Controller（控制器層）
// 負責：協調 Model 和 View，處理用戶交互和業務流程

/// MVCDemoViewController - 演示 MVC 架構的控制器
class MVCDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    // Model - 用戶數據模型
    private var user: UserInfo?
    
    // View - 自定義用戶信息視圖
    private let userView: UserView = {
        let view = UserView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 輸入欄位容器
    private let inputStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // 姓名輸入框
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "請輸入姓名"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 郵箱輸入框
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "請輸入郵箱"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 年齡輸入框
    private let ageTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "請輸入年齡"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // 更新按鈕
    private let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("更新用戶資料", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // 說明標籤
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.text = """
        MVC 架構演示
        
        Model：User 類（管理數據和業務邏輯）
        View：UserView 類（負責 UI 呈現）
        Controller：本 ViewController（協調兩者）
        """
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupInitialData()
        setupActions()
        
        // 設置導航欄
        title = "MVC 架構演示"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - UI Setup
    
    /// 設置用戶界面
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加子視圖
        view.addSubview(descriptionLabel)
        view.addSubview(inputStackView)
        view.addSubview(updateButton)
        view.addSubview(userView)
        
        // 添加輸入框到堆疊視圖
        inputStackView.addArrangedSubview(nameTextField)
        inputStackView.addArrangedSubview(emailTextField)
        inputStackView.addArrangedSubview(ageTextField)
        
        // 設置約束
        NSLayoutConstraint.activate([
            // 說明標籤
            descriptionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 輸入欄位
            inputStackView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // 更新按鈕
            updateButton.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: 16),
            updateButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            updateButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            updateButton.heightAnchor.constraint(equalToConstant: 50),
            
            // 用戶信息視圖
            userView.topAnchor.constraint(equalTo: updateButton.bottomAnchor, constant: 24),
            userView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            userView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    /// 設置初始數據
    private func setupInitialData() {
        // Controller 創建 Model
        user = UserInfo(name: "張三", email: "zhangsan@example.com", age: 25)
        
        // 填充初始值到輸入框
        if let user = user {
            nameTextField.text = user.name
            emailTextField.text = user.email
            ageTextField.text = "\(user.age)"
        }
        
        // 更新視圖顯示
        updateView()
    }
    
    /// 設置按鈕動作
    private func setupActions() {
        updateButton.addTarget(self, action: #selector(updateButtonTapped), for: .touchUpInside)
        
        // 添加點擊手勢關閉鍵盤
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    /// 更新按鈕點擊事件
    @objc private func updateButtonTapped() {
        // Controller 處理用戶交互
        
        // 1. 獲取輸入
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "請輸入姓名")
            return
        }
        
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "請輸入郵箱")
            return
        }
        
        guard let ageText = ageTextField.text,
              let age = Int(ageText),
              age > 0 && age < 150 else {
            showAlert(message: "請輸入有效的年齡（1-150）")
            return
        }
        
        // 2. 更新 Model
        // 這裡可以創建新的 User 對象，或者更新現有對象
        user = UserInfo(name: name, email: email, age: age)
        
        // 3. 通知更新成功
        showSuccessAnimation()
        
        // 4. 更新 View
        updateView()
        
        // 5. 關閉鍵盤
        dismissKeyboard()
    }
    
    /// 關閉鍵盤
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Helper Methods
    
    /// 更新視圖顯示
    /// Controller 負責從 Model 獲取數據，並更新 View
    private func updateView() {
        guard let user = user else { return }
        
        // 從 Model 獲取數據
        let info = user.getFormattedInfo()
        let isValid = user.isValidEmail()
        let isAdult = user.isAdult()
        
        // 更新 View 顯示
        // Controller 將處理後的數據傳遞給 View
        userView.configure(info: info, isValid: isValid, isAdult: isAdult)
    }
    
    /// 顯示警告訊息
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "提示",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }
    
    /// 顯示成功動畫
    private func showSuccessAnimation() {
        // 按鈕動畫反饋
        UIView.animate(withDuration: 0.1, animations: {
            self.updateButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.updateButton.transform = .identity
            }
        }
        
        // 視圖更新動畫
        UIView.transition(with: userView,
                         duration: 0.3,
                         options: .transitionCrossDissolve,
                         animations: nil)
    }
}

// MARK: - 架構說明總結

/*
 這個演示展示了 MVC 架構的三個核心組件：
 
 1. Model（UserInfo 類）：
    - 管理用戶數據（name, email, age）
    - 包含業務邏輯（isAdult(), isValidEmail()）
    - 不依賴於 View 或 Controller
    - 可以被其他 Controller 重用
 
 2. View（UserView 類）：
    - 負責 UI 呈現
    - 通過 configure() 方法接收數據
    - 不包含業務邏輯
    - 不直接訪問 Model
    - 可以被重用於不同的場景
 
 3. Controller（MVCDemoViewController）：
    - 擁有 Model（user 屬性）
    - 管理 View（userView 屬性）
    - 處理用戶交互（按鈕點擊）
    - 協調 Model 和 View 之間的數據流
    - 包含應用邏輯和流程控制
 
 數據流：
 User Input → View → Controller → Model
                                    ↓
 User Interface ← View ← Controller ←
 
 優點體現：
 ✓ 關注點分離：每個組件職責明確
 ✓ 可重用性：User 和 UserView 可以在其他地方使用
 ✓ 易於理解：結構清晰，代碼組織良好
 
 缺點體現：
 ✗ Controller 仍然承擔較多職責（UI 設置、數據驗證、事件處理）
 ✗ View 和 Controller 耦合（Controller 直接操作 View）
 ✗ 隨著功能增加，Controller 容易變得臃腫
 
 改進建議：
 - 可以引入 Service 層處理數據持久化和網絡請求
 - 可以使用 ViewModel 來處理數據格式化邏輯
 - 可以使用 Coordinator 模式來處理導航邏輯
 - 對於大型項目，考慮使用 MVVM 或 VIPER 架構
 */

