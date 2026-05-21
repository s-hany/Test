;;; init.el --- Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;;; Code:

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta))

(prefer-coding-system 'utf-8)

(setq x-select-enable-clipboard t
      x-select-enable-primary t
      save-interprogram-paste-before-kill t
      apropos-do-all t
      mouse-yank-at-point t)

;; 警告音と画面フラッシュが鬱陶しいため無効化
(setq ring-bell-function 'ignore)

;; Emacsチュートリアル
(keymap-set global-map "C-h t" #'help-with-tutorial-spec-language)
;; 操作に慣れてきたら，以下の2行のコメントアウトを外すのがおすすめ
;; （C-hは直前の1文字の削除．ヘルプはM-hで開く．）
;; (keymap-global-set "C-h" #'delete-backward-char)
;; (keymap-global-set "M-h" #'help)

;; コマンド履歴を保存
(savehist-mode 1)
;; ファイル内のカーソル位置を記憶
(save-place-mode 1)

;; インデントにタブ文字を使わない
(setq-default indent-tabs-mode nil)

;; オープン中のバッファが他所で変更された際の同期処理
(global-auto-revert-mode 1)
;; Dired等も自動更新
(setq global-auto-revert-non-file-buffers t)

;; Emacs中のファイル削除は「ごみ箱へ移動」
(setq delete-by-moving-to-trash t)

;; フレームやウィンドウのリサイズをスムーズに
(setq window-resize-pixelwise t)
(setq frame-resize-pixelwise t)

;; スクロールもスムーズに
(pixel-scroll-precision-mode 1)

;; マウソポインタの位置に追随して自動でウィンドウをセレクト
(setq mouse-autoselect-window t)

;; マウスのドラッグ＆ドロップでリージョンのコピペを可能に
;; Emacs以外へもコピペ可能にする
(setq mouse-drag-and-drop-region-cross-program t)
;; Metaキーを押しながらドロップ = 同一バッファ内でも移動ではなくコピー
(setq mouse-drag-and-drop-region 'meta)

;; グローバルなフォントスケーリングにフレームサイズを追随
(setq global-text-scale-adjust-resizes-frames t)

;; ツールバー不要
(tool-bar-mode -1)
;; メニューバー不要
(menu-bar-mode -1)

;; ウィンドウの縁を掴めるようにする
(window-divider-mode)
(setq-default window-divider-default-right-width 1)

;; 初期フレームサイズ
(add-to-list 'default-frame-alist '(width . 83))
(add-to-list 'default-frame-alist '(height . 36))
;; 80文字目に罫線
;; (setq-default display-fill-column-indicator-column 80)
;; (global-display-fill-column-indicator-mode)

;; カーソルの見た目
(setq-default cursor-type '(bar . 3))
(blink-cursor-mode -1)

;; ウィンドウの横幅を超える行を自動で折り返す
(setq-default truncate-lines nil)

;; シンタックス・ハイライト
(setq font-lock-maximum-decoration t)

;; 括弧の対応を強調表示
(show-paren-mode t)

;; 現在行をハイライト表示
;; (global-hl-line-mode t)

;; モードラインにカラムを表示
(column-number-mode t)

;; delete selection modeを有効化
(delete-selection-mode)

;; minibufferのdefaultをスマート化
(minibuffer-electric-default-mode)

;; Ctrl+マウスホイール（トラックパッド含む）による
;; text-scale-adjustの誤爆を防止
(global-unset-key (kbd "C-<wheel-up>"))
(global-unset-key (kbd "C-<wheel-down>"))
(global-unset-key (kbd "C-<mouse-4>"))
(global-unset-key (kbd "C-<mouse-5>"))


;; External packages

(use-package package
  :config
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/"))
  ;; (package-initialize)
  )

(setopt use-package-always-ensure t)
(setopt package-native-compile nil)
;; (setopt warning-minimum-level :emergency)

(use-package use-package
  :ensure nil)

;; PC room only
;; (unless (package-installed-p 'compat)
;;   (package-install-file "~/.emacs.d/compat-30.1.0.1.0.20260131.205608.tar"))
;; (use-package compat
;;   :ensure nil)

;; org-modern
(use-package org-modern
  :after org
  :hook
  ((org-mode . org-indent-mode)
   (org-mode . org-modern-mode)
   (org-agenda-finalize-hook . org-modern-agenda))
  :config
  (defun my/org-indent-redraw ()
    "Force redraw of org-indent overlays."
    (interactive)
    (org-indent-mode -1)
    (org-indent-mode 1))
  :bind
  (:map org-mode-map
        ("C-c i" . my/org-indent-redraw)))

;; Display page-break (\f, C-q C-l) as a horizontal line
(use-package page-break-lines
  :config
  (add-to-list 'page-break-lines-modes 'racket-mode)
  (custom-set-faces
   '(page-break-lines ((t (:foreground "gray30" :family "Courier" :height 1)))))
  (setq page-break-lines-max-width (if (eq system-type 'windows-nt) 40 68))
  (global-page-break-lines-mode 1))

;; Smart minibuffer
(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-sort-function 'vertico-sort-history-alpha))
;; Search for partial matches in any order
(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles partial-completion)))))
;; Enable richer annotations using the Marginalia package
(use-package marginalia
  :init
  (marginalia-mode))
;; Improve keyboard shortcut discoverability
(use-package which-key
  :config
  (which-key-mode)
  :custom
  (which-key-max-description-length 40)
  (which-key-lighter nil)
  (which-key-sort-order 'which-key-description-order))

;; Auto-comletion for all mode
(use-package company
  :demand t
  :custom
  (company-idle-delay 0.05)
  (company-minimum-prefix-length 1)
  (company-tooltip-align-annotations t)
  (company-selection-wrap-around t)
  :bind
  ("M-/" . company-complete)
  (:map company-active-map
        ("C-n" . company-select-next)
        ("C-p" . company-select-previous)
        ("<tab>" . company-complete-selection)
        ("C-d" . company-show-doc-buffer)
        ("M-." . company-show-location))
  :config
  (global-company-mode 1))

;; Tiny documentation in echo area
(use-package eldoc-mouse
  :custom
  (eldoc-mouse-posframe-max-width 80)
  (eldoc-mouse-posframe-max-height 16)
  ;; (eldoc-mouse-idle-time 1.2) ;; default = 0.4
  :hook eldoc-mode)

;; Appearance
(use-package modus-themes
  :custom
  (modus-themes-italic-constructs t)
  (modus-themes-bold-constructs t)
  (modus-themes-mixed-fonts t)
  (modus-themes-to-toggle '(modus-operandi-tinted
			    modus-vivendi-tinted))
  :bind
  (("C-c t t" . modus-themes-toggle)
   ("C-c t m" . modus-themes-select)))
;(use-package ef-themes)
(use-package doom-themes)
(load-theme 'modus-vivendi-tinted t) ; change here

;; Paren editing
(use-package smartparens
  :config
  (require 'smartparens-config)
  (smartparens-global-mode t)
  (setq sp-highlight-pair-overlay nil
        sp-highlight-wrap-overlay nil
        sp-highlight-wrap-tag nil
        sp-autowrap-region t)
  :hook ((prog-mode . smartparens-mode) ;; smartparens-strict-mode
         (eval-expression-minibuffer-setup . smartparens-mode))
  :bind (:map sp-keymap
              ;; ("M-s" . nil)
              ("M-]" . sp-forward-slurp-sexp)
              ("M-[" . sp-forward-barf-sexp)))

;; Racket mode
(defun my/racket-company-setup ()
  "Prefer Racket-aware completion candidates."
  (when (boundp 'company-backends)
    (setq-local company-backends
                '(company-capf
                  company-files
                  company-dabbrev-code
                  company-keywords
                  company-dabbrev)))
  (when (fboundp 'company-mode)
    (company-mode 1)))

(defun my/racket-insert-lang-line ()
  "Insert a starter language line for new empty .rkt files."
  (when (and buffer-file-name
             (string-match-p "\\.rkt\\'" buffer-file-name)
             (not (file-exists-p buffer-file-name))
             (= (buffer-size) 0))
    (insert "#lang racket\n\n")))

(defun my/racket-mode-setup ()
  "Enable a small Racket learning setup."
  (my/racket-insert-lang-line)
  (racket-xp-mode 1)
  (racket-input-mode 1)
  (my/racket-company-setup))

(use-package racket-mode
  :mode "\\.rkt\\'"
  :custom
  (racket-program "racket.exe")
  (racket-xp-eldoc-level 'summary)
  (racket-error-context 'medium)
  :bind
  (:map racket-mode-map
        ("C-c r r" . racket-run)
        ("C-c r R" . racket-run-and-switch-to-repl)
        ("C-c r t" . racket-test)
        ("C-c r e" . racket-send-definition)
        ("C-c r x" . racket-send-last-sexp)
        ("C-c r d" . racket-xp-describe)
        ("C-c r h" . racket-documentation-search)
        ("C-c r n" . racket-xp-next-error)
        ("C-c r p" . racket-xp-previous-error))
  :config
  (require 'racket-input)
  (require 'racket-repl)
  (require 'racket-xp)

  (add-hook 'racket-mode-hook #'my/racket-mode-setup)
  (add-hook 'racket-repl-mode-hook #'my/racket-company-setup))

(with-eval-after-load 'racket-repl
  (add-hook 'racket-repl-mode-hook #'my/racket-company-setup))

;; Start from home directory
(setq inhibit-startup-screen t)
(cd "~")

;; Default font
(cond
 ((eq system-type 'darwin)
  (set-face-attribute 'default nil
                      :family "PlemolJP Console NF"
                      :foundry "outline"
                      :slant 'normal
                      :weight 'regular
                      :height 220
                      :width 'normal))
 ((eq system-type 'windows-nt)
  (set-face-attribute 'default nil
                      :family "Consolas" ; customize here
                      :foundry "outline"
                      :slant 'normal
                      :weight 'regular
                      :height 130        ; customize here
                      :width 'normal)))

(message "ALL DONE.")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(page-break-lines ((t (:foreground "gray30" :family "Courier" :height 1)))))


(provide 'init)
;;; init.el ends here
