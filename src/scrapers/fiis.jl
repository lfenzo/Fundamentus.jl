"""
    fii_fatos_relevantes(ticker::AbstractString) :: DataFrame

Retrieve the material facts (“fatos relevantes”) disclosed by a Brazilian FII
(Real Estate Investment Fund) with the given ticker.

# Parameters
- `ticker::AbstractString` : The FII ticker symbol, e.g., `"HGLG11"`.

# Returns
`DataFrame` with the following columns:
- `data` (`DateTime`): Date and time when the disclosure was published.
- `tipo` (`String`): Type of disclosure or communication.
- `download_link` (`String`): URL to download the official disclosure document.

# Example
```@repl
julia> fii_fatos_relevantes("HGLG11")
100×3 DataFrame
 Row │ download_link                      tipo            data                
     │ String                             String          DateTime            
─────┼────────────────────────────────────────────────────────────────────────
   1 │ https://fnet.bmfbovespa.com.br/f…  Fato Relevante  2025-06-17T18:17:00
   2 │ https://fnet.bmfbovespa.com.br/f…  Fato Relevante  2025-03-20T18:13:00
   3 │ https://fnet.bmfbovespa.com.br/f…  Fato Relevante  2024-12-23T19:19:00
   4 │ https://fnet.bmfbovespa.com.br/f…  Fato Relevante  2024-12-12T18:05:00
   5 │ https://fnet.bmfbovespa.com.br/f…  Fato Relevante  2024-10-29T18:05:00
...
```

See also [`acao_apresentacoes()`](@ref).
"""
function fii_fatos_relevantes(ticker::T) where {T <: AbstractString}
    url = "https://www.fundamentus.com.br/fii_fatos_relevantes.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("table#comunicados tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "data" => DateTime(replace(values[1], r"\s+" => " "), dateformat"dd/mm/yyyy HH:MM"),
                "tipo" => values[2],
                "download_link" => first(eachmatch(Selector("a"), tds[end])).attributes["href"],
            )
        )
    end
    return DataFrame(data)
end


"""
    fii_imoveis(ticker::AbstractString) :: DataFrame

Retrieve detailed information about the real estate properties held by a Brazilian FII (Real Estate Investment Fund) with the given ticker.

# Parameters
- `ticker::AbstractString` : The FII ticker symbol, e.g., `"HGLG11"`.

# Returns
`DataFrame` with the following columns:
- `imovel` (`String`): Name or identification of the property.
- `endereco` (`String`): Address of the property.
- `area` (`Int`): Total area of the property (as reported).
- `n_unidades` (`Int`): Number of units in the property.
- `caracteristicas` (`String`): Main characteristics of the property.
- `%_ocupacao` (`String`): Occupancy rate of the property.
- `%_inadimplencia` (`String`): Default rate associated with the property.
- `%_receita` (`String`): Percentage of the fund’s revenue attributed to the property.

# Example
```@repl
using Fundamentus # hide
df = fii_imoveis("HGLG11")
first(df, 5)
```

```@example
import Random # hide
Random.seed!(1) # hide
A = rand(3, 3)
b = [1, 2, 3]
A
```

"""
function fii_imoveis(ticker::T) where {T <: AbstractString}
    url = "https://www.fundamentus.com.br/fii_imoveis_detalhes.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "imovel" => values[1],
                "endereco" => values[2],
                "area" => sanitize_int(values[3]),
                "n_unidades" => sanitize_int(values[4]),
                "caracteristicas" => values[5],
                "%_ocupacao" => sanitize_float(values[6]; as_percentage = true),
                "%_inadimplencia" => sanitize_float(values[7]; as_percentage = true),
                "%_receita" => sanitize_float(values[8]; as_percentage = true),
            )
        )
    end
    return DataFrame(data)
end


"""
    fii_relatorios(ticker::AbstractString) :: DataFrame

Retrieve the monthly reports published by a Brazilian FII (Real Estate Investment Fund) with the given ticker.

# Parameters
- `ticker::AbstractString` : The FII ticker symbol, e.g., `"HGLG11"`.

# Returns
`DataFrame` with the following columns:
- `data` (`Date`): Reference date of the report (month/year).
- `download_link` (`String`): URL to download the report file.

# Example
```@repl
julia> fii_relatorios("HGLG11")
111×2 DataFrame
 Row │ download_link                      data       
     │ String                             Date       
─────┼───────────────────────────────────────────────
   1 │ https://fnet.bmfbovespa.com.br/f…  2025-07-01
   2 │ https://fnet.bmfbovespa.com.br/f…  2025-06-01
   3 │ https://fnet.bmfbovespa.com.br/f…  2025-05-01
   4 │ https://fnet.bmfbovespa.com.br/f…  2025-04-01
   5 │ https://fnet.bmfbovespa.com.br/f…  2025-03-01
...
```
"""
function fii_relatorios(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/fii_relatorios.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "data" => Date(replace(values[1], r"\s+" => " "), dateformat"mm/yyyy"),
                "download_link" => first(eachmatch(Selector("a"), tds[2])).attributes["href"],
            )
        )
    end
    return DataFrame(data)
