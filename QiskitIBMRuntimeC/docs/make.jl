using QiskitIBMRuntimeC
using Documenter

DocMeta.setdocmeta!(QiskitIBMRuntimeC, :DocTestSetup, :(using QiskitIBMRuntimeC); recursive=true)

makedocs(;
    modules=[QiskitIBMRuntimeC],
    authors="IBM and its contributors",
    sitename="QiskitIBMRuntimeC.jl",
    format=Documenter.HTML(;
        canonical="https://qiskit.github.io/QiskitIBMRuntimeC.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Qiskit/QiskitIBMRuntimeC.jl",
    devbranch="main",
)
