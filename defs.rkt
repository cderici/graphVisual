#lang racket

(provide (all-defined-out))

;; label : (or symbol? number?)
;; clr : color
(struct vertex (label [clr #:mutable]))

;; source/dest : vertex-label?
;; weight : number?
(struct edge (source dest weight))

;; weighted?, directed? : boolean 
;; V : (listof vertex?)
;; E : (listof edge?)
(struct graph (weighted? directed? V E))

;; for drawing
(struct v-posn (label color x y))
