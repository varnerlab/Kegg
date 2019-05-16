## Kegg.jl: A Julia interface to the Kyoto Encyclopedia of Genes and Genomes (KEGG)
The [Kyoto Encyclopedia of Genes and Genomes (KEGG)](https://www.kegg.jp/kegg/kegg1.html)
provides a [REST-style Application Programming Interface (API)](https://www.kegg.jp/kegg/rest/keggapi.html)
for custom queries against the KEGG database. This package provides a [Julia](https://julialang.org) interface to the
KEGG-API.

### Installation and requirements
``Kegg.jl`` can be installed in the ``package mode`` of Julia.

Start of the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html) and enter the ``package mode`` using the ``]`` key (to get back press the ``backspace`` or ``^C`` keys). Then, at the prompt enter:

    (v1.1) pkg> add https://github.com/varnerlab/Kegg.git

This will install the `Kegg.jl` package and other all required packages.
``Kegg.jl`` requires Julia 1.x and above.


### Funding
The work described was supported by the [Center on the Physics of Cancer Metabolism at Cornell University](https://psoc.engineering.cornell.edu) through Award Number 1U54CA210184-01 from the [National Cancer Institute](https://www.cancer.gov). The content is solely the responsibility of the authors and does not necessarily
represent the official views of the [National Cancer Institute](https://www.cancer.gov) or the [National Institutes of Health](https://www.nih.gov).
