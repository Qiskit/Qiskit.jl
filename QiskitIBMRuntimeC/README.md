# QiskitIBMRuntimeC

Julia wrapper of [qiskit-ibm-runtime-c](https://github.com/Qiskit/qiskit-ibm-runtime-c)

### Example

```julia
using Qiskit
using QiskitIBMRuntimeC

function generate_bell_circuit()
    qc = QuantumCircuit(2, 2) # 2 qubits, 2 clbits
    qc.h(1)
    qc.cx(1, 2)
    qc.measure(1, 1)
    qc.measure(2, 2)
    qc
end

service = Service()
search_results = backend_search(service)
backend = least_busy(search_results)
@show backend.name
target = target_from_backend(backend, service)

qc = generate_bell_circuit()

transpiled_circuit, layout = transpile(qc, target)
@show transpiled_circuit.num_instructions

shots = 1024
job = run_sampler_job(service, backend, transpiled_circuit, shots)
samples = get_job_results(job, service)
@show samples
```
