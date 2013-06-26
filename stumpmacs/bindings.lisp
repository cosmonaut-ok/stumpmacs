;;; -*- Mode: LISP; Syntax: Common-lisp; Package: stumpmacs -*-

;; Copyright 2013 Alexander aka 'CosmonauT' Vynnyk
;;
;; Author: Alexander aka CosmonauT Vynnyk <cosmonaut.ok@gmail.com>
;; Version: id: web,v 2013.06.26 Jun 26 2013 cosmonaut.ok@gmail.com
;; Keywords:
;; X-URL: not distributed yet

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
;;
;;; Commentary:

;;;==================================================================
;;; Filename: bindings.lisp
;;; Eamcs integration extension for stumpwm
;;;==================================================================
;;;
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
