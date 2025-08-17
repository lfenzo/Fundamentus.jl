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
