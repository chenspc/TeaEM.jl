using TeaEM
using Documenter

DocMeta.setdocmeta!(TeaEM, :DocTestSetup, :(using TeaEM); recursive=true)

makedocs(;
    modules=[TeaEM],
    authors="Chen Huang <chen1huang2@gmail.com> and contributors",
    repo="https://github.com/chenspc/TeaEM.jl/blob/{commit}{path}#{line}",
    sitename="TeaEM.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://chenspc.github.io/TeaEM.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/chenspc/TeaEM.jl",
)
