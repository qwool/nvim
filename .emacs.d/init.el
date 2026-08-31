;;; init.el -*- lexical-binding: t; -*-

(defvar bootstrap-version)
(let ((bootstrap-file
    (expand-file-name
      "straight/repos/straight.el/bootstrap.el"
      (or (bound-and-true-p straight-base-dir)
        user-emacs-directory)))
    (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
       'silent 'inhibit-cookies)
    (goto-char (point-max))
    (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)
(setq use-package-always-defer t)

(use-package exec-path-from-shell
  :if (memq system-type '(darwin gnu/linux))
  :demand t
  :config
  (exec-path-from-shell-initialize))

(set-charset-priority 'unicode)
(setq locale-coding-system 'utf-8
      coding-system-for-read 'utf-8
      coding-system-for-write 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

(set-face-attribute 'default nil
                    :font "Maple Mono NL NF"
                    :height 160)
(when (eq system-type 'darwin)
  (set-fontset-font t 'symbol "Apple Color Emoji" nil 'prepend))
(when (eq system-type 'gnu/linux)
  (set-fontset-font t 'symbol "Noto Color Emoji" nil 'prepend))

(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(setq use-file-dialog nil)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq ring-bell-function 'ignore)
(setq scroll-conservatively 101)
(setq scroll-margin 10)

(global-auto-revert-mode t)
(show-paren-mode 1)
(setq show-paren-delay 0)
(save-place-mode 1)

(winner-mode 1)

(setq confirm-kill-emacs 'y-or-n-p)

(setq history-delete-duplicates t)
(savehist-mode 1)
(setq savehist-additional-variables '(search-ring regexp-search-ring)
      history-length 500
      savehist-autosave-interval 60)
(setq make-backup-files nil)
(setq create-lockfiles nil)

(use-package recentf
  :straight nil
  :init (recentf-mode 1)
  :custom
  (recentf-max-menu-items 25)
  (recentf-max-saved-items 100)
  (recentf-exclude '("/tmp/" "/ssh:" "\\.?ido\\.last$" "\\.revive$" "/TAGS$")))

(setq select-enable-clipboard t
      select-enable-primary t
      save-interprogram-paste-before-kill t)

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'meta)
  (setq mac-right-option-modifier nil)
  (setq mac-control-modifier 'control)
  (add-to-list 'initial-frame-alist '(fullscreen . maximized))
  (add-to-list 'default-frame-alist '(fullscreen . maximized)))

(setq display-line-numbers-type t)
(global-display-line-numbers-mode 1)
(setq case-fold-search t)
(global-visual-line-mode 1)

(setq dired-auto-revert-buffer t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(setq dired-kill-when-opening-new-dired-buffer t)

(require 'treesit)
(add-to-list 'treesit-language-source-alist
             '(rust "https://github.com/tree-sitter/tree-sitter-rust"))
(unless (treesit-language-available-p 'rust)
  (treesit-install-language-grammar 'rust))

(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode))

(electric-indent-mode 1)

(setq-default tab-width 2)
(setq-default indent-tabs-mode nil)
(setq-default c-basic-offset 2)
(setq-default c-ts-mode-indent-offset 2)
(setq-default rust-ts-mode-indent-offset 2)
(setq-default js-indent-level 2)
(setq-default python-indent-offset 4)

(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

(defun my/c-mode-setup ()
  (setq-local indent-tabs-mode t)
  (setq-local tab-width 2)
  (c-set-offset 'substatement-open 0))

(add-hook 'c-mode-hook #'my/c-mode-setup)
(add-hook 'c++-mode-hook #'my/c-mode-setup)
(add-hook 'c-ts-mode-hook #'my/c-mode-setup)
(add-hook 'c++-ts-mode-hook #'my/c-mode-setup)

(use-package vertico
  :straight (vertico :files (:defaults "extensions/*"))
  :demand t
  :init (vertico-mode 1)
  :custom
  (vertico-cycle t)
  (vertico-count 12))

(use-package vertico-directory
  :straight nil
  :after vertico
  :bind (:map vertico-map
              ("RET" . vertico-directory-enter)
              ("DEL" . vertico-directory-delete-char)
              ("M-DEL" . vertico-directory-delete-word)))

(use-package orderless
  :demand t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package consult
  :bind (("C-c C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)))

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-c C-e" . embark-export)
         ("M-?" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :demand t
  :init (global-corfu-mode 1)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 1)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  :config
  (defun my/corfu-enable-in-minibuffer ()
    (when (where-is-internal #'completion-at-point (list (current-local-map)))
      (corfu-mode 1)))
  (add-hook 'minibuffer-setup-hook #'my/corfu-enable-in-minibuffer))

(use-package base16-theme
  :demand t
  :config (load-theme 'base16-default-dark t))

(use-package crux
  :bind (("C-a"   . crux-move-beginning-of-line)
         ("M-o"   . crux-smart-open-line-above)
         ("C-S-k" . crux-kill-whole-line)))

(use-package which-key
  :demand t
  :init (which-key-mode 1)
  :custom
  (which-key-idle-delay 0.3)
  (which-key-side-window-location 'bottom))

(use-package marginalia
  :demand t
  :init (marginalia-mode 1))

(setq desktop-restore-eager 10)
(setq desktop-path (list user-emacs-directory))
(setq desktop-dirname user-emacs-directory)
(setq desktop-base-file-name "emacs-desktop")

(setq desktop-save t)

(desktop-save-mode 1)

(run-with-timer 300 300 #'desktop-save-in-desktop-dir)

(use-package eglot
  :straight (eglot :host github :repo "joaotavora/eglot"))

(add-hook 'c-mode-hook #'eglot-ensure)
(add-hook 'c++-mode-hook #'eglot-ensure)
(add-hook 'c-ts-mode-hook #'eglot-ensure)
(add-hook 'c++-ts-mode-hook #'eglot-ensure)
(add-hook 'rust-ts-mode-hook #'eglot-ensure)
(add-hook 'python-mode-hook #'eglot-ensure)

(defun my/eglot-formatting-setup ()
  (setq-local tab-width 2)
  (setq-local indent-tabs-mode t))
(add-hook 'eglot-managed-mode-hook #'my/eglot-formatting-setup)

(add-hook 'eglot-managed-mode-hook #'flymake-mode)

(with-eval-after-load 'eglot
  (define-key eglot-mode-map (kbd "C-c l r") #'eglot-rename)
  (define-key eglot-mode-map (kbd "C-c l a") #'eglot-code-actions)
  (define-key eglot-mode-map (kbd "C-c l f") #'eglot-format)
  (add-to-list 'eglot-ignored-server-capabilities :documentOnTypeFormattingProvider))

(setq eglot-events-buffer-size 0)

(use-package eldoc-box
  :straight (:host github :repo "casouri/eldoc-box")
  :after eglot
  :hook (eglot-managed-mode . eldoc-box-hover-mode)
  :custom
  (eldoc-box-only-multi-line t)
  (eldoc-box-max-pixel-width 600)
  (eldoc-box-max-pixel-height 400)
  (eldoc-box-cleanup-interval 0.5)
  (eldoc-box-fringe-use-same-bg t)
  :config
  (when (and (eq system-type 'gnu/linux)
             (string-match-p "GTK" system-configuration-features))
    (setq x-gtk-resize-child-frames 'resize-mode)))

(use-package diff-hl
  :bind (("C-{" . diff-hl-previous-hunk)
         ("C-}" . diff-hl-next-hunk))
  :demand t
  :init
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))

(use-package magit
  :bind (("C-x g" . magit-status)))

(use-package listen
  :bind (("M-p" . listen)))

(defun my/smart-backward-kill ()
  (interactive)
  (if (use-region-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word 1)))
(global-set-key (kbd "C-w") #'my/smart-backward-kill)

(defvar my/leader-map (make-sparse-keymap))
(define-key global-map (kbd "C-c p") my/leader-map)

(defun my/switch-to-last-buffer ()
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) t)))

(defun my/scroll-half-page-down ()
  (interactive)
  (let ((lines (/ (window-height) 2)))
    (forward-line lines)
    (recenter)))

(defun my/scroll-half-page-up ()
  (interactive)
  (let ((lines (/ (window-height) 2)))
    (forward-line (- lines))
    (recenter)))

(use-package bind-key
  :straight nil
  :config
  (bind-keys :map my/leader-map
             ("b" . consult-buffer)
             ("f" . find-file)
             ("r" . recentf-open-files)
             ("s" . save-buffers-kill-terminal)
             ("l" . my/switch-to-last-buffer))
  (bind-key* "C-d" #'my/scroll-half-page-down)
  (bind-key* "C-u" #'my/scroll-half-page-up)
  (bind-key* "M-q" #'kill-emacs))

(global-set-key (kbd "M-w") 'kill-ring-save)
(global-set-key (kbd "C-y") 'yank)
(global-set-key (kbd "C-/") 'undo)

(global-set-key (kbd "C-c h") #'describe-symbol)
(global-set-key (kbd "C-c C-h") #'describe-symbol)

;; tabs
(global-set-key (kbd "M-t") #'tab-new)
(global-set-key (kbd "M-1") (lambda () (interactive) (tab-bar-select-tab 1)))
(global-set-key (kbd "M-2") (lambda () (interactive) (tab-bar-select-tab 2)))
(global-set-key (kbd "M-3") (lambda () (interactive) (tab-bar-select-tab 3)))
(global-set-key (kbd "M-4") (lambda () (interactive) (tab-bar-select-tab 4)))
(global-set-key (kbd "M-5") (lambda () (interactive) (tab-bar-select-tab 5)))
(global-set-key (kbd "M-]") #'tab-next)
(global-set-key (kbd "M-[") #'tab-previous)

(global-set-key (kbd "M-j") 'join-line)
(global-set-key (kbd "M-/") 'consult-git-grep)
(global-set-key (kbd "C-x C-b") 'consult-buffer)
(global-set-key (kbd "M-?") 'embark-bindings)

(global-set-key (kbd "M-r") 'recompile)
(global-set-key (kbd "C-x C-o") 'other-window)

;; org mode
(setq org-link-frame-setup
      '((file . find-file)))

;; (set-keymap-parent 'org-mode-map ())
;; todo figure out how to map C-c . to (org-timestamp t t) only in org mode
;; (setq org-timestamp-custom-formats '("%a, %d %h %h:%m" . "%d/%m/%y %a %h:%m"))
(with-eval-after-load 'org
  (setq org-time-stamp-formats '("<%Y-%m-%d %a %H:%M>" . "<%Y-%m-%d %a %H:%M>")))
(org-babel-load-file "~/projects/revo/Emacs.org")

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 '(custom-safe-themes
   '("f700bc979515153bef7a52ca46a62c0aa519950cc06d539df4f3d38828944a2c"
     default)))
(custom-set-faces
 ;; custom-set-faces was added by custom.
 ;; if you edit it by hand, you could mess it up, so be careful.
 ;; your init file should contain only one such instance.
 ;; if there is more than one, they won't work right.
 )
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
