;;; -*- Mode: LISP; Syntax: Common-lisp; Package: stumpwm.modules.emacs -*-

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

;;; Commentary:

;;;==================================================================
;;; Filename: package.lisp
;;; Eamcs integration extension for stumpwm
;;;==================================================================
;;;
;;; Code:

(in-package :stumpmacs)
;;;; set command-line parameters and commands for emacs
(set-arg exec "--eval")
(set-arg socket "-s")
(set-arg new-frame "-c")
(set-arg no-wait "-n")
(set-arg as-script "--script")
(set-arg batch "--batch")
(set-arg alt-configfile "-q -l")

(set-cmd ping-daemon "t")
(set-cmd stop-daemon "(kill-emacs)")
(set-cmd switch-to-buffer '("(switch-to-buffer \"" "\")"))
(set-cmd save-buffer '("(if (not (null (buffer-file-name (get-buffer \"" "\")))) (and (switch-to-buffer \"" "\") (save-buffer)) (message \"nil\"))"))
(set-cmd save-some-buffers "(save-some-buffers t)")
(set-cmd kill-buffer '("(kill-buffer \"" "\")"))
(set-cmd write-file '("(and (switch-to-buffer \"" "\") (write-file \"" "\"))"))
(set-cmd find-file '("(find-file \"" "\")"))
(set-cmd execute-extended-command '( "(and (switch-to-buffer \"" "\") (" "))"))
(set-cmd get-emacs-commands "(mapatoms (lambda (x) (and (fboundp x) (commandp (symbol-function x)) (princ (concat (symbol-name x) \";\")))))")

;;;; /set command-line parameters and commands for emacs
