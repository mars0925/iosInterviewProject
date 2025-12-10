//
//  CallbackDemoViewController.swift
//  InterviewDemoProject
//
//  Callback (回調) 演示
//  展示 iOS 中各種 Callback 的實現方式和使用場景
//

import UIKit

// MARK: - Data Models

/// User model for demonstration
struct User {
    let id: Int
    let name: String
}

/// Custom error type
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

// MARK: - Network Service (Callback 範例)

/// Network service demonstrating different callback patterns
class NetworkService {
    
    // MARK: 1. Simple Closure Callback
    
    /// Fetch user with simple closure callback
    /// - Parameter completion: Callback closure that receives optional User
    func fetchUser(completion: @escaping (User?) -> Void) {
        // Simulate async network request
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let user = User(id: 1, name: "張三")
            
            // Execute callback on main thread
            DispatchQueue.main.async {
                completion(user)
            }
        }
    }
    
    // MARK: 2. Result Type Callback (推薦做法)
    
    /// Fetch user with Result type callback
    /// This is the recommended approach as it handles success and failure cases clearly
    /// - Parameter completion: Callback with Result type
    func fetchUserWithResult(completion: @escaping (Result<User, NetworkError>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            // Simulate random success/failure
            let isSuccess = Bool.random()
            
            DispatchQueue.main.async {
                if isSuccess {
                    let user = User(id: 2, name: "李四")
                    completion(.success(user))
                } else {
                    completion(.failure(.noData))
                }
            }
        }
    }
    
    // MARK: 3. Multiple Callbacks
    
    /// Fetch data with separate success and failure callbacks
    /// - Parameters:
    ///   - success: Called when request succeeds
    ///   - failure: Called when request fails
    func fetchData(
        success: @escaping (String) -> Void,
        failure: @escaping (Error) -> Void
    ) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            let isSuccess = Bool.random()
            
            DispatchQueue.main.async {
                if isSuccess {
                    success("Data loaded successfully")
                } else {
                    failure(NetworkError.noData)
                }
            }
        }
    }
    
    // MARK: 4. Progress Callback
    
    /// Download with progress callback
    /// - Parameters:
    ///   - progress: Called periodically with download progress (0.0 to 1.0)
    ///   - completion: Called when download completes
    func downloadFile(
        progress: @escaping (Double) -> Void,
        completion: @escaping (Bool) -> Void
    ) {
        var currentProgress = 0.0
        
        // Simulate download progress
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            currentProgress += 0.2
            progress(currentProgress)
            
            if currentProgress >= 1.0 {
                timer.invalidate()
                completion(true)
            }
        }
    }
}

// MARK: - Main View Controller

class CallbackDemoViewController: UIViewController {
    
    // MARK: - Properties
    
    private let networkService = NetworkService()
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let resultLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Callback Demo"
        view.backgroundColor = .systemBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup stack view
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        // Setup result label
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
        resultLabel.font = .systemFont(ofSize: 14)
        resultLabel.textColor = .secondaryLabel
        resultLabel.text = "點擊按鈕查看不同的 Callback 範例"
        
        // Setup progress view
        progressView.progress = 0.0
        progressView.isHidden = true
        
        // Add demo sections
        addSection(title: "1. 簡單 Closure Callback", buttonTitle: "獲取用戶資料") {
            [weak self] in
            self?.demoSimpleCallback()
        }
        
        addSection(title: "2. Result Type Callback (推薦)", buttonTitle: "獲取用戶資料（Result）") {
            [weak self] in
            self?.demoResultCallback()
        }
        
        addSection(title: "3. 多個 Callback", buttonTitle: "獲取數據") {
            [weak self] in
            self?.demoMultipleCallbacks()
        }
        
        addSection(title: "4. Progress Callback", buttonTitle: "下載文件") {
            [weak self] in
            self?.demoProgressCallback()
        }
        
        addSection(title: "5. 動畫 Completion Callback", buttonTitle: "執行動畫") {
            [weak self] in
            self?.demoAnimationCallback()
        }
        
        addSection(title: "6. Alert Callback", buttonTitle: "顯示彈窗") {
            [weak self] in
            self?.demoAlertCallback()
        }
        
