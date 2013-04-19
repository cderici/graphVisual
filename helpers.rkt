#lang racket

(require "defs.rkt")

(provide (all-defined-out))

;; make-label=? : graph -> (label label -> boolean)
;; This is for (possibly future) generalization, it produces an 
;; equality checking function (predicate) for labels in the given graph
(define (make-label=? g)
  (cond 
    ((symbol? (vertex-label (list-ref (graph-V g) (random (length (graph-V g))))))
     symbol=?)
    ((number? (vertex-label (list-ref (graph-V g) (random (length (graph-V g))))))
     =)
    (else
     (error 'label-check-func "something wrong with vertex labels"))))


;; label->string : label -> string
;; (possibly future) generalization for printing, 
;; produces a string representation for the given label
(define (label->string label)
  (cond 
    ((symbol? label)
     (symbol->string label))
    ((number? label)
     (number->string label))
    (else
     (error 'label->string "something wrong with vertex labels"))))

(define (listof pred?)
  (lambda (ls)
    (andmap pred? ls)))

;; get-vertex : label (listof v-posn) : vertex
;; vertices can be (or (listof v-posn) (listof vertex))
(define (get-vertex label label=? vertices)
  (let*
      ((label-getter (if ((listof vertex?) vertices) vertex-label
                         (if ((listof v-posn?) vertices) v-posn-label
                             (error 'get-vertex "something wrong with the vertex list")))))
    (cond
      ((null? vertices) false)
      ((label=? label (label-getter (car vertices)))
       (car vertices))
      (else
       (get-vertex label label=? (cdr vertices))))))
