#lang racket

(require 2htdp/image)
(require "defs.rkt")

(require "graphCheck.rkt")
(require "helpers.rkt")

(provide (all-defined-out))


;; width = height (= size)

;; switches the color of the node 'label' in 'g' to 'clr'
;; returns the modified (mutated) graph 
(define (switch-color label g clr)
  (let*
      ((c-node (get-vertex label (make-label=? g) (graph-V g))))
    (if (not c-node)
        (error 'switch-color (string-append "no such vertex with label : "
                                            (label->string label)))
        (begin
          (set-vertex-clr! c-node clr)
          g))))


;; draw-graph : graph number -> image
;; 
;; Draws the given graph as follows:
;; 1) Computes the position of each vertex according to the 
;; number of vertices and the given size (generates a listof v-posn)
;; 2) Draws the vertices on an empty-scene, defined by the listof v-posn
;; 3) Draws the edges
(define (draw-graph g size)
  (let*
      ((init-check? (check-graph g))
       (scn-size (* 1.2 size)))
    (if (not init-check?)
        (error 'check-graph init-check?)
        (let*-values
            ([(unit-size vertices) (geneate-positions (graph-V g) size)])
          (draw-edges
           (graph-weighted? g)
           (graph-directed? g)
           (/ unit-size 4)
           (graph-E g)
           vertices
           (make-label=? g)
           (draw-vertices vertices (/ unit-size 2) (empty-scene scn-size scn-size)))))))

;; get-neighbors : label g -> (listof labels)
;;
;; Given a vertex label, it searches the vertex and produces 
;; a list of vertex labels of its neighbors
;;
;; If the given graph is directed, only the vertices that appear on the 
;; destination side of the edges in which the given node label is on the 
;; source side, are returned.
;; (get-neighbors k <a directed-graph>) -> (k,v),(k,u),(k,o)...
;; (get-neighbors k <an undirected-graph>) -> (k,v),(u,k),(o,k)...
(define (get-neighbors label g)
  (let*
      ((label=? (make-label=? g))
       (c-node (get-vertex label label=? (graph-V g))))
    (if (not c-node)
        (error 'get-neighbors (string-append "no such vertex with label : "
                                             (label->string label)))
        (foldr append null
               (map (lambda (ec)
                      (let
                          ((src (edge-source ec))
                           (dst (edge-dest ec))
                           (directed? (graph-directed? g)))
                        (cond
                          ((label=? src label) (list dst))
                          ((and (not directed?)
                                (label=? dst label)) (list src))
                          (else null)))) 
                    (graph-E g))))))