        stackView.addArrangedSubview(resultLabel)
        stackView.addArrangedSubview(progressView)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])
    }
    
    /// Add a demo section with title and button
    private func addSection(title: String, buttonTitle: String, action: @escaping () -> Void) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .label
        
        let button = UIButton(type: .system)
        button.setTitle(buttonTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Store action in button using associated object pattern
        let actionWrapper = ActionWrapper(action: action)
        objc_setAssociatedObject(button, &AssociatedKeys.action, actionWrapper, .OBJC_ASSOCIATION_RETAIN)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(button)
        
        // Add separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
        stackView.addArrangedSubview(separator)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        if let actionWrapper = objc_getAssociatedObject(sender, &AssociatedKeys.action) as? ActionWrapper {
            actionWrapper.action()
        }
    }
    
    // MARK: - Demo Methods
    
    /// Demo 1: Simple closure callback
    private func demoSimpleCallback() {
        resultLabel.text = "載入中..."
        
        // 使用 [weak self] 避免循環引用
        networkService.fetchUser { [weak self] user in
            guard let self = self else { return }
            
            if let user = user {
                self.resultLabel.text = "✅ 成功獲取用戶\nID: \(user.id)\n名稱: \(user.name)"
                self.resultLabel.textColor = .systemGreen
            } else {
                self.resultLabel.text = "❌ 獲取用戶失敗"
                self.resultLabel.textColor = .systemRed
            }
        }
    }
    
    /// Demo 2: Result type callback (recommended approach)
    private func demoResultCallback() {
        resultLabel.text = "載入中..."
        
        networkService.fetchUserWithResult { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let user):
                self.resultLabel.text = "✅ 成功獲取用戶\nID: \(user.id)\n名稱: \(user.name)"
                self.resultLabel.textColor = .systemGreen
                
            case .failure(let error):
                self.resultLabel.text = "❌ 獲取失敗\n錯誤: \(error)"
                self.resultLabel.textColor = .systemRed
            }
        }
    }
    
    /// Demo 3: Multiple callbacks
    private func demoMultipleCallbacks() {
        resultLabel.text = "載入中..."
        
        networkService.fetchData(
            success: { [weak self] data in
                self?.resultLabel.text = "✅ 成功\n\(data)"
                self?.resultLabel.textColor = .systemGreen
            },
            failure: { [weak self] error in
                self?.resultLabel.text = "❌ 失敗\n錯誤: \(error.localizedDescription)"
                self?.resultLabel.textColor = .systemRed
            }
        )
    }
    
    /// Demo 4: Progress callback
    private func demoProgressCallback() {
        resultLabel.text = "下載中..."
        progressView.isHidden = false
        progressView.progress = 0.0
        
        networkService.downloadFile(
            progress: { [weak self] progress in
                // Progress callback - called multiple times
                self?.progressView.progress = Float(progress)
                self?.resultLabel.text = "下載中... \(Int(progress * 100))%"
            },
            completion: { [weak self] success in
                // Completion callback - called once
                self?.progressView.isHidden = true
                if success {
                    self?.resultLabel.text = "✅ 下載完成！"
                    self?.resultLabel.textColor = .systemGreen
                }
            }
        )
    }
    
    /// Demo 5: Animation completion callback
    private func demoAnimationCallback() {
        resultLabel.text = "執行動畫中..."
        
        // Create a temporary view for animation
        let animatedView = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
        animatedView.backgroundColor = .systemBlue
        animatedView.center = view.center
        view.addSubview(animatedView)
        
        // Animate with completion callback
        UIView.animate(
            withDuration: 1.0,
            animations: {
                // Animation block
                animatedView.alpha = 0.0
                animatedView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            },
            completion: { [weak self] finished in
                // Completion callback
                animatedView.removeFromSuperview()
                
                if finished {
                    self?.resultLabel.text = "✅ 動畫完成！"
                    self?.resultLabel.textColor = .systemGreen
                } else {
                    self?.resultLabel.text = "⚠️ 動畫被中斷"
                    self?.resultLabel.textColor = .systemOrange
                }
            }
        )
    }
    
    /// Demo 6: Alert action callback
    private func demoAlertCallback() {
        let alert = UIAlertController(
            title: "Callback Demo",
            message: "選擇一個選項",
            preferredStyle: .alert
        )
        
        // Action 1 callback
        alert.addAction(UIAlertAction(title: "選項 A", style: .default) { [weak self] _ in
            self?.resultLabel.text = "✅ 你選擇了：選項 A"
            self?.resultLabel.textColor = .systemBlue
        })
        
        // Action 2 callback
        alert.addAction(UIAlertAction(title: "選項 B", style: .default) { [weak self] _ in
            self?.resultLabel.text = "✅ 你選擇了：選項 B"
            self?.resultLabel.textColor = .systemPurple
        })
        
        // Cancel callback
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { [weak self] _ in
            self?.resultLabel.text = "❌ 已取消"
            self?.resultLabel.textColor = .systemGray
        })
        
        present(alert, animated: true)
    }
}

// MARK: - Helper Classes

/// Wrapper class to store closure action
private class ActionWrapper {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
}

/// Associated keys for storing action
private struct AssociatedKeys {
    static var action = "action"
}

