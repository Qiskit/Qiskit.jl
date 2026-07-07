JULIA ?= julia

.PHONY: help format format-check test gen

help:
	@echo "Targets:"
	@echo "  format        Format the repo with the pinned JuliaFormatter (format/ env)"
	@echo "  format-check  Check formatting without modifying files (exits non-zero if unformatted)"
	@echo "  test          Run the test suite"
	@echo "  gen           Regenerate lib/LibQiskit.jl from the Qiskit C headers (gen/ env)"

format:
	$(JULIA) --project=format -e 'import Pkg; Pkg.instantiate(); using JuliaFormatter; format(".")'

format-check:
	$(JULIA) --project=format -e 'import Pkg; Pkg.instantiate(); using JuliaFormatter; format(".") || (@error "Some files are not formatted; run \`make format\`"; exit(1))'

test:
	$(JULIA) --project=. -e 'import Pkg; Pkg.test()'

gen:
	$(JULIA) --project=gen -e 'import Pkg; Pkg.instantiate()'
	$(JULIA) --project=gen gen/generator.jl
