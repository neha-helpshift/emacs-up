;;; core.el --- customizing core emacs variables
;;; Author: Vedang Manerikar
;;; Created on: 13 Oct 2013
;;; Copyright (c) 2013 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Code:


(setq user-full-name "Vedang Manerikar"
      user-mail-address "vedang.manerikar@gmail.com"
      message-log-max t
      visible-bell t
      echo-keystrokes 0.1
      inhibit-startup-message t
      font-lock-maximum-decoration t
      confirm-kill-emacs 'y-or-n-p
      require-final-newline t
      ediff-window-setup-function 'ediff-setup-windows-plain
      save-place-file (concat tempfiles-dirname "places")
      column-number-mode t
      debug-on-error t
      eshell-history-file-name (concat tempfiles-dirname "eshell-history")
      gc-cons-threshold 1800000
      bookmark-save-flag 1
      display-buffer-reuse-frames t
      whitespace-line-column 80
      flyspell-issue-welcome-flag nil
      recenter-positions '(top middle bottom)
      sentence-end-double-space nil
      display-time-day-and-date t)

;; Don't clutter up directories with files~
(setq backup-directory-alist
      `(("." . ,(expand-file-name
                 (concat tempfiles-dirname "backups"))))
      auto-save-list-file-prefix
      (concat tempfiles-dirname "auto-save-list/.auto-saves-")
      auto-save-file-name-transforms
      `((".*" ,(concat tempfiles-dirname "auto-save-list/") t)))

;; Completion ignores filenames ending in any string in this list.
(setq vm/completion-ignored-extensions
      '(".exe" ".ps" ".abs" ".mx" ".~jv" ".rbc" ".beam" ".out" ".hbc"))
(dolist (ext vm/completion-ignored-extensions)
  (add-to-list 'completion-ignored-extensions ext))

;;; Everything in UTF8
(prefer-coding-system 'utf-8)
(set-language-environment 'UTF-8)
(set-default-coding-systems 'utf-8)
(setq file-name-coding-system 'utf-8)
(setq buffer-file-coding-system 'utf-8)
(setq coding-system-for-write 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-clipboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(setq default-process-coding-system '(utf-8 . utf-8))


(setq-default indent-tabs-mode nil  ;only spaces by default.
              tab-width 4)


(mouse-avoidance-mode 'banish)
(delete-selection-mode t)
(display-time)


;;; hooks
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)
(add-hook 'text-mode-hook 'turn-on-flyspell)
(add-hook 'fundamental-mode-hook 'turn-on-flyspell)


;;; open these files in the appropriate mode
(add-to-list 'auto-mode-alist '("\\.\\(mc\\|rc\\|def\\)$" . conf-mode))
(add-to-list 'auto-mode-alist '("\\.\\(erl\\|hrl\\)$" . erlang-mode))
(add-to-list 'auto-mode-alist '("\\.\\(tex\\|ltx\\)$" . LaTeX-mode))
(add-to-list 'auto-mode-alist '("Vagrantfile$" . ruby-mode))
(if (eq system-type 'darwin)
  (add-to-list 'auto-mode-alist '("\\.m$" . objc-mode))
  (add-to-list 'auto-mode-alist '("\\.m$" . octave-mode)))

(add-to-list 'safe-local-variable-values '(lexical-binding . t))


;; Enable narrow-to-region, extremely useful for editing text
(put 'narrow-to-region 'disabled nil)


(provide 'core)
