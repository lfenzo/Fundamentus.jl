function acao_proventos(ticker::T) :: DataFrame where {T <: AbstractString}
    url = "https://www.fundamentus.com.br/proventos.php?papel=$ticker"
    parsed = get_html_from_url(url=url, encoding="ISO-8859-1") |> parsehtml
    rows = eachmatch(Selector("table#resultado tbody tr"), parsed.root)

    data = []

    for row in rows
        values = string.([text(td) for td in eachmatch(Selector("td"), row)])
        push!(
            data,
            Dict(
                "data-com" => Date(values[1], dateformat"dd/mm/yyyy"),
                "valor" => values[2] |> sanitize_float,
                "tipo" => values[3],
                "data-pag" => values[4] != "-" ? Date(values[4], dateformat"dd/mm/yyyy") : missing,
            )
        )
    end
    return DataFrame(data)
end


function acao_apresentacoes(ticker::T) where {T <: AbstractString}
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
                "data" => DateTime(replace(values[1], r"\s+" => " "), dateformat"dd/mm/yyyy HH:MM"),
                "descricao" => values[2],
                "download_link" => first(eachmatch(Selector("a"), tds[end])).attributes["href"],
            )
        )
    end
    return DataFrame(data)
end


function acao_recompras(ticker::T) where {T <: AbstractString}
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
                "data" => Date(replace(values[1], r"\s+" => " "), dateformat"dd/mm/yyyy"),
                "quantidade" => sanitize_float(values[2]),
                "valor" => sanitize_float(values[3]),
                "preco_medio" => values[4],
                "%_do_capital" => values[5],
                "download_link" => first(eachmatch(Selector("a"), tds[6])).attributes["href"],
            )
        )
    end
    return DataFrame(data)
end