(define (draw-vertices v-posns rad scn)
  (cond
    ((null? v-posns) scn)
    (else
     (draw-vertices (cdr v-posns) rad
                    (place-image
                     (overlay (text (label->string (v-posn-label (car v-posns))) 
                                    (round (/ rad 2))
                                    (v-posn-color (car v-posns)))
                              (rectangle (round (/ rad 2)) (round (/ rad 2)) 'solid 'white))
                     (v-posn-x (car v-posns))
                     (v-posn-y (car v-posns))
                     (place-image
                      (rectangle rad rad 'solid (v-posn-color (car v-posns)))
                      (v-posn-x (car v-posns))
                      (v-posn-y (car v-posns))
                      scn))))))

(define (draw-edges weighted? directed? rad E vertices label=? scene)
  (cond
    ((null? E) scene)
    (else
     (let* ((c-edge (car E))
            (c-weight (edge-weight c-edge))
            (c-source (get-vertex (edge-source c-edge) label=? vertices))
            (c-dest (get-vertex (edge-dest c-edge) label=? vertices))
            (relative-x (make-relativity-func (v-posn-x c-dest) (v-posn-x c-source)))
            (relative-y (make-relativity-func (v-posn-y c-dest) (v-posn-y c-source)))
            (e-start-x (relative-x (v-posn-x c-source) (/ rad 1)))
            (e-start-y (relative-y (v-posn-y c-source) (/ rad 1)))
            (e-end-x ((invert-arith relative-x) (v-posn-x c-dest) (/ rad 1)))
            (e-end-y ((invert-arith relative-y) (v-posn-y c-dest) (/ rad 1)))
            
            (gap (* rad 5)) ; '5' -> just in case
            ; true is curve, false is line
            ; draw curve if : 
            (line-or-curve (or 
                            ; aligned horizontally
                            (and (> (abs (- e-start-x e-end-x)) gap)
                                 (= e-start-y e-end-y))
                            ; aligned vertically
                            (and (> (abs (- e-start-y e-end-y)) gap)
                                 (= e-start-x e-end-x))
                            ; aligned diagonally
                            (and (= (abs (- e-start-x e-end-x)) 
                                    (abs (- e-start-y e-end-y)))
                                 (> (abs (- e-start-x e-end-x)) gap))
                            ))
            
            (edge-base-img (if line-or-curve
                               ; we have a curve
                               (add-curve scene 
                                          e-start-x e-start-y (curve-angle relative-x relative-y true) 1/2
                                          e-end-x e-end-y (curve-angle relative-x relative-y false) 1/2 'black)
                               ; we have a line
                               (add-line scene
                                         e-start-x e-start-y
                                         e-end-x e-end-y 'black)))
            ;; weighted?
            (edge-with-weights (if (not weighted?) edge-base-img
                                   (place-image (overlay (text (number->string c-weight) (round (/ rad 2)) 'black)
                                                         (rectangle (round (/ rad 1.75)) (round (/ rad 1.75)) 'solid 'white))
                                                (weight-position relative-x relative-y e-start-x e-start-y e-end-x e-end-y true line-or-curve)
                                                (weight-position relative-x relative-y e-start-x e-start-y e-end-x e-end-y false line-or-curve)
                                                edge-base-img)))
            ;; directions? : will be painted with the color of the source node (indicating where does it coming?)
            (final-img (if (not directed?) edge-with-weights
                           (place-image (circle (round (/ rad 6)) 'solid (v-posn-color c-source))
                                        e-end-x
                                        e-end-y
                                        edge-with-weights)))
            
            )
       (draw-edges weighted? directed? rad (cdr E) vertices label=? final-img)))))

;; finds the next natural square number
;; and produces its square root (obviously integer)
(define (find-next-nat-sqr n)
  (if (integer? (sqrt n))
      (sqrt n)
      (find-next-nat-sqr (add1 n))))


(define (geneate-positions vertices size)
  (let*
      ((labels (map vertex-label vertices))
       (n (length labels))
       (division (find-next-nat-sqr n))
       (unit-size (/ size division))
       (initial-x (+ (* size 0.05) (/ unit-size 2)))
       (initial-y (+ (* size 0.05) (/ unit-size 2))))
    (values 
     unit-size
     (foldr (lambda (vert v-posns)
              (if (> (+ (v-posn-x (car v-posns)) 
                        unit-size) size) ; we are getting out of picture
                  ; start from the next row
                  (cons (v-posn (vertex-label vert)
                                (vertex-clr vert)
                                initial-x 
                                (+ (v-posn-y (car v-posns))
                                   unit-size))
                        v-posns)
                  (cons (v-posn (vertex-label vert)
                                (vertex-clr vert)
                                (+ (v-posn-x (car v-posns))
                                   unit-size)
                                (v-posn-y (car v-posns)))
                        v-posns)))
            (cons (v-posn (vertex-label 
                           (car vertices))
                          (vertex-clr
                           (car vertices))
                          initial-x 
                          initial-y) 
                  null)
            (cdr vertices)))))




;; switches between + and - 
;; if op is neither of them, it returns op
(define (invert-arith op)
  (if (eq? op +) - 
      (if (eq? op -) +
          op)))

(define (make-relativity-func pos1 pos2)
  (cond
    ((> pos1 pos2) +)
    ((< pos1 pos2) -)
    (else (lambda (x y) x))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; We use these functions (below) to determine the parameters of 
;; the curve
(define (vertical? rel-x)
  (and (not (eq? rel-x +))
       (not (eq? rel-x -))))

(define (horizontal? rel-y)
  (and (not (eq? rel-y +))
       (not (eq? rel-y -))))


;; normal angle calculations are based on left->right or up->down
;; drawings, but we might as well have the inverted drawings according 
;; to the source/dest positions
;; start? : true->from start // false->from end
(define (curve-angle rel-x rel-y start?)
  (cond
    ; vertical?
    ((vertical? rel-x) (if 
                        (eq? rel-y +) ; if we draw up->down 
                        (if start? 220 -40)
                        (if start? 140 40)))
    ; horizontal?
    ((horizontal? rel-y) (if
                          (eq? rel-x +) ; if we draw left->right
                          (if start? 40 -40)
                          (if start? 140 -140)))
    ; diagonal? (i.e. we are sure that we draw a curve,
    ; and it's neither vertically nor horizontally aligned)
    (else 
     (if 
      (eq? rel-x rel-y)
      ; leaning to left -> relative-x and relative-y 's must be the same
      (if (eq? rel-x +) ; if we draw again left->right
          (if start? 280 -10)
          (if start? 170 100))
      ; leaning to right -> relative-x and relative-y 's must be different
      (if (eq? rel-x +) ; if we draw again left->right
          (if start? 10 80)
          (if start? -90 190))
      ))))

;; x? : true->we are looking for x value
(define (weight-position rel-x rel-y sx sy ex ey x? curve?)
  (let* (
         (base-x (/ (+ sx ex) 2))
         (base-y (/ (+ sy ey) 2))
         )
    (if (not curve?) 
        ; we have a line
        (if x? base-x base-y)
        ; we have a curve
        (cond
          ; we search for x and drawing vertical curve
          ((and x? (vertical? rel-x))
           (- base-x (* (cos (degrees->radians 50)) (/ (abs (- sy ey)) 2.2))))
          ; we search for y and drawing a horizontal curve
          ((and (not x?) (horizontal? rel-y))
           (- base-y (* (sin (degrees->radians 50)) (/ (abs (- sx ex)) 3.2))))
          ; right leaning diagonal
          ((not (eq? rel-x rel-y)) 
           (if x? 
               (+ base-x (* (cos (degrees->radians -60)) (/ (abs (- sy ey)) 2.2)))
               (+ base-y (* (sin (degrees->radians 47)) (/ (abs (- sx ex)) 3.2)))))
          ; left leaning diagonal
          ((eq? rel-x rel-y)
           (if x? 
               (- base-x (* (cos (degrees->radians -60)) (/ (abs (- sy ey)) 2.2)))
               (+ base-y (* (sin (degrees->radians 45)) (/ (abs (- sx ex)) 3.2)))))
          (else
           (if x? base-x base-y))))))