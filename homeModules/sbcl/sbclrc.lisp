#|
;;; The following lines added by ql:add-to-init-file:
#-quicklisp
(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp"
                                       (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))
|#

(setf *print-circle* t)

(defun clear nil
  (sb-ext:run-program "clear" nil :search t :output t)
  (values))

(defun range (a &optional b c)
  (unless b
    (setf b a
          a 0
          c 1))
  (unless c
    (if (< a b)
        (setf c 1)
        (setf c -1)))
  (when (zerop c)
    (error "range arg 3 must not be zero"))
  (when (< (* (- b a) c) 0)
    (return-from range nil))
  (do ((result nil (cons a result))
       (a a (incf a c)))
      ((<= (* (- b a) c) 0)
       (nreverse result))))

(defun print-secs (secs)
  (labels ((secs (secs)
             (multiple-value-bind (mins secs) (floor secs 60)
               (unless (= mins 0)
                 (mins mins))
               (format t "~as~%" (floor secs))))
           (mins (mins)
             (multiple-value-bind (hours mins) (floor mins 60)
               (unless (= hours 0)
                 (hours hours))
               (format t "~am " (floor mins))))
           (hours (hours)
             (multiple-value-bind (days hours) (floor hours 24)
               (unless (= days 0)
                 (days days))
               (format t "~ah " (floor hours))))
           (days (days)
             (format t "~ad " days)))
    (secs secs)))

(defun to-secs (&rest rest)
  (labels ((to-secs-impl (acc data)
                         (ecase (length data)
                           (0 acc)
                           ;; secs
                           (1 (+ acc (car data)))
                           ;; mins
                           (2 (to-secs-impl (* (+ acc (car data)) 60) (cdr data)))
                           ;; hours
                           (3 (to-secs-impl (* (+ acc (car data)) 60) (cdr data)))
                           ;; days
                           (4 (to-secs-impl (* (+ acc (car data)) 24) (cdr data))))))
    (to-secs-impl 0 rest)))

(defun fact (n)
  (labels ((fact-impl (n acc)
                      (if (<= n 1)
                        acc
                        (fact-impl (1- n) (* acc n)))))
    (fact-impl n 1)))
