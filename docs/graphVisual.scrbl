#lang scribble/manual
@(require scribble/eval)
@title{Graph Visualization}
@(author "Caner Derici")

GraphVisual is a tool to automatically produce image representation of a given graph. It also includes functionalities to build randomly generated graphs.

The code is seperated into five distinct parts:

@itemlist[
          @item{graphDraw: includes functions related to drawing a graph representation.}
           @item{graphCheck: checks the validity of a graph representation defined by defs.}
           @item{graphGen: includes functionality to build random graphs.}
           @item{defs: main definitions.}
           @item{helpers: more somewhat general utility functions used by several parts in the code base.}]

@section[#:tag "defs"]{Definitions}

@defstruct*[graph ([weighted? boolean?]
                   [directed? boolean?]
                   [V (listof vertex?)]
                   [E (listof edge?)]
                   )
            ]{Defines a simple representation for a graph. Note that weighted? and directed? informations are being set explicitly.}

@defstruct*[vertex ([label (or/c symbol? number?)] [clr (#:mutable color?)])]{Structure for a single vertex, 
                                                                              defined by a label (symbol or number), and a color. 
                                                                              Note that @italic{clr} is mutable.}

@defstruct*[edge ([source vertex-label?] 
                  [dest vertex-label?]
                  [weight number?]
                  )
            ]{Defines a single edge from @italic{source} to @italic{dest} with @italic{weight}.}
             
@section[#:tag "valid"]{Validating Graph Representations}

Primary function responsible for the validity of a graph representation is:

@defproc[(check-graph [g graph?]) boolean?]{Checks if ;
@itemlist[@item{the vertex labels in V are valid (number or symbol)}
           @item{the vertices in edges are really the ones in V}
           @item{there are no duplicate vertices (with the same label)}
           @item{there are no duplicate edges (with same source/dest)}]
}

The main reason for this function is to be able to validate the graphs generated either manually or by using @italic{make-random-graph}.

@section[#:tag "draw"]{Drawing Graphs}

Here's an example:

@(image "exampleGraphImage.png")

@section[#:tag "rand"]{Generating Random Graphs}

@defproc[(make-random-graph [n-nodes number?]
                            [n-edges number?]
                            [weighted? boolean?]
                            [directed? boolean?]
                            [max-weight* number?]) graph?]{Produces a random graph with the given number of nodes and the number of edges. Weights are choosen randomly within the range [0..max-weight].}

@section[#:tag "anim"]{Animating Graphs}

@;{
See @secref{chickens}.

  @defmodule[my-lib/helper]{The @racketmodname[my-lib/helper]

  module---now with extra cows!}

  

  @defproc[(my-helper [lst list?])

           (listof (not/c (one-of/c 'cow)))]{

  

   Replaces each @racket['cow] in @racket[lst] with

   @racket['aardvark].

  

   @examples[

     (my-helper '())

     (my-helper '(cows such remarkable cows))

   ]}
}