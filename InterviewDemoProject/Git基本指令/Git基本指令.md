# Git 基本指令與 Git Merge 操作指南

## 一、Git 基本配置指令 main

this is form main
this is from feature2

### 1.1 設定使用者資訊
```bash
# 設定全域使用者名稱
git config --global user.name "Your Name"

# 設定全域使用者信箱
git config --global user.email "your.email@example.com"

# 查看所有配置
git config --list

# 查看特定配置
git config user.name
```

### 1.2 初始化倉庫
```bash
# 在當前目錄初始化 Git 倉庫
git init

# 複製遠端倉庫到本地
git clone <repository-url>
```

## 二、基本操作指令

### 2.1 檢查狀態
```bash
# 查看工作區狀態
git status

# 查看簡短狀態
git status -s
```

### 2.2 添加檔案到暫存區
```bash
# 添加指定檔案
git add <filename>

# 添加所有修改的檔案
git add .

# 添加所有 .swift 檔案
git add *.swift

# 互動式添加
git add -i
```

### 2.3 提交變更
```bash
# 提交暫存區的變更
git commit -m "commit message"

# 添加並提交（跳過 git add）
git commit -am "commit message"

# 修改最後一次提交
git commit --amend
```

### 2.4 查看歷史記錄
```bash
# 查看提交歷史
git log

# 查看簡潔的提交歷史
git log --oneline

# 查看圖形化的分支歷史
git log --graph --oneline --all

# 查看最近 5 筆提交
git log -5

# 查看特定檔案的歷史
git log <filename>
```

### 2.5 查看差異
```bash
# 查看工作區與暫存區的差異
git diff

# 查看暫存區與最後一次提交的差異
git diff --staged

# 查看兩個提交之間的差異
git diff <commit1> <commit2>
```

### 2.6 撤銷操作
```bash
# 取消暫存（保留修改）
git reset HEAD <filename>

# 丟棄工作區的修改
git checkout -- <filename>

# 回退到指定提交（保留修改）
git reset --soft <commit>

# 回退到指定提交（不保留修改）
git reset --hard <commit>

# 恢復指定提交的內容（建立新提交）
git revert <commit>
```

## 三、分支操作指令

### 3.1 分支管理
```bash
# 查看所有本地分支
git branch

# 查看所有分支（包含遠端）
git branch -a

# 建立新分支
git branch <branch-name>

# 建立並切換到新分支
git checkout -b <branch-name>
# 或使用新指令
git switch -c <branch-name>

# 切換分支
git checkout <branch-name>
# 或使用新指令
git switch <branch-name>

# 刪除分支
git branch -d <branch-name>

# 強制刪除分支（未合併的分支）
git branch -D <branch-name>

# 重新命名分支
git branch -m <old-name> <new-name>
```

### 3.2 查看分支資訊
```bash
# 查看每個分支的最後一次提交
git branch -v

# 查看已合併到當前分支的分支
git branch --merged

# 查看未合併到當前分支的分支
git branch --no-merged
```

## 四、Git Merge 詳細說明

### 4.1 什麼是 Git Merge

Git Merge 是將兩個或多個開發歷史合併在一起的操作。它會將指定分支的變更整合到當前分支中。

### 4.2 Merge 的類型

#### 1. Fast-Forward Merge（快進合併）

**條件**：當前分支沒有新的提交，目標分支是當前分支的直接下游。

```bash
# 假設在 main 分支
git merge feature-branch
```

**特點**：
- 不會產生新的合併提交
- 只是移動分支指標
- 保持線性歷史

**圖示**：
```
Before:
main:    A -- B
               \
feature:        C -- D

After (Fast-Forward):
main:    A -- B -- C -- D
feature:              ^
```

#### 2. Three-Way Merge（三方合併）

**條件**：當前分支和目標分支都有各自的新提交。

```bash
# 假設在 main 分支
git merge feature-branch
```

**特點**：
- 會產生一個新的合併提交（Merge Commit）
- 保留兩個分支的完整歷史
- 合併提交有兩個父節點

**圖示**：
```
Before:
        C -- D (feature)
       /
A -- B -- E -- F (main)

After (Three-Way Merge):
        C -- D (feature)
       /      \
A -- B -- E -- F -- M (main, M 是合併提交)
```

### 4.3 基本 Merge 操作

```bash
# 1. 確認當前分支
git branch

# 2. 切換到要接收變更的分支（通常是 main 或 develop）
git checkout main

# 3. 確保分支是最新的
git pull

# 4. 合併目標分支
git merge feature-branch

# 5. 如果沒有衝突，推送到遠端
git push origin main
```

### 4.4 Merge 選項

```bash
# 強制產生合併提交（即使可以 Fast-Forward）
git merge --no-ff feature-branch

# 只有在可以 Fast-Forward 時才合併
git merge --ff-only feature-branch

# 合併但不自動提交（用於檢查）
git merge --no-commit feature-branch

# 壓縮合併（將所有變更合併為一個提交）
git merge --squash feature-branch
```

