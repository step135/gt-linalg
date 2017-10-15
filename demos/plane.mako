## -*- coffee -*-

<%inherit file="base2.mako"/>

<%block name="title">A Plane</%block>

##

new Demo {}, () ->
    window.mathbox = @mathbox

    coeffs = ['y', 'z']
    if @urlParams.coeffs?
        coeffs = @urlParams.coeffs.split ","

    cf = (i) -> params[coeffs[i]]

    updateCaption = () =>
        katex.render """(x,\\,y,\\,z)
                          = (1-#{coeffs[0]}-#{coeffs[1]},\\,#{coeffs[0]},\\,#{coeffs[1]})
                          = \\color{#00ff00}{({#{(1-cf(0)-cf(1)).toFixed(2)}},\\,
                             {#{cf(0).toFixed(2)}},\\,
                             {#{cf(1).toFixed(2)}})}
                     """, @vecElt

    vectors = [[-1, 1, 0], [-1, 0, 1]]

    # gui
    params = {}
    params[coeffs[0]] = 0.0
    params[coeffs[1]] = 0.0
    gui = new dat.GUI()
    gui.add(params, coeffs[0], -10, 10).step(0.1).onChange updateCaption
    gui.add(params, coeffs[1], -10, 10).step(0.1).onChange updateCaption

    view = @view()

    # Plane
    clipCube = @clipCube view,
        draw:   true
        hilite: false
        color:  new THREE.Color .75, .75, .75
    trans = clipCube.clipped.transform position: [1, 0, 0]

    subspace = @subspace
        vectors: vectors
        live: false
    subspace.draw trans

    @grid trans, vectors: vectors

    # Parameterized point
    view
        .array
            channels: 3
            width:    1
            expr: (emit) ->
                emit 1 - cf(0) - cf(1), cf(0), cf(1)
        .point
            color:  "rgb(0,200,0)"
            size:   15
            zTest:  false
            zWrite: false
        .format
            expr: (x, y, z) ->
                "(" + x.toPrecision(2) + ", " \
                    + y.toPrecision(2) + ", " \
                    + z.toPrecision(2) + ")"
        .label
            outline:    2
            background: "black"
            color:      "white"
            offset:     [0,20]
            size:       20
            zTest:      false
            zWrite:     false

    # Caption
    @caption '''<p><span id="eqn-here"></span></p>
                <p><span id="vec-here"></span></p>
             '''
    katex.render "\\color{red}{x+y+z=1}", document.getElementById 'eqn-here'
    @vecElt = document.getElementById 'vec-here'
    updateCaption()
