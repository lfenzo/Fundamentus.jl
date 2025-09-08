const fii_methods = Function[
    fii_administrador,
    fii_fatos_relevantes,
    fii_relatorios,
    fii_imoveis,
    fii_proventos,
]

const fii = "HGLG11"

@testset "fiis" begin
    _test_ticker_against_methods(ticker = fii, methods = fii_methods)
end
