using Clang.Generators

using Qiskit_jll

cd(@__DIR__)

include_dir = normpath(Qiskit_jll.artifact_dir, "include")
qiskit_dir = joinpath(include_dir, "qiskit")

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags, e.g. "-DXXXXXXXXX"
args = get_default_args()
push!(args, "-I$include_dir")
# XXX: this is a hack but necessary in order to avoid an error about the QkGate
# enum being defined as two different things.
push!(args, "-D__cplusplus")

headers = [joinpath(include_dir, "qiskit.h")]
for header in readdir(qiskit_dir)
    if endswith(header, ".h")
        push!(headers, joinpath(qiskit_dir, header))
    end
end
# there is also an experimental `detect_headers` function for auto-detecting top-level headers in the directory
# headers = detect_headers(qiskit_dir, args)

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
