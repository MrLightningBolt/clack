#|
  This file is a part of Clack package.
  URL: http://github.com/fukamachi/clack
  Copyright (c) 2011 Eitarow Fukamachi <e.arrows@gmail.com>

  Clack is freely distributable under the LLGPL License.
|#

#|
  Testing Clack Applications.

  Author: Eitarow Fukamachi (e.arrows@gmail.com)
|#

(clack.util:namespace :clack.test
  (:use :cl
        :cl-test-more)
  (:export :test-app
           :define-app-test
           :*clack-test-handler*
           :*clack-test-port*
           :*enable-debug-p*))

(defvar *clack-test-handler* 'clack.handler.hunchentoot
  "Backend Handler to run tests on. String or Symbol are allowed.")

(defvar *clack-test-port* 8080
  "HTTP port number of Handler.")

(defvar *enable-debug-p* t)

(defun test-app (app client &optional desc)
  "Test Clack Application."
  (let* ((handler
          (or (find-package *clack-test-handler*)
              (error "Handler package is not found. Forgot to load it?: ~A"
                     *clack-test-handler*)))
         (acceptor (funcall (intern "RUN" handler)
                            app
                            :port *clack-test-port*
                            :debug *enable-debug-p*)))
    (when desc (diag desc))
    (unwind-protect
        (funcall client)
      (funcall (intern "STOP" handler) acceptor))))

(defmacro define-app-test (desc app client &optional (enable-debug-p *enable-debug-p*))
  "Define tests for Clack Application. This just wrap `cl-test-more:deftest', so you can run this test by calling `(cl-test-more:run-test :foo)'."
  `(deftest ,desc
       (let ((*enable-debug-p* ,enable-debug-p))
         (test-app ,app ,client))))
