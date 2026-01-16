using QiskitIBMRuntimeC
using Qiskit
using Test
using Aqua

function generate_bell_circuit()
    qc = QuantumCircuit(2, 2) # 2 qubits, 2 clbits
    qc.h(1)
    qc.cx(1, 2)
    qc.measure(1, 1)
    qc.measure(2, 2)
    qc
end

@testset "QiskitIBMRuntimeC.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(QiskitIBMRuntimeC)
    end

    # Skip the tests that require a service by default
    if get(ENV, "TEST_QKRT_SERVICE", "0") == "0"
        @info "Skipping the service tests.  To run them, set the environment variable TEST_QKRT_SERVICE=1"
    else
        @info "Running the service tests, since the environment variable TEST_QKRT_SERVICE is nonzero."
        service = Service()
        @testset "Actual service" begin
            search = backend_search(service)
            backend = least_busy(search)
            @show backend.name
            target = target_from_backend(backend, service)

            qc = generate_bell_circuit()

            transpiled_circuit, layout = transpile(qc, target)
            @show transpiled_circuit.num_instructions

            shots = 1024
            job = run_sampler_job(service, backend, transpiled_circuit, shots)
            samples = get_job_results(job, service)
            @show samples
        end
    end
end
