;;; -*- Mode: LISP; Syntax: Common-lisp; Package: stumpwm.modules.emacs -*-
;;
;; Copyright (C) 2003-2008 Shawn Betts
;; Copyright (C) 2010-2012 Alexender aka CosmonauT Vynnyk
;;
;;  This file is part of stumpwm.
;;
;; stumpwm is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; stumpwm is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this software; see the file COPYING.  If not, see
;; <http://www.gnu.org/licenses/>.

;; Commentary:
;;
;; define standard key bindings
;;
;; Code:

(in-package #:stumpwm)

(export '(*emacs-map*))

(defvar *emacs-key* (kbd "e"))
(defvar *another-emacs-key* (kbd "C-e"))

(defvar *emacs-map* nil
  "The keymap that group related key bindings sit on. It is bound to @kbd{C-j e} by default.")

(fill-keymap *emacs-map*
  (kbd "e") "send-escape"
  (kbd "b") "e-open-buffer"
  (kbd "C-b") "e-list-buffers"
  (kbd "f") "e-find-file"
  (kbd "k") "e-kill-buffer"
  ;; (kbd "C-k") "e-kill-buffer-from-menu"
  (kbd ":") "e-eval-expression"
  (kbd "C-e") "e-connect" ;; e-run-or-raise-client"
  (kbd "s") "e-save-some-buffers"
  (kbd "M-x") "e-execute-extended-command"
  (kbd "w") "e-write-file"
  (kbd "C-s") "e-save-buffer"
  )

(define-key *root-map* *emacs-key*  '*emacs-map*)
(define-key *root-map* *another-emacs-key* '*emacs-map*)


;; e-find-file +
;; e-switch-to-buffer +
;; e-list-buffers +
;; e-open-buffer 
;; e-save-buffer 
;; e-save-changed +
;; e-write-file +
;; e-kill-buffer +
;; e-eval-expression +
;; e-execute-extended-command +
;; e-connect +
;; e-start-daemon -
;; e-stop-daemon -
;; e-restart-daemon -
;; e-list-daemons -
;; e-swith-to-daemon -
;; e-daemons -
