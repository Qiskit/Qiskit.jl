using Clang.Generators

using Qiskit_jll
using qiskit_ibm_runtime_jll

cd(@__DIR__)

include_dir = normpath(qiskit_ibm_runtime_jll.artifact_dir, "include")
qkrt_dir = joinpath(include_dir, "qiskit_ibm_runtime")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "-I" * normpath(Qiskit_jll.artifact_dir, "include"))
# XXX: this is a hack but necessary in order to avoid an error about the QkGate
# enum being defined as two different things.
push!(args, "-D__cplusplus")

headers = [joinpath(qkrt_dir, header) for header in readdir(qkrt_dir) if endswith(header, ".h")]
# there is also an experimental `detect_headers` function for auto-detecting top-level headers in the directory
# headers = detect_headers(qkrt_dir, args)

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
