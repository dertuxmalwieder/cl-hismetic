(asdf:defsystem "hismetic"
  :description "An authentication framework for Clack-based Common Lisp web applications"
  :version "1.9.1" 
  :author "tux0r"
  :license "BSD-3-Clause-No-Military-License"
  :components ((:file "hismetic"))
  :depends-on (:cl-bcrypt))
