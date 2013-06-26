;;; -*- Mode: LISP; Syntax: Common-lisp; Package: stumpmacs -*-

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

;;; Code:

(in-package :stumpmacs)

(export '(ping-daemon
	  start-daemon
	  ping-or-start-daemon
	  eval-on-daemon
	  script-on-emacs
	  batch-on-emacs
	  stop-daemon
	  current-daemon
	  list-daemons
	  current-daemon-or-start-one
	  set-current-daemon))

;; StumpWM types
(define-stumpwm-type :emacs-daemon-name (input prompt)
  (if (null (current-daemon))
      (or (argument-pop input)
	  (read-one-line (current-screen) prompt))
    (or (argument-pop-rest input)
	(completing-read (current-screen) prompt (list-daemon-names) :initial-input (princ-to-string (emacs-name (current-daemon)))))))

(define-stumpwm-type :emacs-running-daemon-name (input prompt)
  (or (argument-pop-rest input)
      (completing-read (current-screen) prompt (list-daemon-names) :require-match t)))

(defmethod ping-daemon ((emacs emacs))
  (let ((client (emacs-client emacs))
	(exec (get-arg exec))
	(socket (get-arg socket))
	(name (princ-to-string (emacs-name emacs)))
    	(ping (concatenate 'string "'" (get-cmd ping-daemon) "'")))
    (when
	(equal (format nil "t~%")
	       (run-shell-command
		(make-arg-string client exec ping socket name) t))
      emacs)))

(defmethod start-daemon ((emacs emacs))
  (flet ((with-alt-config ()
                          (if (not (null (emacs-configfile emacs)))
                            (format nil "~a ~a"
                                    (get-arg alt-configfile) (emacs-configfile emacs))
                            (format nil ""))))
        (let* ((cmd (emacs-daemon emacs))
               (name (princ-to-string (emacs-name emacs)))
               (args
                (concatenate 'string (emacs-daemon-args emacs)
		       " " "--daemon=" name " " (with-alt-config))))
    (if (not (ping-daemon emacs))
	(progn
	  (run-shell-command
	   (make-arg-string cmd args) t)
	  (pushnew emacs *emacs-instances-list* :test #'equal-emacs-daemon-names)
	  (if (and (ping-daemon emacs)
		   (member emacs *emacs-instances-list*))
	      (progn
		(message "Daemon ~a started successful" name) emacs)
	    (message "Failed to start ~a" name)))
      (message (format nil "Instance ~a already running" name))))))

(defmethod ping-or-start-daemon ((emacs emacs))
  (if (not (ping-daemon emacs))
      (start-daemon emacs) emacs))

(defmethod eval-on-daemon ((emacs emacs) (string string) &key new-frame)
  (let ((client (emacs-client emacs))
	(socket (get-arg socket))
	(name (princ-to-string (emacs-name emacs)))
	(exec (get-arg exec))
	(run-p (when new-frame (get-arg new-frame))))
    (if (ping-daemon emacs)
	(if run-p
	    (run-shell-command
	     (make-arg-string
	      client run-p socket name exec (concatenate 'string "'" string "'")))
	  (run-shell-command
	   (make-arg-string client socket name exec (concatenate 'string "'" string "'")) t))
      (message (format nil "Instance ~a is not running" name)))))

(defmethod script-on-emacs ((emacs emacs) filename)
  (let ((edaemon (emacs-daemon emacs))
	(name (princ-to-string (emacs-name emacs)))
	(as-script (get-arg as-script)))
    (if (ping-daemon emacs)
	(run-shell-command
	 (make-arg-string edaemon as-script filename) t)
      (message (format nil "Instance ~a is not running" name)))))

(defmethod batch-on-emacs ((emacs emacs) (string string))
  (let ((edaemon (emacs-daemon emacs))
	(exec (get-arg exec))
	(batch (get-arg batch)))
    (run-shell-command
     (make-arg-string edaemon batch exec (concatenate 'string "'" string "'")) t)))

(defmethod stop-daemon ((emacs emacs))
  (let ((name (emacs-name emacs))
	(stop-daemon (get-cmd stop-daemon)))
    (if (ping-daemon emacs)
	(if (member emacs *emacs-instances-list*)
	    (progn
	      (eval-on-daemon emacs stop-daemon)
	      (setf *emacs-instances-list*
		    (remove emacs *emacs-instances-list*))
	      (if (and
		   (not (ping-daemon emacs))
		   (not (member emacs *emacs-instances-list*)))
		  (message "Daemon ~a stopped successful" name)
		(message "Failed to stop ~a" name)))
	  (message "Daemon ~a is not managed" name))
      (progn
	(setf *emacs-instances-list*
	      (remove emacs *emacs-instances-list*))
	(message (format nil "Daemon ~a is not running" name))))))
  
(defun current-daemon ()
  (car *emacs-instances-list*))

(defun list-daemons ()
  *emacs-instances-list*)

(defun current-daemon-or-start-one ()
  (if (current-daemon)
      (current-daemon)
    (start-daemon (make-instance 'emacs))))

(defmethod set-current-daemon ((emacs emacs))
  (if (and
       (member emacs *emacs-instances-list*)
       (ping-or-start-daemon emacs))
      (progn
	(setf *emacs-instances-list*
	      (remove emacs *emacs-instances-list*))
	(push emacs *emacs-instances-list*))
    (message "Daemon ~a is not managed" (emacs-name emacs))))

;;;; StumpWM commands
(defcommand e-start-daemon (name) ((:emacs-daemon-name "Input EMACS daemon name: "))
  (let ((instance (make-emacs :name (intern (string-upcase name)))))
	(if (start-daemon instance)
	    (message "Emacs daemon started"))))

(defcommand e-stop-daemon (name) ((:emacs-running-daemon-name "Input running EMACS daemon name: "))
  (let ((instance
	 (find
	  name *emacs-instances-list*
	  :test #'(lambda (x y) (equal x (princ-to-string (emacs-name y)))))))
    (if (not (null instance))
	(stop-daemon instance)
      (message "No managed daemon, named ~a" name))))

(defcommand e-restart-daemon (name) ((:emacs-running-daemon-name "Input running EMACS daemon name to restart: "))
  (let ((instance
	 (find
	  name *emacs-instances-list*
	  :test #'(lambda (x y) (equal x (princ-to-string (emacs-name y)))))))
    (if (not (null instance))
	(progn
	  (stop-daemon instance)
	  (start-daemon instance))
      (message "No managed daemon, named ~a" name))))

(defcommand e-list-daemons () ()
  (let ((instance (member-emacs-daemon-name
		   (stumpwm::select-from-menu (current-screen) (list-daemon-names))
		   *emacs-instances-list*)))
    (when (not (null instance))
      (if (set-current-daemon instance)
	  (message "Switched to ~a" (princ-to-string (emacs-name instance)))
	(message "Failed to switch to ~a" (princ-to-string (emacs-name instance)))))))

(defcommand e-switch-to-daemon (name)  ((:emacs-running-daemon-name "Input running EMACS daemon name to switch: "))
  (let ((instance (member-emacs-daemon-name name *emacs-instances-list*)))
    (if (not (null instance))
	(set-current-daemon instance))))

(defcommand-alias e-daemons e-list-daemons)
