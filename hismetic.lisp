;; Copyright (c) 2025 tux0r. All Rights Reserved.
;; SPDX-License-Identifier: BSD-3-Clause-No-Military-License

;; A session management middleware for ningle.
;; Loosely based on eudoxia0's hermetic, MIT-licensed.
;; Src & docs: https://github.com/eudoxia0/hermetic/

(defpackage hismetic
  (:use :cl)
  (:export
   :setup
   :login
   :logged-in-p
   :logout
   :user-name
   :roles
   :role-p
   :auth
   :hash-password
   :check-password))
(in-package :hismetic)

(defparameter *user-p* nil
  "A function that takes a username string, and returns t if a user by that name exists in the database, otherwise nil.")
(defparameter *user-pass* nil
  "A function to retrieve the hash of a user's password from its username")
(defparameter *user-roles* nil
  "A function that maps a username to a list of roles.")
(defparameter *session* nil
  "The expression for accessing the session object.")
(defparameter *denied-page* nil
  "A function that gets called when a user tries to access a page without sufficient privileges")

(defun hash-password (password)
  ;; Thin wrapper around bcrypt, just in case we want to switch the algorithm some day.
  ;; We default to 13 rounds here, which makes onboarding and login "fast enough".
  ;; If we switch to 50 or something in a few decades, existing passwords won't become invalid.
  ;; Yay.
  (bcrypt:encode (bcrypt:make-password password :cost 13 :identifier "2b")))

(defun check-password (password hashed-password)
  ;; Thin wrapper around bcrypt, just in case we want to switch the algorithm some day.
  ;; Check whether the clear-text password matches the hash.
  (bcrypt:password= password hashed-password))

(defun authorize (user pass)
  (if (funcall *user-p* user)
      (check-password pass (funcall *user-pass* user))
      :no-user))

(defmacro setup (&key user-p user-pass user-roles session denied)
  "Provide functions for *user-p* and *user-pass*"
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     (setf hismetic::*user-p* ,user-p
           hismetic::*user-pass* ,user-pass
           hismetic::*user-roles* ,user-roles
           hismetic::*session* ',session
           hismetic::*denied-page* ,denied)))

(defmacro login (params on-success on-failure on-no-user)
  `(let ((user (getf ,params :|username|))
         (pass (getf ,params :|password|)))
     (declare (string user pass))
     (case (hismetic::authorize user pass)
       ((t) (progn
              ;; Store login data on the session
              (setf (gethash :username ,hismetic::*session*) user)
              (setf (gethash :roles ,hismetic::*session*) (funcall hismetic::*user-roles* user))
              ,on-success))
       ((nil) ,on-failure)
       (:no-user ,on-no-user))))

(defmacro logout (on-success on-failure)
  `(progn
     (if (logged-in-p)
         (progn (remhash :username ,hismetic::*session*)
                (remhash :roles ,hismetic::*session*)
                ,on-success)
         ,on-failure)))

;;; Functions for getting information about the logged-in user

(defmacro logged-in-p ()
  `(gethash :username ,hismetic::*session*))

(defmacro user-name ()
  ;; Technically the same as logged-in-p, but more obvious in some contexts
  `(logged-in-p))

(defmacro roles ()
  `(gethash :roles ,hismetic::*session*))

(defmacro role-p (role)
  `(member ,role (gethash :roles ,hismetic::*session*)))

(defmacro auth ((&rest roles) page &optional denied-page)
  `(if (intersection (list ,@roles) (roles))
       ,page
       ,(if denied-page
            denied-page
            `(funcall hismetic::*denied-page*))))
