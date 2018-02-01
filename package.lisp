;;;; package.lisp

(defpackage #:ct
  (:shadowing-import-from #:serapeum fmt @ slice in scan)  
  (:use #:cl #:cl-ppcre #:cl-interpol #:alexandria #:serapeum #:levenshtein)
  )

