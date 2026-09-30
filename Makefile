.PHONY: format
format:
	julia --project=format -e 'using Pkg; Pkg.instantiate()'
	julia --project=format format/run.jl
