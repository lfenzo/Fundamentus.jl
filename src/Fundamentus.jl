module Fundamentus

include("./scrapers.jl")
include("./utils.jl")

export fii_administrador
export fii_fatos_relevantes
export fii_imoveis
export fii_proventos

export acao_proventos
export acao_apresentacoes

export ativos

CACHE = Dict()

end
