using Cascadia
using Dates
using DataFrames
using HTTP
using Gumbo
using StringEncodings


function ativos()
    headers = ["User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36"]
    url = "https://www.fundamentus.com.br/detalhes.php"
    html = get_html_from_url(url=url, encoding="ISO-8859-1")# |> parsehtml
    parsed = html |> parsehtml
    tables = eachmatch(Selector("h1"), parsed.root)
    #println(html[1:20_000])
    println(length(tables))
    open("file.html", "w") do file
        write(file, html)
    end
end


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


function fii_imoveis()
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
function fii_imoveis(tickers::Vector{<:AbstractString}) where {T <: AbstractString}
    return filter(r -> r["fii"] in tickers, fii_imoveis())
end
function fii_imoveis(ticker::T) where {T <: AbstractString}
    return fii_imoveis([ticker])
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
    rows = eachmatch(Selector("table#resultado tbody tr"), parsed.root)
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
