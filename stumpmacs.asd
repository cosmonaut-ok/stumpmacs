(defpackage :emacs-system
  (:use :cl :asdf))

(in-package :emacs-system)

(defsystem :emacs
  :name "EMACS"
  :author "Alexander aka 'CosmonauT' Vynnyk"
  :version "2013.06.26"
  :maintainer "Alexander aka 'CosmonauT' Vynnyk"
  :license "GNU General Public License v2 or later"
  :description "StumpWM extension for better working with emacs"
  :serial t
  :components ((:file "package")
	       (:file "emacs")
	       (:file "data")
	       (:file "daemon")
	       (:file "client")
	       (:file "bindings")
	       ))