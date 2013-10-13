;;; utility-functions.el --- Useful Functions for day to day use
;;; Author: Vedang Manerikar
;;; Created on: 08 Jan 2012
;;; Copyright (c) 2012 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Code:


;;; function to display Tip of the Day
(defconst animate-n-steps 3)
(require 'cl)
(random t)
(defun totd ()
  (interactive)
  (let* ((commands (loop for s being the symbols
                         when (commandp s) collect s))
         (command (nth (random (length commands)) commands)))
    (animate-string (concat ";; Initialization successful, welcome to "
                            (substring (emacs-version) 0 16)
                            "\n"
                            "Your tip for the day is:\n========================\n\n"
                            (describe-function command)
                            (delete-other-windows)
                            "\n\nInvoke with:\n\n"
                            (where-is command t)
                            (delete-other-windows)
                            )0 0)))


;;; Function to launch a google search
(defun google ()
  "googles a query or a selected region"
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?q="
    (if mark-active
        (buffer-substring (region-beginning) (region-end))
      (read-string "Query: ")))))


;;; Function to mark complete word, and expand to sentence etc.
;;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun semnav-up (arg)
  (interactive "p")
  (when (nth 3 (syntax-ppss))
    (if (> arg 0)
        (progn
          (skip-syntax-forward "^\"")
          (goto-char (1+ (point)))
          (decf arg))
      (skip-syntax-backward "^\"")
      (goto-char (1- (point)))
      (incf arg)))
  (up-list arg))