### 4.5 處理合併衝突

#### 什麼是合併衝突？

當兩個分支修改了同一個檔案的同一部分時，Git 無法自動決定保留哪個版本，就會產生衝突。

#### 衝突標記格式

```
<<<<<<< HEAD
這是當前分支的內容
=======
這是要合併的分支的內容
>>>>>>> feature-branch
```

#### 解決衝突步驟

**步驟 1：執行合併**
```bash
git merge feature-branch
# 如果有衝突，會看到類似訊息：
# CONFLICT (content): Merge conflict in filename.swift
# Automatic merge failed; fix conflicts and then commit the result.
```

**步驟 2：查看衝突的檔案**
```bash
# 查看哪些檔案有衝突
git status

# 查看衝突的詳細內容
git diff
```

**步驟 3：手動解決衝突**
```bash
# 使用編輯器打開衝突檔案
# 編輯檔案，移除衝突標記，保留需要的內容

# 範例：原始衝突
<<<<<<< HEAD
let message = "Hello from main"
=======
let message = "Hello from feature"
>>>>>>> feature-branch

# 解決後：
let message = "Hello from merged version"
```

**步驟 4：標記衝突已解決**
```bash
# 添加已解決的檔案
git add <resolved-file>

# 或添加所有已解決的檔案
git add .
```

**步驟 5：完成合併**
```bash
# 提交合併
git commit

# Git 會自動產生合併提交訊息
# 也可以自訂訊息：
git commit -m "Merge feature-branch: resolved conflicts"
```

**取消合併**
```bash
# 如果想放棄合併
git merge --abort
```

### 4.6 Merge vs Rebase

#### Git Merge
```bash
git merge feature-branch
```

**優點**：
- 保留完整的歷史記錄
- 可以清楚看到分支的合併點
- 更安全，不會改變現有的提交

**缺點**：
- 會產生額外的合併提交
- 歷史記錄可能變得複雜

#### Git Rebase
```bash
git rebase main
```

**優點**：
- 產生線性的歷史記錄
- 更乾淨、更容易閱讀

**缺點**：
- 會改寫歷史（不要在公共分支上使用）
- 可能需要解決多次衝突

**使用建議**：
- 在自己的 feature 分支上使用 rebase 保持乾淨
- 將 feature 合併到 main 時使用 merge

## 五、遠端操作指令

### 5.1 遠端倉庫管理
```bash
# 查看遠端倉庫
git remote -v

# 添加遠端倉庫
git remote add origin <url>

# 移除遠端倉庫
git remote remove origin

# 重新命名遠端倉庫
git remote rename origin upstream
```

### 5.2 推送和拉取
```bash
# 推送到遠端分支
git push origin <branch-name>

# 推送並設定追蹤
git push -u origin <branch-name>

# 強制推送（危險！）
git push --force origin <branch-name>

# 從遠端拉取並合併
git pull origin <branch-name>

# 從遠端拉取但不合併
git fetch origin

# 拉取所有遠端分支
git fetch --all
```

### 5.3 追蹤遠端分支
```bash
# 設定當前分支追蹤遠端分支
git branch --set-upstream-to=origin/<branch-name>

# 查看追蹤關係
git branch -vv
```

## 六、標籤管理

### 6.1 建立標籤
```bash
# 建立輕量標籤
git tag v1.0.0

# 建立附註標籤
git tag -a v1.0.0 -m "Release version 1.0.0"

# 對指定提交建立標籤
git tag -a v1.0.0 <commit-hash> -m "message"
```

### 6.2 查看和管理標籤
```bash
# 查看所有標籤
git tag

# 查看標籤詳細資訊
git show v1.0.0

# 刪除標籤
git tag -d v1.0.0

# 推送標籤到遠端
git push origin v1.0.0

# 推送所有標籤
git push origin --tags

# 刪除遠端標籤
git push origin :refs/tags/v1.0.0
```

## 七、實用技巧

### 7.1 暫存工作
```bash
# 暫存當前工作
git stash

# 暫存包含未追蹤的檔案
git stash -u

# 查看暫存列表
git stash list

# 恢復最近的暫存
git stash pop

# 恢復指定的暫存
git stash apply stash@{0}

# 刪除暫存
git stash drop stash@{0}

# 清空所有暫存
git stash clear
```

### 7.2 Cherry-pick
```bash
# 挑選特定提交到當前分支
git cherry-pick <commit-hash>

# 挑選多個提交
git cherry-pick <commit1> <commit2>

# 挑選但不自動提交
git cherry-pick -n <commit-hash>
```

### 7.3 清理
```bash
# 刪除未追蹤的檔案（預覽）
git clean -n

# 刪除未追蹤的檔案
git clean -f

# 刪除未追蹤的檔案和目錄
git clean -fd

# 刪除被忽略的檔案
git clean -fX
```

## 八、常見工作流程

### 8.1 Feature Branch 工作流程

