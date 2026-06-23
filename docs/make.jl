using Qiskit
using Documenter

DocMeta.setdocmeta!(Qiskit, :DocTestSetup, :(using Qiskit); recursive=true)

makedocs(;
    modules=[Qiskit, Qiskit.Operations],
    authors="IBM and its contributors",
    sitename="Qiskit.jl",
    format=Documenter.HTML(;
        canonical="https://qiskit.github.io/Qiskit.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Qiskit/Qiskit.jl",
    devbranch="main",
)
