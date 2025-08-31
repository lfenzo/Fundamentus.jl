"""
    acao_resultados(ticker::AbstractString) :: DataFrame

Fetches the quarterly results of a stock from the **Fundamentus** website.

# Arguments
- `ticker::AbstractString`: The stock trading code (e.g., `"PETR4"`, `"VALE3"`).

# Returns
`DataFrame` with the quarterly results of the stock, containing:
- `data::Date`: Reference date of the quarterly result.
- `url_demonstracao::Union{String, Missing}`: Link to the financial statement, if available.
- `url_release::Union{String, Missing}`: Link to the results press release, if available.
"""
function acao_resultados(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/resultados_trimestrais.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "data" => _parse_date((values[1])),
                "url_demonstracao" => _extract_link_from_attributes(tds[2]),
                "url_release" => _extract_link_from_attributes(tds[3]),
            )
        )
    end
    return DataFrame(data)
end


"""
    acao_proventos(ticker::AbstractString) :: DataFrame

Retrieve the dividends and distributions paid by a Brazilian stock (ação) with the given ticker.

# Parameters
- `ticker::AbstractString` : The stock ticker symbol, e.g., `"PETR4"`.

# Returns
`DataFrame` with the following columns:
- `data_com` (`Date`): Ex-dividend date (the date when the right to receive the dividend is determined).
- `valor` (`Float64`): Amount paid per share.
- `tipo` (`String`): Type of distribution (e.g., "Dividend", "Interest on Capital").
- `data_pag` (`Union{Date, Missing}`): Payment date when the dividend is actually credited. `missing` if not available.

# Example

```@repl
julia> acao_proventos("PETR4")
115×4 DataFrame
 Row │ data_com    valor    tipo             data_pag   
     │ Date        Float64  String           Date?      
─────┼──────────────────────────────────────────────────
   1 │ 2025-06-02   0.4546  JRS CAP PROPRIO  2025-08-20
   2 │ 2025-06-02   0.3084  DIVIDENDO        2025-09-22
   3 │ 2025-06-02   0.1461  JRS CAP PROPRIO  2025-09-22
   4 │ 2025-04-16   0.3548  DIVIDENDO        2025-06-20
   5 │ 2025-04-16   0.3548  DIVIDENDO        2025-05-20
...
```

See also [`fii_proventos()`](@ref).
"""
function acao_proventos(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/proventos.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("table#resultado tbody tr"), parsed.root)

    data = []

    for row in rows
        values = string.([text(td) for td in eachmatch(Selector("td"), row)])
        push!(
            data,
            Dict(
                "data-com" => _parse_date(values[1]),
                "valor" => sanitize_int(values[2]),
                "tipo" => values[3],
                "data-pag" => values[4] != "-" ? _parse_date((values[4])) : missing,
            )
        )
    end
    return DataFrame(data)
end


"""
    acao_apresentacoes(ticker::AbstractString) :: DataFrame

Retrieve the investor presentations disclosed by a Brazilian stock (ação) with the given ticker.

# Parameters
- `ticker::AbstractString` : The stock ticker symbol, e.g., `"PETR4"`.

# Returns
`DataFrame` with the following columns:
- `data` (`DateTime`): Date and time when the presentation was published.
- `descr` (`String`): Description or title of the presentation.
- `download_link` (`String`): URL to download the presentation file.

# Example
```@repl
julia> acao_apresentacoes("PETR4")
115×3 DataFrame
 Row │ download_link                      data                 descr                             
     │ String                             DateTime             String                            
─────┼───────────────────────────────────────────────────────────────────────────────────────────
   1 │ https://www.rad.cvm.gov.br/ENET/…  2025-08-07T21:47:00  Desempenho Petrobras 2T25
   2 │ https://www.rad.cvm.gov.br/ENET/…  2025-05-13T06:03:00  Desempenho Petrobras 1T25
   3 │ https://www.rad.cvm.gov.br/ENET/…  2025-05-06T16:22:00  Carteira de Investimentos e Opor…
   4 │ https://www.rad.cvm.gov.br/ENET/…  2025-02-26T20:32:00  Desempenho Petrobras em 2024
   5 │ https://www.rad.cvm.gov.br/ENET/…  2024-11-22T19:24:00  Plano Estratégico 2050 - Plano d…
...
```

See also [`fii_fatos_relevantes()`](@ref)
"""
function acao_apresentacoes(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/apresentacoes.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "data" => _parse_date_time(values[1]),
                "descr" => values[2],
                "download_link" => _extract_link_from_attributes(tds[end]),
            )
        )
    end
    return DataFrame(data)
end


"""
    acao_recompras(ticker::AbstractString) :: DataFrame

Retrieve the share buyback events for a Brazilian stock (ação) with the given ticker.

# Parameters
- `ticker::AbstractString` : The stock ticker symbol, e.g., `"PETR4"`.

# Returns
`DataFrame` with the following columns:
- `data` (`Date`): Date when the buyback operation occurred.
- `quantidade` (`Float64`): Number of shares repurchased.
- `valor` (`Float64`): Total value of the buyback operation.
- `preco_medio` (`String`): Average price per share for the buyback.
- `%_do_capital` (`String`): Percentage of the company's capital represented by the buyback.
- `download_link` (`String`): URL to the official document or report regarding the buyback.

# Example
```@repl
julia> acao_recompras("PETR4")
37×6 DataFrame
 Row │ download_link                      valor      %_do_capital  data        quantidade      preco_medio 
     │ String                             Float64    String?       Date        Float64         String      
─────┼─────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ https://www.rad.cvm.gov.br/ENET/…  0.0        missing       2024-09-01       0.0        0,00
   2 │ https://www.rad.cvm.gov.br/ENET/…  0.0        missing       2024-08-01       0.0        0,00
   3 │ https://www.rad.cvm.gov.br/ENET/…  0.0        missing       2024-07-01       0.0        0,00
   4 │ https://www.rad.cvm.gov.br/ENET/…  2.72934e8        0.0005  2024-06-01       7.1594e6   38,12
   5 │ https://www.rad.cvm.gov.br/ENET/…  4.84823e8        0.001   2024-05-01       1.30125e7  37,26
...
```
"""
function acao_recompras(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/recompras.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "data" => _parse_date(values[1]),
                "quantidade" => sanitize_float(values[2]),
                "valor" => sanitize_float(values[3]),
                "preco_medio" => values[4],
                "%_do_capital" => values[5] != "-" ? sanitize_float(values[5]; as_percentage = true) : missing,
                "download_link" => _extract_link_from_attributes(tds[6]),
            )
        )
    end
    return DataFrame(data)
end
