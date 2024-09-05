using ColorSchemes, Colors

_crossvalidation = (
    training = ColorSchemes.Morgenstern[4],
    testing = ColorSchemes.Morgenstern[7],
    validation = ColorSchemes.Morgenstern[1]
)

abcol = ColorSchemes.Egypt[4]
prcol = ColorSchemes.Egypt[2]

_range = (
    absent = abcol,
    present = prcol,
    absentbg = alphacolor(abcol, 0.2),
    presentbg = alphacolor(prcol, 0.2),
    gain = ColorSchemes.Isfahan1[5],
    nochange = ColorSchemes.Isfahan1[3],
    loss = ColorSchemes.Isfahan1[2],
)

# Semantic colors for the book
bkcol = (
    nodata = colorant"#DDDDDD",
    generic = colorant"#222222",
    seq = ColorSchemes.linear_gow_60_85_c27_n256,
    div = ColorSchemes.diverging_protanopic_deuteranopic_bwy_60_95_c32_n256,
    cat = ColorSchemes.Archambault,
    cv = _crossvalidation,
    sdm = _range,
)

using Luxor
function _coldot(cname, cval)
    if ~ispath("resources/colordots/")
        mkpath("resources/colordots")
    end
    Drawing(100, 100, "resources/colordots/$(cname).png")
    origin()
    sethue(cval)
    circle(Luxor.Point(0, 0), 50, action = :fill)
    finish()
end

_coldot("bkcol.generic", bkcol.generic)
_coldot("bkcol.sdm.present", bkcol.sdm.present)
_coldot("bkcol.sdm.absent", bkcol.sdm.absent)
_coldot("bkcol.nodata", bkcol.nodata)
_coldot("bkcol.sdm.loss", bkcol.sdm.loss)
_coldot("bkcol.sdm.nochange", bkcol.sdm.nochange)
_coldot("bkcol.sdm.gain", bkcol.sdm.gain)
_coldot("bkcol.cv.testing", bkcol.cv.testing)
_coldot("bkcol.cv.validation", bkcol.cv.validation)
_coldot("bkcol.cv.training", bkcol.cv.training)

function _colpal(cname, cval)
    if ~ispath("resources/colordots/")
        mkpath("resources/colordots")
    end
    Drawing(400, 50, "resources/colordots/$(cname).png")
    origin()
    for (i,c) in enumerate(cval)
        sethue(c)
        p = (i-1)/(length(cval)-1)*350 - 175
        circle(Luxor.Point(p, 0), 25, action = :fill)
    end
    finish()
end

_colpal("bkcol.div", bkcol.div)
_colpal("bkcol.seq", bkcol.seq)
_colpal("bkcol.cat", bkcol.cat)