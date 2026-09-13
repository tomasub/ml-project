
#import "./lib.typ": *
#let unit(it) = $thick upright(it)$ 

//COMMA FOR DECIMALS?
#let comma = false

#show math.equation: it => {
    show regex("\d+\.\d+"): it => if comma {
      {show ".": {(","+h(0pt))}
        it}} else {
            {show ".": {("."+h(0pt))}
        it}
        }
    it
}

#set bibliography(
    style: "ieee",
    title: "Lähdeluettelo"
  )

#show bibliography: set heading(numbering: "1.")

//SET OTHER PARAMS
#show: it => lab-report(
  doc-context: "insert course here",
  doc-title: "Modelling crop yields based on early season weather, soil, and growth data",
  author: "Tomas D'Incau, Alvari Salonen",
  affiliation: "Aalto University",
  logo: image("assets/logo-question.png", width: 4cm),
  language: "en",
  compact-mode: false,
  it
)


#pagebreak(weak: true)

//#bibliography()

