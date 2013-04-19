#lang racket

(require 2htdp/image)
(require 2htdp/universe)

(require "graphDraw.rkt")
(require "graphGen.rkt")


;; world is a graph
(struct world (current-label graph))

(define init-current-label 0)

; make a random graph with 
; 15 nodes 
; 15 edges
; weighted (with max-weight 15)
; not directed
(define init-g (make-random-graph 15 15 true false 15))

;; paint the current node with red
(switch-color init-current-label init-g 'red)

(define (draw w)
  (draw-graph (world-graph w) 500))

(define (tick w)
  (let*
      ((g (world-graph w))
       (c-node-label (world-current-label w))
       ;; getting the labels of the neighbors of the current-node
       (neighbors (get-neighbors c-node-label g)))
    (if (null? neighbors)
        w
        (let*
            ;; choosing a random neighbor
            ((neighbor-label (list-ref neighbors (random (length neighbors)))))
          (world
           neighbor-label
           ;; switching the color of the selected neighbor to red
           ;; and switcing the color of the current node to black
           (switch-color neighbor-label 
                         (switch-color c-node-label g 'black) 
                         'red))))))

(big-bang (world init-current-label init-g) 
          (on-tick tick 1) 
          (to-draw draw))