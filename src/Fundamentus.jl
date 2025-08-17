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

export ativos

export fii_administrador
export fii_fatos_relevantes
export fii_relatorios
export fii_imoveis
export fii_proventos
export fii_detalhes
export fiis_imoveis

export acao_proventos
export acao_apresentacoes
export acao_recompras

CACHE = Dict()

end
