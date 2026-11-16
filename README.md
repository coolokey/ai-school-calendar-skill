# 📅 校園智慧會議行事曆與場地協作系統產生器 (`ai-school-calendar` Skill)

一套專為 **Antigravity / AI Coding Agent** 設計的標準化技能套件（Skill），可協助各級國中小／高中快速建立、客製化、測試與部署具備 **Gemini 2.5 Flash 公文文字與開會通知截圖一鍵速填（Multimodal Vision OCR）**、**場地＋參與人員雙重防衝堂雷達**、**Google Apps Script + Google Sheets 四分頁後台** 與 **會後 AI 推播／議程／會議紀錄草案生成** 的校園智慧行事曆網站。

---

## ✨ 套件核心特色

* **AI 公文與開會通知截圖「一鍵速填」（Gemini 2.5 Flash Vision）**：
  * 支援貼上非結構化公文本文、LINE 處室通知文字，或直接按 **`Ctrl+V` 貼上／拖曳上傳開會通知單截圖、公文照片**。
  * 瀏覽器端自動智慧縮放壓縮圖片，後端自動辨識民國年換算西元年、上下午 24 小時制、校內節次、常用場地、主辦處室與參與單位，一鍵帶入預約表單。
* **日期 × 時間 × 地點 × 參與人員「四維雙重防衝堂雷達」**：
  * 內建校內 10 大標準作息節次（`朝會`、`第1節`～`第8節`、`午休`）複選與 `自訂時間` 自動換算，跨節次勾選自動顯示跳節提醒。
  * 即時偵測同日重疊時段下的 **場地衝突** 與 **參與人員／單位衝堂**（即使在不同會議室，只要「九年級導師」等參與對象重複即刻紅燈預警），並提供 **「✨ 推薦空檔」** 自動尋找場地與人員皆空閒的節次。
  * 向後相容歷史資料：當舊紀錄的「參與單位」欄為空白時，自動從「說明備註」解析 `參加人員：...` 納入防衝堂比對。
* **自由分類配色與四視圖響應式日曆**：
  * 支援自由輸入分類名稱、自訂底色／字色挑選器與即時膠囊預覽，頂部動態生成分類篩選列，同步渲染 **月曆、週曆、日曆、清單** 四種檢視模式與 CSV 防公式注入匯出。
  * 內建「資料載入中，請稍候...」雲端同步遮罩、跨月預約自動跳轉目標月份、以及防瀏覽器密碼管理員誤填搜尋框保護機制。
* **試算表四分頁資料庫與資安隔離（比照智慧社團選社系統）**：
  * 自動建立並維護 `會議資料`（15 欄）、`異動紀錄`（13 欄完整稽核）、`管理者名單` 與 `系統設定`。
  * 管理者密碼與 `GEMINI_API_KEY` 雙向同步於試算表；未驗證前公開 API 絕不外洩試算表網址、API Key 或密碼雜湊，並支援首次預設密碼 `admin888` 強制變更與連續 5 次失敗鎖定 15 分鐘。
* **完整 10 大項前後端自動化回歸測試**：內含 Node.js 沙盒測試腳本（`tests/safety.test.cjs`），涵蓋 PII 個資攔截、多模態圖片解析、雙重防衝堂、防自動填入與試算表稽核。

---

## 📁 檔案結構

```text
ai-school-calendar/
├── SKILL.md                      # AI Agent 執行 SOP（需求盤點 → 建置 → 測試 → 部署）
├── README.md                     # 本說明文件
├── references/
│   └── architecture.md           # 4 大 Google 試算表分頁規格、雙重防衝堂與資安架構
├── scripts/
│   └── scaffold.ps1              # 一鍵建置新學校智慧行事曆專案腳本
└── resources/
    └── template/                 # 乾淨且學校無關的黃金程式碼範本
        ├── gas_code.gs           # Google Apps Script 後端程式
        ├── index.html            # 單頁式響應式前端（支援 GitHub Pages 與 GAS）
        ├── appsscript.json       # GAS 權限與 V8 執行設定
        ├── .claspignore          # clasp 上傳白名單
        └── tests/
            └── safety.test.cjs   # 10 大項前後端自動化安全與回歸測試
```

---

## 🚀 安裝本 Skill

### 方法一：安裝至個人全域 Skills（推薦，所有專案皆可喚起）

```powershell
git clone https://github.com/coolokey/ai-school-calendar-skill.git "$HOME\.gemini\config\skills\ai-school-calendar"
```

### 方法二：僅安裝至單一專案工作區

```powershell
git clone https://github.com/coolokey/ai-school-calendar-skill.git ".\.agents\skills\ai-school-calendar"
```

---

## 💡 使用方式

### 方式 A：在 Antigravity 對話中直接下指令

> 「請幫我用 `ai-school-calendar` 技能，為『桃園市立○○國民中學』建立一套校園智慧會議行事曆系統。」

### 方式 B：手動執行腳手架腳本建立新專案

```powershell
powershell -ExecutionPolicy Bypass -File "$HOME\.gemini\config\skills\ai-school-calendar\scripts\scaffold.ps1" `
  -TargetDir "D:\my-school-calendar" `
  -SchoolFullName "桃園市立○○國民中學" `
  -SchoolShortName "○○國中" `
  -GasWebappUrl "https://script.google.com/macros/s/<您的 DEPLOYMENT_ID>/exec"
```

建置完成後即可執行驗證與部署：

```powershell
cd D:\my-school-calendar
node --test tests/safety.test.cjs
clasp push --force
clasp deploy --description "Initial release"
```

---

## 📄 授權與實作參考

* 實戰範例系統參考：[dsjh-ai-calendar](https://github.com/coolokey/dsjh-ai-calendar)（線上展示：https://coolokey.github.io/dsjh-ai-calendar/）
* 採用開源授權供各級學校教育行政減量與資訊推廣自由複用與客製。
