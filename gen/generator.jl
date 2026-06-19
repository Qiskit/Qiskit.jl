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
# enum being defined as two different things.  See upstream PR at
# https://github.com/mozilla/cbindgen/pull/1156
push!(args, "-D__cplusplus")

headers = [joinpath(include_dir, "qiskit.h")]
# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
