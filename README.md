***Note:*** This library is developed as a part of [42links](https://code.rosaelefanten.org/42links). This Git repository is not the canonical upstream repository, which, including its bug tracker, remains [there.](https://code.rosaelefanten.org/42links/tree?name=hismetic) I will, however, maintain this copy for your convenience.

# hismetic

This is a fork of [hermetic](https://github.com/eudoxia0/hermetic), a deprecated authentication framework for [Clack](https://github.com/fukamachi/clack)-based Common Lisp web applications. The [demo](https://github.com/eudoxia0/hermetic/blob/master/demo/app.lisp) remains (mostly) compatible, except that `cl-pass` has been replaced by `bcrypt` hashing.

## bcrypt?

Yes. `hismetic` uses `bcrypt` and I don't care about other algorithms. Do not suggest them.

## Usage

Load `hismetic.lisp` from inside your project, then run `(hismetic:setup)`, providing functions that access users, passwords and roles:

```lisp
(defun user-exists-p (user)
  ;; Return t or nil here, depending on whether the
  ;; user name <user> exists.
)

(defun get-user-password (user)
  ;; Return the user password. Hashing recommended.
)

(defun get-user-roles (user)
  ;; Return a list of roles for the user here.
  ;; ex.: (list :users :staff)
)

;; Set up a session:
(hismetic:setup
 :user-p #'(lambda (user) (user-exists-p user))
 :user-pass #'(lambda (user) (get-user-password user))
 :user-roles #'(lambda (user) (get-user-roles user))
 :session *session*
 :denied #'(lambda (&optional params) "Access denied."))
```

Make sure your Clack application uses sessions:

```lisp
(clack:clackup (builder :session *app*))
```

Now, `(hismetic:login)` adds a user handle to your session, `(hismetic:logout)` removes it. `hismetic.lisp` contains a couple of helper methods and macros for your convenience as well, please consider the comments in the code and/or the example application below on how to use them.

## Demo?

The reference demo application for `hismetic` is [42links](https://code.rosaelefanten.org/42links).

## "His"metic?

Well, it's not *her* metic anymore, is it?
