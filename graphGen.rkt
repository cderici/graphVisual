#lang racket

(require (only-in 2htdp/image color))
(require "defs.rkt")

(provide (all-defined-out))

;; make-random-graph : number number boolean boolean boolean (number) -> graph
;;
;; Generates a random graph, with the given:
;; -- n-nodes : Number of nodes
;; -- n-edges : Number of edges
;; -- weighted? : weighted/unweighted info
;; -- directed? : directed/undirected info
;; -- max-weight : maximum possible weight that can appear in one edge
;;
;; max-weight is optional, if not provided, defaults to 1
;;
;; TODO : generate also graphs with symbol node labels
(define (make-random-graph n-nodes n-edges weighted? directed? [max-weight 1])
  (let*
      ((vertex-list (build-list n-nodes (lambda (n) (vertex n 'black))))
       (vertex-labels (map vertex-label vertex-list)))
    (graph
     weighted?
     directed?
     vertex-list
     (build-random-edges vertex-labels n-edges weighted? directed? max-weight = null))))


;; random-color
(define (random-color)
  (color (random 255) (random 255) (random 255)))

(define build-random-edges 
  (let
      ((selected-pairs null))
    (lambda (vertex-labels n-edges weighted? directed? max-weight label=? out)
      (let*
          ((rand-source (list-ref vertex-labels (random (length vertex-labels))))
           (rand-dest (list-ref vertex-labels (random (length vertex-labels)))))
        (cond
          ((zero? n-edges) out)
          ; if a selected (source,dest) pair is either 
          ((or 
            ; (s,s) or 
            (label=? rand-source rand-dest)
            ; previously generated, or  
            (memf (lambda (pair) (and (label=? (car pair) rand-source)
                                      (label=? (cadr pair) rand-dest))) selected-pairs)
            ; in the form (s,d) and there is a previously selected (d,s)
            ; and the graph is UNdirected
            (and (not directed?)
                 (memf (lambda (pair) (and (label=? (car pair) rand-dest)
                                           (label=? (cadr pair) rand-source))) selected-pairs)))
           ; Then loop
           (build-random-edges vertex-labels n-edges weighted? directed? max-weight label=? out))
          (else
           ; we are OK, record the selected pair and go on
           (begin
             (set! selected-pairs (cons (list rand-source rand-dest) selected-pairs))
             (build-random-edges vertex-labels (sub1 n-edges) weighted? directed? max-weight label=?
                                 (cons (edge rand-source rand-dest (random max-weight)) out)))))))))