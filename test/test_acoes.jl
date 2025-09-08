const fii_methods = Function[
    acao_proventos,
    acao_apresentacoes,
    acao_recompras,
    acao_resultados,
]

const acao = "ITUB4"

@testset "acoes" begin
    _test_ticker_against_methods(ticker = acao, methods = fii_methods)
end
