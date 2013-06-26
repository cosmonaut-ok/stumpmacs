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

(export '(get-arg
	  get-cmd
	  emacs-name
	  emacs-daemon
	  emacs-daemon-args
	  emacs-client
	  emacs-client-args
	  emacs-configfile
	  emacs-commands
	  make-emacs
	  list-daemon-names))

(defvar *emacs-arg-hash* (make-hash-table))
(defvar *emacs-cmd-hash* (make-hash-table))
(defvar *emacs-instances-list* nil)

;; emacs class
(defclass emacs ()
  ((name :initform (gensym "EMACS-") :accessor emacs-name)
   (daemon :initform "emacs" :accessor emacs-daemon)
   (daemon-args :initform nil :accessor emacs-daemon-args)
   (client :initform "emacsclient" :accessor emacs-client)
   (configfile :initform nil :accessor emacs-configfile)
   (client-args :initform nil :accessor emacs-client-args)
   (commands :initform nil :accessor emacs-commands)))

;;;; common functions
(defmacro get-arg (name)
  `(gethash ',name *emacs-arg-hash*))

(defmacro set-arg (name val)
  `(setf (gethash ',name *emacs-arg-hash*) ,val))

(defmacro get-cmd (name)
  `(gethash ',name *emacs-cmd-hash*))

(defmacro set-cmd (name val)
  `(setf (gethash ',name *emacs-cmd-hash*) ,val))

(defun make-arg-string (&rest args)
  (cond ((null args)
	 nil)
	((and (not (null (car args))) (null (cdr args)))
	 (car args))
	(t (concatenate 'string (car args) " " (apply #'make-arg-string (cdr args))))))

(defun remove-from-list-by-regex (regex list)
  (cond ((null list) nil)
	((scan-to-strings regex (car list))
	 (remove-from-list-by-regex regex (cdr list)))
	(t (cons (car list) (remove-from-list-by-regex regex (cdr list))))))

(defun list-daemon-names ()
  (mapcar #'(lambda (x) (princ-to-string (emacs-name x))) *emacs-instances-list*))

(defmethod equal-emacs-daemon-names ((emacs1 emacs) (emacs2 emacs))
  (if (equal (princ-to-string (emacs-name emacs1))
	     (princ-to-string (emacs-name emacs2)))
      t nil))

(defun member-emacs-daemon-name (name list)
  (cond ((null list) nil)
	((equal name (princ-to-string (emacs-name (car list))))
	 (car list))
	(t (member-emacs-daemon-name name (cdr list)))))

(defun make-emacs (&key name daemon daemon-args client client-args configfile)
  "Initialization function"
  (let ((instance (make-instance 'emacs)))
    (when (not (null name))
      (setf (emacs-name instance) (intern (string-upcase name))))
    (when (not (null daemon))
      (setf (emacs-daemon instance) daemon))
    (when (not (null daemon-args))
      (setf (emacs-daemon-args instance) daemon-args))
    (when (not (null client))
      (setf (emacs-client instance) client))
    (when (not (null client-args))
      (setf (emacs-client-args instance) client-args))
    (when (not (null configfile))
      (setf (emacs-configfile instance) configfile))
    (pushnew instance *emacs-instances-list* :test #'equal-emacs-daemon-names)
    instance))
;;;; /common functions
