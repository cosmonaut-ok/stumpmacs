;;; -*- Mode: LISP; Syntax: Common-lisp; Package: stumpmacs-loader -*-

;; Copyright 2013 Alexander aka 'CosmonauT' Vynnyk
;;
;; Author: Alexander aka CosmonauT Vynnyk <cosmonaut.ok@gmail.com>
;; Version: id: web,v 0.1 26 Jun 2013 cosmonaut.ok@gmail.com
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
;; "StumpWM extension for better working with emacs"
;;
;;; Code:

(defpackage stumpmacs-loader
  (:use :cl :dswm))

(in-package :stumpmacs-loader)


(defvar *my-dirname* (dirname *load-pathname*))

(format t "~a" *my-dirname*)

(and
 (load (merge-pathnames "package.lisp" *my-dirname*))
 (load (merge-pathnames "emacs.lisp" *my-dirname*))
 (load (merge-pathnames "data.lisp" *my-dirname*))
 (load (merge-pathnames "daemon.lisp" *my-dirname*))
 (load (merge-pathnames "client.lisp" *my-dirname*))
 (load (merge-pathnames "bingings.lisp" *my-dirname*)))