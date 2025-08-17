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


function fiis_imoveis()
    url = "https://www.fundamentus.com.br/fii_imoveis.php"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)

    data = []

    for row in rows
        tds = eachmatch(Selector("td"), row)
        values = string.([text(td) for td in tds])
        push!(
            data,
            Dict(
                "fii" => values[1],
                "imovel" => values[2],
                "endereco" => values[3],
                "caracteristicas" => values[4],
            )
        )
    end
    return DataFrame(data)
end
function fiis_imoveis(tickers::Vector{<:AbstractString}) where {T <: AbstractString}
    return filter(r -> r["fii"] in tickers, fiis_imoveis())
end
function fiis_imoveis(ticker::T) where {T <: AbstractString}
    return fiis_imoveis([ticker])
end


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
                "area" => values[3],
                "n_unidades" => values[4],
                "caracteristicas" => values[5],
                "tx_ocupacao" => values[6],
                "%_inadimplencia" => values[7],
                "%_receita" => values[8],
            )
        )
    end
    return DataFrame(data)
end


function fii_relatorios(ticker::AbstractString)# :: DataFrame where {T <: AbstractString}
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


function fii_administrador(ticker::T) :: DataFrame where {T <: AbstractString}
    url = "https://www.fundamentus.com.br/fii_administrador.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    root = parsed.root

    email_hash = first(eachmatch(Selector("a.__cf_email__"), root)).attributes["data-cfemail"]
    labels = eachmatch(Selector(".w728 .w3"), root) .|> text
    values = eachmatch(Selector(".w728 .data"), root) .|> text

    df = DataFrame(Dict(zip(labels, values)))
    setindex!(df, decode_cfemail(email_hash), 1, "E-mail")
    return df
end
function fii_administrador(tickers::Vector{<:AbstractString}) :: DataFrame
    tasks = [@async administrador(ticker) for ticker in tickers]
    dfs = fetch.(tasks)
    return vcat(dfs...)
end


function fii_proventos(ticker::T) :: DataFrame where {T <: AbstractString}
    url = "https://www.fundamentus.com.br/fii_proventos.php?papel=$ticker&tipo=2"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("tbody tr"), parsed.root)
    data = []

    for row in rows
        values = string.([text(td) for td in eachmatch(Selector("td"), row)])
        push!(
            data,
            Dict(
                "data-com" => Date(values[1], dateformat"dd/mm/yyyy"),
                "tipo" => values[2],
                "data-pag" => Date(values[3], dateformat"dd/mm/yyyy"),
                "valor" => sanitize_float(values[4]),
            )
        )
    end
    return DataFrame(data)
end
