;;;; ct.asd

(asdf:defsystem #:ct
  :description "Describe ct here"
  :author "Your Name <your.name@example.com>"
  :license "Specify license here"
  :serial t
  :depends-on (
	       :cl-ppcre
	       :cl-interpol
	       :serapeum
	       :alexandria
	       :levenshtein
	       )
  :components ((:file "package")
               (:file "ct")))

