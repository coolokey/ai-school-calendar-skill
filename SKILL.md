---
name: ai-school-calendar
description: >-
  校園智慧會議行事曆與雙軌防衝堂協作系統產生與部署技能。當使用者要求「製作校園智慧行事曆」、「建立學校會議與場地預約網站」、「套用 AI 公文截圖速填與防衝堂行事曆範本到新學校」或「客製化／部署 GAS + Gemini 校園行事曆系統」時啟動。
---

# 校園智慧會議行事曆與場地協作系統建立指南 (`ai-school-calendar`)

本 Skill 提供完整的「Google Apps Script + Google Sheets 4 分頁資料庫 + Gemini 2.5 Flash 圖文多模態解析 + 場地與參與人員雙重防衝堂雷達」校園智慧會議行事曆系統標準作業流程與可複用黃金範本（內含 10 項前後端自動化回歸測試）。

---

## 觸發條件

當使用者提出以下需求之一時啟用本 Skill：
* 要求「為某某學校建立校園智慧行事曆」、「製作處室會議與場地借用系統」或「複製／客製這套 AI 行事曆網站」。
* 要求新增、擴充、除錯或重新部署現有 `gas_code.gs` / `index.html` 的行事曆功能（如 Gemini Vision 公文截圖速填、10 節次複選、自訂分類配色、場地＋參與人員雙重防衝堂雷達、試算表管理者帳密與 API Key 設定）。

---

## 執行流程

### 階段一：需求盤點（與使用者確認必要參數）

啟動新專案前，先向使用者確認以下參數（若為擴充既有專案則先檢查現有 `gas_code.gs` 與 `.clasp.json`）：
1. **學校全銜與簡稱**：例如 `桃園市立○○國民中學` / `○○國中`。
2. **校內常用會議場地與作息節次**：
   * 預設提供 8 個常用場地（`學生活動中心`、`行政大樓3F教師研習中心`、`科技館1F視聽教室`、`科技館2F科技智慧教室`、`科技館2F科技創作教室`、`圖書館`、`校史室`、`新大樓1F視聽中心`）與「其他」自訂輸入。
   * 預設內建 10 個標準作息節次（`朝會 08:00-08:20`、`第1節`～`第4節`、`午休`、`第5節`～`第8節`）與「自訂時間」模式。
3. **Google 試算表與 Apps Script 部署設定**：
   * 若將 `gas_code.gs` 直接綁定於試算表，系統會自動建立並維護 4 大核心工作表（`會議資料`、`異動紀錄`、`管理者名單`、`系統設定`）；若為獨立 Apps Script 專案，亦可自動建立試算表並記錄 `SPREADSHEET_ID`。
4. **Gemini API Key 與管理密碼**：
   * 首次預設管理密碼為 `admin888`（首次登入強制改為 8 碼以上自訂密碼後才解鎖敏感設定與試算表網址）。
   * `GEMINI_API_KEY` 可於網頁「管理者系統設定」輸入，或直接貼入後台 Google 試算表「系統設定」分頁。

---

### 階段二：一鍵建立專案骨架 (`scripts/scaffold.ps1`)

執行本 Skill 附帶的 [scaffold.ps1](./scripts/scaffold.ps1) 將已驗證的黃金範本複製至目標資料夾，並自動替換學校名稱與預設 GAS 部署網址：

```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\MAO YU REN\.gemini\config\skills\ai-school-calendar\scripts\scaffold.ps1" `
  -TargetDir "<專案目標路徑>" `
  -SchoolFullName "<學校全銜>" `
  -SchoolShortName "<學校簡稱>" `
  -GasWebappUrl "https://script.google.com/macros/s/<DEPLOYMENT_ID>/exec"
```

* 若需深入了解試算表 4 分頁欄位規格、雙重防衝堂演算法、多模態截圖 OCR 與資安防護，請閱讀 [architecture.md](./references/architecture.md)。

---

### 階段三：客製化調整要點

依學校需求微調目標資料夾內的檔案：
1. **作息節次、場地與參與單位設定**：
   * 前端節次定義位於 `index.html` 的 `SCHOOL_PERIODS`，參與單位定義於 `PARTICIPANT_UNITS`（含 `教務處`、`學務處`、`總務處`、`輔導室`、`人事室`、`科技中心`、`七/八/九年級導師`、`專任教師` 與 `其他`）。
   * 若修改節次或場地清單，請同步更新 `gas_code.gs` 中 `aiExtractEvent` 與 `aiChatSchedule` 的系統提示詞，確保 AI 解析與推薦一致。
2. **雙重防衝堂與向後相容規則**：
   * 前後端（`detectEventConflict` 與 `checkConflict`）同時檢核「同一日期＋重疊時段」下的 **會議地點重複** 與 **參與單位／人員重複**。
   * 保留 `extractLegacyParticipants_` 向後相容機制：當舊有紀錄的第 13 欄 `參與單位` 為空白時，自動從第 9 欄 `說明備註` 擷取 `參加人員：...` 清單納入衝堂比對。
3. **瀏覽器自動填入防護與雲端載入體驗**：
   * 保留 `#searchInput` 的獨立 `<form role="search" autocomplete="off">` 與 `onSearchBoxInput` 未聚焦靜默自動填入清除機制，以及所有 `<input type="password">` 的 `autocomplete="new-password"`，防止瀏覽器密碼管理員誤填帳號導致行事曆被過濾隱藏。
   * 保留 `#cloudLoadingModal`（「資料載入中，請稍候...」遮罩）與跨月預約成功後自動切換至目標月份的 UX 流程。

---

### 階段四：自動化測試與 Playwright 實機驗證

**每次修改程式碼或產生新專案後，必須執行以下雙重驗證，不可跳過：**

1. **前後端安全與業務邏輯單元測試（10 項應全數通過）**：
   ```powershell
   cd "<專案目標路徑>"
   node --test tests/safety.test.cjs
   ```
   檢查包含：會議紀錄防虛構、PII 敏感個資攔截、Gemini 2.5/2.0 模型自動備援、DOM ID 完整性、節次換算與跳節提醒、15 欄試算表與 13 欄異動紀錄稽核、管理者密碼與 API Key 雙向同步、多模態截圖 OCR、以及場地＋參與人員雙重防衝堂（含歷史備註相容）。

2. **Playwright 桌面 + 手機響應式與無錯誤檢查**：
   確認桌面（`1440x900`）與手機（`390x844`）載入無 `pageerror` / `console.error`，且手機版無水平溢位 (`scrollWidth <= clientWidth`)。

---

### 階段五：部署 Google Apps Script 與 GitHub Pages

1. **部署 GAS Web App**：
   ```powershell
   cd "<專案目標路徑>"
   clasp push --force
   clasp deploy --deploymentId "<DEPLOYMENT_ID>" --description "Production release"
   ```
   取得 `/exec` 網址後，確認 `index.html` 的 `DEFAULT_GAS_URL` 一致並推送至 GitHub Pages。

2. **部署後線上健康實測**：
   以 `Invoke-RestMethod "<GAS_EXEC_URL>?action=ping"` 與 `?action=getEvents` 驗證回應 `status: "success"`，且未驗證前不外洩試算表網址與金鑰。
