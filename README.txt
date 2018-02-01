* Description
  There are two implementations, a common lisp and an python
  implementation.  The python implementation 'should' be easy to use
  ;).  I didn't use any external packages, and relied on an
  implementation of levenshtein algorithm from Wikipedia, rather than
  deal with packages for this exercise.

* Basic algorithm
  Extract the name from the email address and use that in the
  computation against the other lines from the business card to
  find the name of the person, rather than say the company name.

* Usage
  ./ct.py

* Manifest
   ct.py     Python implementation of the exercise
   ct.lisp   Lisp implementation of the exercise
   data      Copy and pasted the data from website

* Output
  ['msmith@asymmetrik.com\n', '4105551234', 'Mike Smith\n']
  ['lisa.haung@foobartech.com\n', '4105551234', 'Lisa Haung\n']
  ['awilson@abctech.com\n', '17035551259', 'Arthur Wilson\n']
