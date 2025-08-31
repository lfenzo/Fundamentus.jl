module Fundamentus

using Cascadia
using Dates
using DataFrames
using HTTP
using Gumbo
using StringEncodings

include("./utils.jl")
include("./scrapers/acoes.jl")
include("./scrapers/fiis.jl")
include("./scrapers/misc.jl")

export fii_administrador
export fii_fatos_relevantes
export fii_relatorios
export fii_imoveis
export fii_proventos
export fii_detalhes
export fiis

export acao_proventos
export acao_apresentacoes
export acao_recompras
export acao_resultados
export acao_detalhes
export acoes

CACHE = Dict()

end
