#lang racket

(require "defs.rkt")

(provide (all-defined-out))

;; check-graph : graph -> boolean
;; checks if
;; - the vertex labels are valid (number or symbol)
;; - there are no duplicate vertices (with same label)
;; - there are no duplicate edges (with same source/dest, different weight)
;; - vertex labels in edges are valid
(define (check-graph g)
  (let*
      ((labels (map vertex-label (graph-V g)))
       (edge-sources (map edge-source (graph-E g)))
       (edge-dests (map edge-dest (graph-E g))))
    (cond
      ;((begin (display "checking graph representation...") false) 'dummy)
      ((not (vertex-labels-ok? labels))
       "vertex labels are not valid")
      ((not (unique-vertices? labels))
       "there are duplicate vertices")
      ;((not (edge-points-ok? labels edge-sources edge-dests))
      ; "vertex labels in edges are not valid")
      ((not (no-duplicates? (map list edge-sources edge-dests)))
       "there are duplicate edges")
      (else
       ;(begin (display "OK...\n\n") (newline)
              true
      ;        )
      ))))

;; vertex-labels-ok? : (listof label) -> boolean
;; Checks if the given labels are either numbers or symbols
;; CORRECT : it should check if all of them are numbers or all of them are symbols
(define (vertex-labels-ok? labels)
  (andmap (λ (l) (or (symbol? l) (number? l))) labels))

;; unique-vertices? : (listof label) -> boolean
;; Checks if the given list of labels contain any duplicate label
(define (unique-vertices? labels)
  (= (length labels) 
     (length (foldr (lambda (x y)
                      (if (member x y)
                          y
                          (cons x y))) empty labels))))

;; no-duplicates? : (listof (listof label label)) -> boolean
;; Checks if the given list of edges contain any duplicates
(define (no-duplicates? s-d-pairs)
  (foldr (lambda (edge total)
           (if (not total)
               total
               (if (member edge total)
                   false
                   (cons edge total)))) empty s-d-pairs))