end


"""
    fii_administrador(ticker::AbstractString) :: DataFrame
    fii_administrador(tickers::Vector{<:AbstractString}) :: DataFrame

Retrieve information about the administrator of a Brazilian FII (Real Estate Investment Fund) for the given ticker.

# Parameters
- `ticker::AbstractString` : The FII ticker symbol, e.g., `"HGLG11"`.  
- `tickers::Vector{<:AbstractString}` : A vector of FII tickers for batch retrieval.

# Returns
`DataFrame` with the following columns:
- `ticker` (`String`): The FII ticker symbol.
- `cnpj_fundo` (`String`): CNPJ of the FII itself.
- `cnpj_admin` (`String`): CNPJ (tax ID) of the fund administrator.
- `email` (`String`): Email address of the fund administrator (decoded from obfuscated form on the site).
- `nome_admin` (`String`): Name of the administrator.
- `site_admin` (`String`): Website of the administrator.
- `telefone_admin` (`String`): Phone number of the administrator.
- `tx_admin_pl` (`Float64`): Administration fee as a percentage of the fund’s net asset value (PL).
- `tx_admin_valor_mercado` (`Float64`): Administration fee as a percentage of the fund’s market value.

This function also supports passing a vector of tickers for parallel retrieval, returning a combined DataFrame for all tickers.
"""
function fii_administrador(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/fii_administrador.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    root = parsed.root

    email_hash = first(eachmatch(Selector("a.__cf_email__"), root)).attributes["data-cfemail"]
    labels = eachmatch(Selector(".w728 .w3"), root) .|> text
    values = eachmatch(Selector(".w728 .data"), root) .|> text

    df = DataFrame(Dict(zip(labels, values)))

    rename!(df,
        "CNPJ do Administrador" => "cnpj_admin",
        "CNPJ do Fundo" => "cnpj_fundo",
        "E-mail" => "email",
        "Nome" => "nome_admin",
        "Site" => "site_admin",
        "Telefone" => "telefone_admin",
        "Tx administração sobre o PL" => "tx_admin_pl",
        "Tx administração sobre o Valor de Mercado" => "tx_admin_valor_mercado",
    )

    df.ticker .= ticker
    df.email .= decode_cfemail(email_hash)
    df.tx_admin_pl = sanitize_float.(df.tx_admin_pl)
    df.tx_admin_valor_mercado = sanitize_float.(df.tx_admin_valor_mercado)

    return df
end
function fii_administrador(tickers::Vector{<:AbstractString}) :: DataFrame
    tasks = [@async fii_administrador(ticker) for ticker in tickers]
    dfs = fetch.(tasks)
    return vcat(dfs...)
end


"""
    fii_proventos(ticker::AbstractString) :: DataFrame

Retrieve the dividends and distributions paid by a Brazilian FII with the given `ticker`.

# Parameters
- `ticker <: AbstractString`: FII ticker symbol, e.g., "HGLG11".

# Returns
`DataFrame` with the following columns:
- `data_com` (`Date`): Ex-dividend date (the date when the right to receive the dividend is determined).
- `tipo` (`String`): Type of distribution.
- `valor` (`Float64`): Amount paid per unit/share.
- `data_pag` (`Date`): Payment date when the dividend is actually credited.

# Example

```@repl
julia> fii_proventos("HGLG11")
101×4 DataFrame
 Row │ data_com    tipo        valor    data_pag
     │ Date        String      Float64  Date       
─────┼─────────────────────────────────────────────
   1 │ 2025-07-31  Rendimento     1.1   2025-08-14
   2 │ 2025-06-30  Rendimento     1.1   2025-07-14
   3 │ 2025-05-30  Rendimento     1.1   2025-06-13
   4 │ 2025-04-30  Rendimento     1.1   2025-05-15
   5 │ 2025-03-31  Rendimento     1.1   2025-04-14
...
```

See also [`acao_proventos()`](@ref).
"""
function fii_proventos(ticker::AbstractString) :: DataFrame
    url = "https://www.fundamentus.com.br/fii_proventos.php?papel=$ticker&tipo=2"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)
    data = []

    for row in rows
        values = string.([text(td) for td in eachmatch(Selector("td"), row)])
        push!(
            data,
            Dict(
                "data_com" => Date(values[1], dateformat"dd/mm/yyyy"),
                "tipo" => values[2],
                "data_pag" => Date(values[3], dateformat"dd/mm/yyyy"),
                "valor" => sanitize_float(values[4]),
            )
        )
    end
    return DataFrame(data)
end
