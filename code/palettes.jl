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
    seq = _sequential,
    div = _diverging,
    cat = _categorical,
    cv = _crossvalidation,
    sdm = _range,
)