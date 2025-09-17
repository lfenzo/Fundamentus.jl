"""
    acoes() :: DataFrame

Fetch fundamental indicators for all stocks listed on the Fundamentus website.

# Returns
`DataFrame` where each row corresponds to a stock, with the following columns:
- `papel::String`: Trading code of the stock (ticker).
- `name::String`: Full company name.
- `cotacao::Union{Float64, Missing}`: Current price.
- `p_l::Union{Float64, Missing}`: Price-to-Earnings ratio.
- `p_vp::Union{Float64, Missing}`: Price-to-Book ratio.
- `psr::Union{Float64, Missing}`: Price-to-Sales ratio.
- `perc_div_yield::Union{Float64, Missing}`: Dividend Yield (%).
- `p_ativo::Union{Float64, Missing}`: Price-to-Assets ratio.
- `p_cap_giro::Union{Float64, Missing}`: Price-to-Working Capital ratio.
- `p_ebit::Union{Float64, Missing}`: Price-to-EBIT ratio.
- `p_ativ_circ_liq::Union{Float64, Missing}`: Price-to-Net Current Assets ratio.
- `ev_ebit::Union{Float64, Missing}`: Enterprise Value to EBIT ratio.
- `ev_ebitda::Union{Float64, Missing}`: Enterprise Value to EBITDA ratio.
- `marg_ebit::Union{Float64, Missing}`: EBIT margin (%).
- `marg_liq::Union{Float64, Missing}`: Net margin (%).
- `liq_corr::Union{Float64, Missing}`: Current ratio.
- `roic::Union{Float64, Missing}`: Return on Invested Capital (%).
- `roe::Union{Float64, Missing}`: Return on Equity (%).
- `liq_2meses::Union{Float64, Missing}`: Average trading volume in the last 2 months.
- `patrim_liq::Union{Float64, Missing}`: Shareholders' equity.
- `div_liq_patrim::Union{Float64, Missing}`: Net Debt to Equity ratio.
- `cresc_rec_5A::Union{Float64, Missing}`: Revenue growth in the last 5 years (%).
"""
function acoes()
    url = "https://www.fundamentus.com.br/resultado.php"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = NamedTuple[]

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            (
                papel = values[1],
                name = only(eachmatch(Selector("span"), row)).attributes["title"],
                cotacao = _sanitize_float(values[2]),
                p_l = _sanitize_float(values[3]),
                p_vp = _sanitize_float(values[4]),
                psr = _sanitize_float(values[5]),
                perc_div_yield = _sanitize_float(values[6], as_percentage = true),
                p_ativo = _sanitize_float(values[7]),
                p_cap_giro = _sanitize_float(values[8]),
                p_ebit = _sanitize_float(values[9]),
                p_ativ_circ_liq = _sanitize_float(values[10]),
                ev_ebit = _sanitize_float(values[11]),
                ev_ebitda = _sanitize_float(values[12]),
                marg_ebit = _sanitize_float(values[13]),
                marg_liq = _sanitize_float(values[14]),
                liq_corr = _sanitize_float(values[15]),
                roic = _sanitize_float(values[16]),
                roe = _sanitize_float(values[17]),
                liq_2meses = _sanitize_float(values[18]),
                patrim_liq = _sanitize_float(values[19]),
                div_liq_patrim = _sanitize_float(values[20]),
                cresc_rec_5A = _sanitize_float(values[21]),
            )
        )
    end
    return DataFrame(data)
end


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

    data = NamedTuple[]

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            (
                data = _parse_date(values[1]),
                url_demonstracao = _extract_link_from_attributes(tds[2]),
                url_release = _extract_link_from_attributes(tds[3]),
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

    data = NamedTuple[]

    for row in rows
        values = string.([text(td) for td in eachmatch(Selector("td"), row)])
        push!(
            data,
            (
                data_com = _parse_date(values[1]),
                valor = _sanitize_float(values[2]),
                tipo = values[3],
                data_pag = values[4] != "-" ? _parse_date((values[4])) : missing,
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

    data = NamedTuple[]

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            (
                data = _parse_date_time(values[1]),
                descr = values[2],
                download_link = _extract_link_from_attributes(tds[end]),
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
- `perc_do_capital` (`Float64`): Percentage of the company's capital represented by the buyback.
- `download_link` (`String`): URL to the official document or report regarding the buyback.

# Example
```@repl
julia> acao_recompras("PETR4")
38×6 DataFrame
 Row │ data        quantidade      valor      preco_medio  perc_do_capital  download_link                     
     │ Date        Float64         Float64    String       Float64?         String                            
─────┼────────────────────────────────────────────────────────────────────────────────────────────────────────
   1 │ 2025-08-01       0.0        0.0        0,00            missing       https://www.rad.cvm.gov.br/ENET/…
   2 │ 2025-07-01       0.0        0.0        0,00            missing       https://www.rad.cvm.gov.br/ENET/…
   3 │ 2025-06-01       0.0        0.0        0,00            missing       https://www.rad.cvm.gov.br/ENET/…
   4 │ 2025-05-01       0.0        0.0        0,00            missing       https://www.rad.cvm.gov.br/ENET/…
   5 │ 2025-04-01       0.0        0.0        0,00            missing       https://www.rad.cvm.gov.br/ENET/…
...
```
"""
function acao_recompras(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/recompras.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = NamedTuple[]

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            (
                data = _parse_date(values[1]),
                quantidade = _sanitize_float(values[2]),
                valor = _sanitize_float(values[3]),
                preco_medio = values[4],
                perc_do_capital = values[5] != "-" ? _sanitize_float(values[5]; as_percentage = true) : missing,
                download_link = _extract_link_from_attributes(tds[6]),
            )
        )
    end
    return DataFrame(data)
end
