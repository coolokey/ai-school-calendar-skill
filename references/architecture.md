# 校園智慧會議行事曆系統：架構與資料表規格參考

## 1. 系統整體架構 (`index.html` + `gas_code.gs`)

* **前端 (`index.html`)**：
  * 單頁式響應式應用（Tailwind CSS + Font Awesome），支援月曆、週曆、日曆、清單四種視圖與列印專用排版。
  * **AI 公文與通知截圖一鍵速填 (`#aiExtractModal`)**：支援文字貼上與圖片貼上（`Ctrl+V` 剪貼簿貼圖、拖曳或檔案上傳），前端自動以 `<canvas>` 將超大截圖等比縮放至 `<=1600px` 並壓縮傳送。
  * **經典預約表單 (`#addEventModal`)**：整合 10 節次核取方塊（`朝會`～`第8節`＋`自訂時間`）、即時防衝堂雷達（`#liveConflictRadar`＋一鍵推薦空檔）、自由分類與底色／字色挑選器（`#colorPreviewPill`）、11 項參與單位複選與必填管理密碼。
  * **AI 排程秘書對話 (`#aiChatModal`)** 與 **會後 AI 文書協作 (`#eventDetailModal`)**：一鍵產出 LINE 推播通知、標準會議議程與正式會議紀錄草案（含管制追蹤表）。
* **後端 (`gas_code.gs`)**：
  * Google Apps Script Web App (`doGet` / `doPost`)，搭配 `LockService` 併發寫入鎖定與 `CacheService` 登入錯誤速率限制。
  * 串接 Google Gemini REST API (`gemini-2.5-flash` 優先，`gemini-2.0-flash` 自動備援)，支援純文字與 `inlineData` 多模態圖片輸入。

---

## 2. Google 試算表資料庫 Schema（4 大核心分頁）

| 分頁名稱 | 用途 | 欄位結構 |
| :--- | :--- | :--- |
| `會議資料` | 全校會議與活動主資料表（15 欄，支援 11 欄舊表自動無痛升級） | `ID`、`標題`、`日期`、`開始時間`、`結束時間`、`地點`、`主辦單位/部門`、`分類`、`說明備註`、`密碼(Hash)`、`建立時間`、`節次`、`參與單位`、`分類底色`、`分類字色` |
| `異動紀錄` | 新增／修改／刪除／管理者覆寫之完整稽核軌跡（13 欄） | `異動時間`、`操作類型`、`會議ID`、`標題`、`日期`、`開始時間`、`結束時間`、`地點`、`主辦單位/部門`、`分類`、`說明備註`、`節次`、`參與單位` |
| `管理者名單` | 系統管理員帳號與密碼（與 `系統設定` 雙向同步） | `帳號`（預設 `admin`）、`姓名`、`密碼`（預設 `admin888`）、`角色說明`、`更新時間` |
| `系統設定` | 系統金鑰與模型參數 | `ADMIN_PASSWORD`、`GEMINI_API_KEY`、`GEMINI_MODEL`（含最後更新時間與說明） |

---

## 3. 核心防衝堂與資安設計準則

1. **場地 ＋ 參與人員雙重防衝堂 (`checkConflict` / `detectEventConflict`)**：
   * 只要同一日期且時間區間重疊（`startA < endB && endA > startB`），系統同時比對「會議地點」與「參與單位／人員清單（`parseParticipantTokens`）」。
   * 若舊有資料第 13 欄 `參與單位` 為空白，自動透過 `extractLegacyParticipants_` 從第 9 欄 `說明備註` 解析 `參加人員：...` 納入比對。
2. **PII 個資攔截與去識別化 (`sensitiveInput_` / `sanitizeScheduleText_`)**：
   * 送交外部 Gemini 模型前，自動檢測並攔截身分證字號、手機號碼、Email 與機密關鍵字；AI 排程對話僅傳遞去識別化之場地與時段摘要，不傳送私密備註。
3. **管理者驗證與試算表網址保護**：
   * 未登入或仍使用預設密碼 `admin888` 時，公開 `?action=ping` 絕不回傳 `spreadsheetUrl` 或 `GEMINI_API_KEY` 明文；頁首「開啟試算表」按鈕預設隱藏，須以自訂管理密碼登入後才解鎖。
   * 連續 5 次登入密碼錯誤將透過 `CacheService` 鎖定 15 分鐘。
4. **防止瀏覽器密碼管理員污染搜尋欄**：
   * `#searchInput` 採用獨立 `<form role="search" autocomplete="off">` 與 `type="search"`，所有密碼輸入框設定 `autocomplete="new-password"`，並搭配 `onSearchBoxInput` 過濾未聚焦之靜默自動填入。
