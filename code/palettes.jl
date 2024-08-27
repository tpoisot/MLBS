# Sequential
_sequential = [
    colorant"#FEFBE9",
    colorant"#FCF7D5",
    colorant"#F5F3C1",
    colorant"#EAF0B5",
    colorant"#DDECBF",
    colorant"#D0E7CA",
    colorant"#C2E3D2",
    colorant"#B5DDD8",
    colorant"#A8D8DC",
    colorant"#9BD2E1",
    colorant"#8DCBE4",
    colorant"#81C4E7",
    colorant"#7BBCE7",
    colorant"#7EB2E4",
    colorant"#88A5DD",
    colorant"#9398D2",
    colorant"#9B8AC4",
    colorant"#9D7DB2",
    colorant"#9A709E",
    colorant"#906388",
    colorant"#805770",
    colorant"#684957",
    colorant"#46353A",
]

_diverging = [
    colorant"#125A56",
    colorant"#00767B",
    colorant"#238F9D",
    colorant"#42A7C6",
    colorant"#60BCE9",
    colorant"#9DCCEF",
    colorant"#C6DBED",
    colorant"#DEE6E7",
    colorant"#ECEADA",
    colorant"#F0E6B2",
    colorant"#F9D576",
    colorant"#FFB954",
    colorant"#FD9A44",
    colorant"#F57634",
    colorant"#E94C1F",
    colorant"#D11807",
    colorant"#A01813",
]

# Categorical
_categorical = [
    colorant"#4477AA",
    colorant"#EE6677",
    colorant"#228833",
    colorant"#CCBB44",
    colorant"#66CCEE",
    colorant"#AA3377",
]

_crossvalidation = (
    training = colorant"#BBBBBB",
    testing = colorant"#CC6677",
    validation = colorant"#117733"
)

_range = (
    absent = colorant"#77AADD",
    absentbg = colorant"#77AADD44",
    present = colorant"#EE8866",
    presentbg = colorant"#EE886644",
    gain = _diverging[11],
    nochange = _diverging[9],
    loss = _diverging[7],
)

# Semantic colors for the book
bkcol = (
    nodata = colorant"#DDDDDD",
    generic = colorant"#224433",
    seq = _sequential,
    div = _diverging,
    cat = _categorical,
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
    Drawing(600, 100, "resources/colordots/$(cname).png")
    origin()
    for (i,c) in enumerate(cval)
        sethue(c)
        p = (i-1)/(length(cval)-1)*500 - 250
        circle(Luxor.Point(p, 0), 50, action = :fill)
    end
    finish()
end

_colpal("bkcol.div", bkcol.div)
_colpal("bkcol.seq", bkcol.seq)
_colpal("bkcol.cat", bkcol.cat)