;;; brainfuck-mode.el --- Brainfuck mode for Emacs

;; Copyright (C) 2013  by Tomoya Tanjo

;; Author: Tomoya Tanjo <ttanjo@gmail.com>
;; Keywords: brainfuck, langdoc

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This library helps you to write brainfuck in Emacs.
;; It is also an example to define eldoc functions by using langdoc.
;;
;; Requirement:
;;    langdoc.el
;;
;; To use this package, add the following line to your .emacs file:
;;     (require 'brainfuck-mode)
;; brainfuck-mode highlights some keywords for usability.
;; By using M-x eldoc-mode, you can see the help string in minibuffer.
;; Also, by using M-x bf-help:describe-symbol (or C-c f), you can see
;; more documents for each command.

;;; Code:

(require 'langdoc)
(require 'generic)


(define-generic-mode brainfuck-mode
  nil
  nil
  '(("[^]><+.,[-]+" . font-lock-comment-face)
    ("\\]\\|\\["    . font-lock-keyword-face))
  '("\\.bf\\'")
  '(define-bf-keymap bf-help:doc-fun)
  "Major mode for brainfuck")

(defvar brainfuck-mode:local-map nil "Keymap for brainfuck-mode")

(defun define-bf-keymap ()
  (setq brainfuck-mode:local-map (make-keymap))
  (define-key brainfuck-mode:local-map
      "\C-cf" 'bf-help:describe-symbol)
  (use-local-map brainfuck-mode:local-map))

(langdoc:define-help-mode bf-help "Major mode for brainfuck help" "*Brainfuck Help*"
                          'bf-help:sym-called-at-point
                          '(">" "<" "+" "-" "." "," "[" "]")
                          'bf-help:lookup-doc
                          "`\\([^']+\\)'"
                          (lambda (a b) b) (lambda (a b) b)
                          "`" "'")


(defun bf-help:doc-fun ()
  (make-local-variable 'eldoc-documentation-function)
  (setq eldoc-documentation-function
        'bf-help:minibuffer-help-string))

(defun bf-help:sym-called-at-point ()
  (unless (eobp)
    (buffer-substring-no-properties (point) (1+ (point)))))

(defun bf-help:minibuffer-help-string ()
  (interactive)
  (let* ((sym (bf-help:sym-called-at-point))
         (doc (when sym (bf-help:lookup-doc sym))))
    (when doc (bf-help:summerize-doc sym doc))))

(defun bf-help:lookup-doc (sym)
  "Returns document string for SYM."
  (cond
    ((equal sym ">") "Increment the pointer.")
    ((equal sym "<") "Decrement the pointer.")
    ((equal sym "+") "Increment the value indicated by the pointer.")
    ((equal sym "-") "Decrement the value indicated by the pointer.")
    ((equal sym ".") "Print the value indicated by the pointer.")
    ((equal sym ",") "Read one byte from input and store it in the indicated value.")
    ((equal sym "[") "Jump to the matching `]' if the indicated value is zero.")
    ((equal sym "]") "Jump to the matching `[' if the indicated value is not zero.")))

(defun bf-help:summerize-doc (sym doc)
  (concat sym " : " (car (split-string doc "[\n\r]+"))))

(provide 'brainfuck-mode)
;;; brainfuck-mode.el ends here
