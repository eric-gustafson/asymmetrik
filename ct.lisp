;;;; ct.lisp

(in-package #:ct)

(cl-interpol:enable-interpol-syntax)

(defun hash-update! (table key update-function init-function)
  "Hashtable update, inspired by various schemes. It's like upsert in dbms land"  
  (multiple-value-bind (value present) (gethash key table)
    (setf (gethash key table) 
	  (if present
	      (funcall update-function value)
	      (funcall init-function))))
  )

(defun record-split? (line)
  (if (ppcre:scan #?r"Example\s+\d+" line) line)
  )

(defun phone-number? (line)
  (if (ppcre:scan #?r"\d{3}.+\d{4}" line) line))

(defun email-extract-name (email-line)
  (cl-ppcre:register-groups-bind (name)
      (#?r"\s*(.+)@.*" email-line)
    name))

(defun extract-phone (line)
  "remove anything not a digit"
  (ppcre:regex-replace-all "[^0-9]" line ""))

(defun data-ans-divider? (line)
  (if (ppcre:scan #?r"==>" line) line))

(defun is-email? (line)
  (if (ppcre:scan #?r".*\@[^.]+\.com" line)
      line))

(defun read-data (p)
    (with-open-file (str p :if-does-not-exist nil)
      (loop for line = (read-line str nil)
	 while line
	 collect line
	   )))

(defun email-search (lst)
  (find nil lst :test #'(lambda(v le)
			  ;;(format t "~a ~a~%" le v)
			  (is-email? le)))
  )

(defun txt->records (lines)
  "returns two tables (data . answer)"
  (let ((dtable (dict))
	(atable (dict))
	(qa  0)
	(recno 0))
    (loop for line in lines do
	 (cond
	   ((record-split? line)
	    (incf recno)
	    (setf qa 0)
	    )
	   ((data-ans-divider? line)
	    (setf qa 1))
	   (t
	    (hash-update! (if (= qa 0)
			      dtable
			      atable)
			  recno
			  #'(lambda(ov)
			      (cons line ov))
			  #'(lambda() (list line))))))
    (cons dtable atable)
    )
  )

(defun get-email-address (rec)
  "returns first line that has an email signature match"
  (email-search rec)
  )

(defun get-phone-number (rec)
  (filter-map #'(lambda(line)
		  (if (and (phone-number? line)
			   (not (ppcre:scan "ax:" line))
			   ) line))
	      rec)
  )

(defun candidate-filter (line)
  (> (length line) 0))

(defun common-letter-score (a b)
  ""
  (reduce #'(lambda(s c)
	      (if (find c b :test #'equal)
		  (+ s 1)
		  s))
	  a
	  :initial-value 0)
  )

(defun score-name (name target)
  (levenshtein-score name target)
  #+nil(let ((s1 (levenshtein:distance name target))
	(cls (common-letter-score name target)))
    (/ (+ (- max-lscore s1) cls) 2)
    )
  )

(defun levenshtein-score (a b)
  "Normalize the score over the max possible score.  Subtracting from 1.  We should be able to combine with other scores through simple multiplication."
  (declare (type (a string)) (type (b string)))
  (let ((mlen (max (length a) (length b))))
    (- 1 (coerce (/ (levenshtein:distance a b)
		    mlen)
		 'float
		 ))))

(defun %get-name (rec)
  (and-let*
      ((email (get-email-address rec))
       (email-name (email-extract-name email))
       #+nil(max-lscore (apply #'max (mapcar
				 #'(lambda(target)
				     (levenshtein:distance target email-name))
				 (filter #'candidate-filter rec))))
       )
    (sort (copy-list
		 (mapcar
		  #'(lambda(str)
		      (list str
			    (score-name ;;max-lscore
					str email-name)
			    ;;max-lscore
			    (levenshtein:distance email-name str)
			    (levenshtein-score email-name str)
			    (common-letter-score email-name str)
		      email-name ))
	    (filter #'(lambda(x)
			(and (candidate-filter x)
			     (not (equal x email))))
		    
		    rec)))
	  #'>
	  :key #'cadr)
    )
  )

(defun get-name (rec)
  (caar (%get-name rec)))

(defun t1 ()
  (read-data "data"))

(defun run (data)
  (mapcar #'(lambda(a)
	      (let ((pn (car (get-phone-number a))))
		(list (get-name a)
		      (get-email-address a)
		      (extract-phone pn))
		))
	  data))

(cl-interpol:disable-interpol-syntax)

;;; "ct" goes here. Hacks and glory await!

