;;; init.el --- Root emacs configuration file.
;;; Author: Vedang Manerikar
;;; Created on: 08 Jan 2012
;;; Time-stamp: "2013-08-15 02:24:34 vedang"
;;; Copyright (c) 2012 Vedang Manerikar <vedang.manerikar@gmail.com>

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Do What The Fuck You Want to
;; Public License, Version 2, which is included with this distribution.
;; See the file LICENSE.txt

;;; Code:;;;

(defvar *emacs-load-start* (current-time))


;;; No GUI
(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp mode) (funcall mode -1)))


;;; Some global defs
(setq dotfiles-dirname (file-name-directory (or load-file-name
                                                (buffer-file-name)))
      autoload-file (concat dotfiles-dirname "loaddefs.el")
      plugins-dirname (concat dotfiles-dirname "plugins/")
      config-dirname (concat dotfiles-dirname "configuration/")
      elpa-dirname (concat dotfiles-dirname "elpa/")
      vedang-custom-file (concat dotfiles-dirname "custom.el")
      tempfiles-dirname (concat dotfiles-dirname "temp-files/")
      log-dirname (concat dotfiles-dirname "logs/"))


(defvar vedang/programming-major-modes
  '(js2-mode c-mode c++-mode conf-mode clojure-mode erlang-mode
             emacs-lisp-mode lisp-mode scheme-mode python-mode objc-mode)
  "List of programming modes that I use")
(defvar vedang/lisp-major-modes
  '(emacs-lisp-mode lisp-mode clojure-mode scheme-mode)
  "List of lispy modes that I use")


;;; Create temp directories if necessary
(make-directory tempfiles-dirname t)


;;; From nflath.com
;;; add all subdirs under "~/.emacs.d/" to load-path
(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
    (let* ((my-lisp-dir dotfiles-dirname)
           (default-directory my-lisp-dir)
           (orig-load-path load-path))
      (setq load-path (cons my-lisp-dir nil))
      (normal-top-level-add-subdirs-to-load-path)
      (nconc load-path orig-load-path)))


;;; Require common stuff
(require 'cl)
(require 'uniquify)
(require 'saveplace)


;;; Require my configuration
(load vedang-custom-file 'noerror)
(require 'utility-functions)
(require 'customizations)
(require 'mode-config)
(require 'key-bindings)
(require 'registers)
(when (eq system-type 'darwin)
  (require 'osx))
(vedang/regen-autoloads)
(server-start)
(message "My .emacs loaded in %ds" (destructuring-bind (hi lo ms psec) (current-time)
                                     (- (+ hi lo)
                                        (+ (first *emacs-load-start*)
                                           (second *emacs-load-start*)))))
(totd) ; Display Tip Of The Day.

;;; init.el ends here
