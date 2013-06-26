;;; -*- Mode: LISP; Syntax: Common-lisp; Package: stumpwm.modules.emacs -*-

;; Copyright 2011 Alexander aka 'CosmonauT' Vynnyk
;;
;; Author: Alexander aka CosmonauT Vynnyk <cosmonaut.ok@gmail.com>
;; Version: id: web,v 0.1 22 Apr 2013 cosmonaut.ok@gmail.com
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

;;;; NEED:
;; e-find-file
;; e-swith-to-buffer +
;; e-list-buffers +
;; e-open-buffer +
;; e-save-buffer +
;; e-save-changed +
;; e-write-file
;; e-kill-buffer
;; e-eval-expression 'PREF e :'
;; e-execute-extended-command 'PREF e M-x'

;;; Code:

(in-package :stumpmacs)

(export '(*show-system-buffers-p* 
	  list-buffers
	  switch-to-buffer-from-menu
	  save-buffer
	  kill-buffer
	  kill-buffer-from-menu
	  list-buffers-matched-regexp
	  switch-to-buffer
	  save-some-buffers))

(defvar *show-system-buffers-p* nil
  "Is it needed to show system buffers, marked by stars. Ex. *scratch*")

(defmethod list-all-buffers ((emacs emacs))
  "Get list of all buffers names" ;; there is no sense to get 
  (cl-ppcre:split                 ;; all object of emacs buffer
   "\"+\ \"+|\"+"                 ;; It`s actual only inside of
   (cl-ppcre:regex-replace-all    ;; emacs code
    "\\(\"|\"\\)" 
    (eval-on-daemon emacs "(mapcar (function buffer-name) (buffer-list))") "")))

(defmethod list-buffers ((emacs emacs))
  "Get list of buffer names"
  (if *show-system-buffers-p*
      (list-all-buffers emacs)
    (remove-from-list-by-regex "\\*[a-z,A-Z,0-9].*\\*$" (list-all-buffers emacs))))

(defmethod list-buffers-matched-regexp (regexp (emacs emacs))
  (labels ((get-from-list (regexp list)
			  (cond ((null list) nil)
				((not (null
				       (cl-ppcre:scan-to-strings regexp (car list))))
				 (cons (car list) (get-from-list regexp (cdr list))))
				(t (get-from-list regexp (cdr list))))))
    (get-from-list regexp (list-all-buffers emacs))))

;;; StumpWM types
(define-stumpwm-type :emacs-buffer (input prompt)
  (let ((*current-input-history-slot* :emacs-buffer))
    (or (argument-pop-rest input)
	(completing-read (current-screen) prompt (list-buffers (current-daemon-or-start-one)) :require-match nil))))

(define-stumpwm-type :emacs-existent-buffer (input prompt)
  (let ((*current-input-history-slot* :emacs-buffer))
    (or (argument-pop-rest input)
	(completing-read (current-screen) prompt (list-buffers (current-daemon-or-start-one)) :require-match t))))

(define-stumpwm-type :emacs-commands (input prompt)
  (let ((cmds (or (emacs-commands (current-daemon))
		  (setf
		   (emacs-commands (current-daemon))
		   (cl-ppcre:split
		    ";"
		    (batch-on-emacs
		     (current-daemon)
		     "(mapatoms (lambda (x) (and (fboundp x) (commandp (symbol-function x)) (princ (concat (symbol-name x) \";\")))))")))))
	(*current-input-history-slot* :emacs-commands))
    (or (argument-pop-rest input)
	(completing-read (current-screen)
			 prompt
			 (emacs-commands (current-daemon))
			 :require-match nil))))
;;; /StumpWM types

(defmethod current-buffer ((emacs emacs))
  "Get current emacs buffer name"
  (car (list-buffers emacs)))

;; (defun switch-to-buffer-from-menu ()
;;   (let ((buffer (stumpwm::select-from-menu (current-screen)
;; 				  (list-buffers (current-daemon-or-start-one))))
;; 	(switch-to-buffer (get-cmd switch-to-buffer)))
;;     (eval-on-daemon
;;      (current-daemon-or-start-one)
;;      (concatenate 'string (car switch-to-buffer)
;; 		  buffer
;; 		  (cadr switch-to-buffer)))))

(defmethod switch-to-buffer (buffer-name (emacs emacs) &optional new-frame)
  "Switches emacs daemon to needed buffer"
  (let ((swbc (get-cmd switch-to-buffer)))
    (if (null new-frame)
	(eval-on-daemon emacs
			(concatenate 'string (car swbc)
				     buffer-name
				     (cadr swbc)))
      (eval-on-daemon emacs
		      (concatenate 'string (car swbc)
				   buffer-name
				   (cadr swbc)) :new-frame t))))

(defmethod switch-to-buffer-from-menu ((emacs emacs) &optional new-frame)
  "Switches emacs daemon to needed buffer from menu"
  (let ((buffer (stumpwm::select-from-menu (current-screen) (list-buffers emacs))))
    (when (not (null buffer))
      (switch-to-buffer buffer emacs new-frame))))

(defmethod save-buffer (buffer-name (emacs emacs))
  "Save buffer at daemon, associated with file"
  (let ((save-buffer-cmd (get-cmd save-buffer)))
    (eval-on-daemon emacs
		    (concatenate 'string
				 (nth 0 save-buffer-cmd)
				 buffer-name
				 (nth 1 save-buffer-cmd)
				 buffer-name
				 (nth 2 save-buffer-cmd)))))

(defmethod kill-buffer (buffer-name (emacs emacs))
  "Kills buffer at daemon"
  (let ((kill-buffer-cmd (get-cmd kill-buffer)))
    (eval-on-daemon emacs
		    (concatenate 'string
				 (car kill-buffer-cmd)
				 buffer-name
				 (cadr kill-buffer-cmd)))))

(defmethod kill-buffer-from-menu ((emacs emacs))
  "Kills buffer at daemon"
  (kill-buffer
   (stumpwm::select-from-menu (current-screen) (list-buffers emacs)) emacs))

(defmethod save-some-buffers ((emacs emacs))
  "Save modified buffers, associated with files"
  (eval-on-daemon emacs (get-cmd save-some-buffers)))

(defmethod write-file (buffer-name file (emacs emacs))
  (let ((write-f-cmd (get-cmd write-file)))
    (eval-on-daemon emacs
		    (concatenate 'string
				 (nth 0 write-f-cmd)
				 buffer-name
				 (nth 1 write-f-cmd)
				 file
				 (nth 2 write-f-cmd)))))

(defmethod find-file (file (emacs emacs))
  "Open file in emacs buffer"
  (let ((find-f-cmd (get-cmd find-file)))
    (eval-on-daemon emacs
		    (concatenate 'string (nth 0 find-f-cmd) file (nth 1 find-f-cmd)) :new-frame t)))

;; Commands
(defcommand e-find-file (file) ((:file "Input filename: "))
  "Open file in current emacs daemon"
  (find-file file (current-daemon)))

(defcommand e-switch-to-buffer (buffer) ((:emacs-buffer "Input buffer name: "))
  "Switches emacs daemon to needed buffer"
  (switch-to-buffer buffer (current-daemon)))

(defcommand e-list-buffers () ()
  "Docstring"
  (let* ((emacs (current-daemon-or-start-one))
	 (buffer (stumpwm::select-from-menu (current-screen)
				   (list-buffers emacs)))
	 (switch-to-buffer (get-cmd switch-to-buffer)))
    (when (not (null buffer))
      (eval-on-daemon emacs
		      (concatenate 'string
				   (car switch-to-buffer)
				   buffer
				   (cadr switch-to-buffer)) :new-frame t))))

(defcommand e-open-buffer (buffer) ((:emacs-buffer "Input buffer name: "))
  "Opens emacs daemon to needed buffer"
  (switch-to-buffer buffer (current-daemon) t))

(defcommand e-save-buffer (buffer) ((:emacs-existent-buffer "Input buffer name: "))
  "Docstring"
  (let ((ret (save-buffer buffer (current-daemon))))
    (if (equal ret "")
	(message "Buffer ~a saved" buffer)
      (message "Failed to save buffer ~a (does buffer-file exists)" buffer))))

(defcommand e-save-some-buffers () ()
  "Writes to files all changed buffers, associated with files "
  (let ((ret (cl-ppcre:regex-replace-all "\"\\(|\\)\"" (save-some-buffers (current-daemon)) "")))
    (cond ((equal ret (format nil "t~%"))
	   (message "All possible buffers saved"))
	  ((equal ret (format nil "No files need saving~%"))
	   (message ret))
	  (t (message "Failed save some buffers")))))

(defcommand e-write-file (buffer file) ((:emacs-existent-buffer "Input buffer name: ") (:file "Input filename: "))
  "Docstring"
  (write-file buffer file (current-daemon)))

(defcommand e-kill-buffer (buffer) ((:emacs-existent-buffer "Input buffer name: "))
  "Kill buffer at current daemon"
  (let ((ret (kill-buffer buffer (current-daemon))))
    (if (equal ret (format nil "t~%"))
	(message "Buffer ~a killed" buffer)
      (message "Failed to kill buffer: ~a" ret))))

(defcommand e-eval-expression (string) ((:rest "Input expression to eval: "))
  "Evaluate expression on the emacs daemon"
  (cl-ppcre:regex-replace-all "\"|\\(|\\)"
			      (eval-on-daemon (current-daemon) string) ""))

(defcommand e-execute-extended-command (cmd) ((:emacs-commands "Command: "))
  "Docstring"
  (let ((exec-cmd (get-cmd execute-extended-command)))
    (cl-ppcre:regex-replace-all
     "\"|\\(|\\)"
     (eval-on-daemon (current-daemon)
		     (concatenate 'string (nth 0 exec-cmd) (current-buffer (current-daemon)) (nth 1 exec-cmd) cmd (nth 2 exec-cmd))) "")))

(defcommand e-connect () ()
  "Connect emacsclient to current emacs daemon"
  (let* ((cur-daemon (current-daemon))
	 (client (emacs-client cur-daemon))
	 (socket (get-arg socket))
	 (name (princ-to-string (emacs-name cur-daemon)))
	 (exec (get-arg exec))
	 (run (get-arg new-frame)))
    (if (ping-daemon cur-daemon)
	(run-shell-command
	 (make-arg-string client run socket name))
      (message "No emacs servers running"))))