```bash
# 1. 從 main 建立新的 feature 分支
git checkout main
git pull origin main
git checkout -b feature/new-feature

# 2. 在 feature 分支上開發
git add .
git commit -m "Add new feature"

# 3. 推送 feature 分支到遠端
git push -u origin feature/new-feature

# 4. 持續開發和提交
git add .
git commit -m "Update feature"
git push

# 5. 完成開發後，更新 main 分支
git checkout main
git pull origin main

# 6. 合併 feature 到 main
git merge --no-ff feature/new-feature

# 7. 推送合併後的 main
git push origin main

# 8. 刪除 feature 分支
git branch -d feature/new-feature
git push origin --delete feature/new-feature
```

### 8.2 Hotfix 工作流程

```bash
# 1. 從 main 建立 hotfix 分支
git checkout main
git checkout -b hotfix/critical-bug

# 2. 修復 bug
git add .
git commit -m "Fix critical bug"

# 3. 合併回 main
git checkout main
git merge --no-ff hotfix/critical-bug

# 4. 如果有 develop 分支，也要合併
git checkout develop
git merge --no-ff hotfix/critical-bug

# 5. 推送並刪除 hotfix 分支
git push origin main
git push origin develop
git branch -d hotfix/critical-bug
```

## 九、最佳實踐

### 9.1 提交訊息規範

```bash
# 好的提交訊息格式
<type>: <subject>

<body>

<footer>

# Type 類型：
# feat: 新功能
# fix: 修復 bug
# docs: 文件變更
# style: 格式調整（不影響代碼運行）
# refactor: 重構
# test: 測試相關
# chore: 建構工具或輔助工具的變更

# 範例：
git commit -m "feat: add user authentication

Implement JWT-based authentication system
- Add login and logout endpoints
- Add middleware for token validation
- Update user model

Closes #123"
```

### 9.2 分支命名規範

```bash
# 功能分支
feature/<feature-name>
feature/user-login
feature/payment-integration

# Bug 修復分支
fix/<bug-name>
fix/login-error
fix/memory-leak

# 緊急修復分支
hotfix/<issue-name>
hotfix/security-patch

# 發布分支
release/<version>
release/v1.2.0

# 實驗性分支
experiment/<experiment-name>
experiment/new-ui
```

### 9.3 日常工作建議

1. **頻繁提交**：小步快跑，每個邏輯單元都提交
2. **描述清晰**：寫清楚為什麼改，而不只是改了什麼
3. **先拉後推**：推送前先 pull，避免衝突
4. **不要提交機密**：密碼、API key 等敏感資訊不要提交
5. **使用 .gitignore**：排除不需要版本控制的檔案
6. **定期整理**：刪除已合併的分支
7. **保護主分支**：main/master 分支應該受保護

## 十、Git Merge 面試常見問題

### Q1: Fast-Forward 和 Three-Way Merge 的區別？

**答案**：
- **Fast-Forward**：當目標分支是當前分支的直接後代時，Git 只需移動指標，不產生新提交
- **Three-Way Merge**：當兩個分支有分歧時，Git 會建立一個新的合併提交，包含兩個分支的變更

### Q2: 如何避免合併衝突？

**答案**：
1. 頻繁地從主分支同步變更
2. 保持提交的原子性和獨立性
3. 團隊成員避免同時修改相同的檔案
4. 使用 feature 分支隔離開發
5. 定期進行代碼審查

### Q3: Merge 和 Rebase 應該如何選擇？

**答案**：
- **使用 Merge**：
  - 合併公共分支（如 feature 到 main）
  - 想保留完整的歷史記錄
  - 多人協作的分支
  
- **使用 Rebase**：
  - 整理個人的 feature 分支
  - 想要線性的歷史記錄
  - 同步主分支的變更到自己的分支

**黃金法則**：永遠不要 rebase 公共分支！

### Q4: 什麼時候使用 --no-ff？

**答案**：
使用 `git merge --no-ff` 會強制產生合併提交，即使可以 fast-forward。

**優點**：
- 保留分支存在的資訊
- 可以看出哪些提交是一起合併的
- 更容易回退整個功能

**適用場景**：
- 合併 feature 分支到 main
- 需要保留完整的分支結構

### Q5: 如何撤銷一個已經推送的 merge？

**答案**：

```bash
# 方法 1：使用 revert（推薦，因為不會改變歷史）
git revert -m 1 <merge-commit-hash>
git push origin main

# 方法 2：使用 reset（危險，會改變歷史）
git reset --hard <commit-before-merge>
git push --force origin main  # 需要團隊協調
```

## 總結

Git 是現代軟體開發不可或缺的工具，掌握 Git Merge 對於團隊協作至關重要。記住：

1. **理解原理**：知道 fast-forward 和 three-way merge 的區別
2. **處理衝突**：學會冷靜地解決合併衝突
3. **保持整潔**：使用適當的工作流程保持歷史記錄清晰
4. **團隊協作**：遵循團隊的分支策略和命名規範
5. **謹慎操作**：特別是涉及 force push 和 rebase 公共分支的操作

持續練習和實際應用這些指令，會讓你在團隊開發中更加得心應手！