;;; by Nikolaj Schumacher, 2008-10-20. Released under GPL.
(defun extend-selection (arg &optional incremental)
  "Select the current word.
Subsequent calls expands the selection to larger semantic unit."
  (interactive (list (prefix-numeric-value current-prefix-arg)
                     (or (and transient-mark-mode mark-active)
                         (eq last-command this-command))))
  (if incremental
      (progn
        (semnav-up (- arg))
        (forward-sexp)
        (mark-sexp -1))
    (if (> arg 1)
        (extend-selection (1- arg) t)
      (if (looking-at "\\=\\(\\s_\\|\\sw\\)*\\_>")
          (goto-char (match-end 0))
        (unless (memq (char-before) '(?\) ?\"))
          (forward-sexp)))
      (mark-sexp -1))))

(global-set-key (kbd "M-8") 'extend-selection)


;;; More Screen Space
(when (executable-find "wmctrl") ; apt-get install wmctrl
  (defun full-screen-toggle ()
    (interactive)
    (shell-command "wmctrl -r :ACTIVE: -btoggle,fullscreen"))
  (global-set-key (kbd "<f1>") 'full-screen-toggle))


;;; turn-on functions for various utilities
;;; =======================================


(defun turn-on-hl-line-mode ()
  "highlight the current line"
  (if window-system (hl-line-mode t)))


(defun turn-on-whitespace-mode ()
  (interactive)
  (require 'whitespace)
  (setq whitespace-style '(face empty tabs lines trailing))
  (whitespace-mode t))


(defun add-watchwords ()
  (font-lock-add-keywords
   nil '(("\\<\\(FIX\\|TODO\\|FIXME\\|HACK\\|REFACTOR\\):"
          1 font-lock-warning-face t))))


(defun pretty-lambdas ()
  (font-lock-add-keywords
   nil `(("(?\\(lambda\\>\\)"
          (0 (progn (compose-region (match-beginning 1) (match-end 1)
                                    ,(make-char 'greek-iso8859-7 107))
                    nil))))))


;; (defun vedang/prog-mode-settings ()
;;   "special settings for programming modes."
;;   (when (memq major-mode vedang/programming-major-modes)
;;     (flyspell-prog-mode)         ;; Flyspell mode for comments and strings
;;     (when (not (equal major-mode 'objc-mode))
;;       (turn-on-whitespace-mode)) ;; tell me if lines exceed 80 columns
;;     (when (memq major-mode vedang/lisp-major-modes)
;;       (require 'paredit)
;;       (paredit-mode t))          ;; Paredit goodness
;;     (pretty-lambdas)))
;; (add-hook 'find-file-hook 'vedang/prog-mode-settings)


;; Indentation hook for C/C++ mode
;; As defined in Documentation/CodingStyle
(defun vedang/linux-c-indent ()
  "adjusted defaults for C/C++ mode use with the Linux kernel."
  (interactive)
  (setq tab-width 8)
  (setq indent-tabs-mode nil) ;; force spaces, to work with dumber editors
  (setq c-basic-offset 8))
(add-hook 'c-mode-hook 'vedang/linux-c-indent)
(add-hook 'c-mode-hook (lambda() (c-set-style "K&R")))
(add-hook 'c++-mode-hook 'vedang/linux-c-indent)


(defun untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))


(defun indent-buffer ()
  (interactive)
  (indent-region (point-min) (point-max)))


(defun cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (indent-buffer)
  (untabify-buffer)
  (delete-trailing-whitespace))

;;; Autoloading and byte-compilation functions


(defun vedang/recompile-init (&optional force)
  "Byte-compile all your dotfiles again."
  (interactive "P")
  (byte-recompile-directory dotfiles-dirname 0 force))


(defun vedang/files-in-below-directory (directory)
  "List the .el files in DIRECTORY and in it's sub-directories."
  (let* ((current-directory-list (directory-files-and-attributes directory t))
         (el-files-list (delq nil (mapcar (lambda (lst)
                                            (and (equal ".el" (substring (car lst) -3))
                                                 (car lst)))
                                          current-directory-list)))
         (dirs-list (delq nil (mapcar (lambda (lst)
                                        (and (car (cdr lst))
                                             (not (equal "." (substring (car lst) -1)))
                                             (not (equal ".git" (substring (car lst) -4)))
                                             (car lst)))
                                      current-directory-list))))
    (apply #'append el-files-list
           (mapcar (lambda (d)
                     (vedang/files-in-below-directory d))
                   dirs-list))))


(defun vedang/update-directory-autoloads (autoload-dir)
  "Update directory autoloads, but better"
  (dolist (el-file (vedang/files-in-below-directory autoload-dir))
    (update-file-autoloads el-file t)))


(defun vedang/regen-autoloads (&optional force-regen)
  "Regenerate the autoload definitions file if necessary and load it."
  (interactive "P")
  (let ((generated-autoload-file autoload-file))
    (when (or force-regen
              (not (file-exists-p generated-autoload-file)))
      (when (not (file-exists-p generated-autoload-file))
        (with-current-buffer (find-file-noselect generated-autoload-file)
          (insert ";;") ;; create the file with non-zero size to appease autoload
          (save-buffer)))
      (message "Updating autoloads...")
      (dolist (autoload-dir (list plugins-dirname config-dirname elpa-dirname))
        (let (emacs-lisp-mode-hook)
          (vedang/update-directory-autoloads autoload-dir)))))
  (load autoload-file))


(defun sudo-edit (&optional arg)
  "Edit as root"
  (interactive "p")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))


(defun revert-all-buffers ()
  "Refreshes all open buffers from their respective files."
  (interactive)
  (dolist (buf (buffer-list))
    (with-current-buffer buf
      (when (and (buffer-file-name) (not (buffer-modified-p)))
        (revert-buffer t t t))))
  (message "Refreshed open files."))


(defun backward-kill-word-or-kill-region (&optional arg)
  "Change C-w behavior"
  (interactive "p")
  (if (region-active-p)
      (kill-region (region-beginning) (region-end))
    (backward-kill-word arg)))

(global-set-key (kbd "C-w") 'backward-kill-word-or-kill-region)


;; http://www.emacswiki.org/emacs/TransposeWindows
;;; When working with multiple windows it can be annoying if they get
;;; out of order. With this function it’s easy to fix that.
(defun transpose-windows (arg)
  "Transpose the buffers shown in two windows."
  (interactive "p")
  (let ((selector (if (>= arg 0) 'next-window 'previous-window)))
    (while (/= arg 0)
      (let ((this-win (window-buffer))
            (next-win (window-buffer (funcall selector))))
        (set-window-buffer (selected-window) next-win)
        (set-window-buffer (funcall selector) this-win)
        (select-window (funcall selector)))
      (setq arg (if (plusp arg) (1- arg) (1+ arg))))))

(global-set-key (kbd "C-x M-s") 'transpose-windows)


;; thank you magnars
(defun eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))


(defun incs (s &optional num)
  (number-to-string (+ (or num 1) (string-to-number s))))


(defun decs (s &optional num)
  (number-to-string (- (string-to-number s) (or num 1))))


(defun jump-to-next-slide ()
  "Jump to the next slide of the presentation"
  (interactive)
  (condition-case ex
      (find-file (car (file-expand-wildcards (concat
                                              (unhandled-file-name-directory (buffer-file-name))
                                              (incs (car (split-string (file-name-nondirectory (buffer-file-name))
                                                                       "-")))
                                              "-*"))))
    ('error (progn
              (message "Rewinding...")
              (find-file (car (file-expand-wildcards (concat
                                                      (unhandled-file-name-directory (buffer-file-name))
                                                      "1-*"))))))))

(global-set-key (kbd "<f8>") 'jump-to-next-slide)


(defun jump-to-prev-slide ()
  "Jump to the previous slide of the presentation"
  (interactive)
  (condition-case ex
      (find-file (car (file-expand-wildcards (concat
                                              (unhandled-file-name-directory (buffer-file-name))
                                              (decs (car (split-string (file-name-nondirectory (buffer-file-name))
                                                                       "-")))
                                              "-*"))))
    ('error (message "You've reached the beginning of the presentation"))))

(global-set-key (kbd "<f7>") 'jump-to-prev-slide)


(defmacro safe-wrap (fn &rest clean-up)
  "A wrapping over Emacs error handling"
  `(unwind-protect
       (let (retval)
         (condition-case ex
             (setq retval (progn ,fn))
           ('error
            (message (format "Caught exception: [%s]" ex))
            (setq retval (cons 'exception (list ex)))))
         retval)
     ,@clean-up))


(provide 'utility-functions)
