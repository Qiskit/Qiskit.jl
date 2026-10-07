# Report whether Project.toml's [compat] entry for Qiskit_jll admits a given
# Qiskit_jll version.
#
# Usage: julia check_jll_compat.jl <Project.toml> <version>
#
# The version to pass is the one the workflow is about to build -- that is, the
# Qiskit release under test with any pre-release suffix dropped -- not whatever
# happens to be published in the registry.  The point of the check is to notice
# when the declared bound would exclude the release we are testing against.
import Pkg
import TOML

if length(ARGS) != 2
    println(stderr, "usage: julia check_jll_compat.jl <Project.toml> <version>")
    exit(2)
end

project_file, version_string = ARGS

# JLL versions carry a `+N` build suffix that compat bounds do not constrain,
# so compare on major.minor.patch alone.
parsed = VersionNumber(version_string)
under_test = VersionNumber(parsed.major, parsed.minor, parsed.patch)

project = TOML.parsefile(project_file)
compat = get(get(project, "compat", Dict{String,Any}()), "Qiskit_jll", nothing)

if compat === nothing
    println("admits=true")
    println("under_test=", under_test)
    println("reason=no [compat] entry for Qiskit_jll, so any version is allowed")
    exit(0)
end

admits = under_test in Pkg.Versions.semver_spec(compat)

println("admits=", admits)
println("compat=", compat)
println("under_test=", under_test)
println(
    "reason=compat \"",
    compat,
    "\" ",
    admits ? "admits" : "excludes",
    " ",
    under_test,
    ", the version under test",
)
