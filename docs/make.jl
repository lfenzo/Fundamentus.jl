using Documenter
using Fundamentus

makedocs(
    warnonly = true,
    sitename = "Fundamentus.jl",
    modules = [Fundamentus],
    pages = [
        "Introduction" => "index.md",
        "API Reference" => "api_reference.md"
    ]
)

deploydocs(
    repo = "github.com/lfenzo/Fundamentus.jl.git",
)
