# Report whether a given Qiskit_jll version is published in the registries.
import Pkg

const QISKIT_JLL_UUID = Base.UUID("b54e8e98-f244-53b3-a8e8-4727a4907f76")

wanted = VersionNumber(ARGS[1])

found = VersionNumber[]
for reg in Pkg.Registry.reachable_registries()
    entry = get(reg.pkgs, QISKIT_JLL_UUID, nothing)
    entry === nothing && continue
    info = try
        Pkg.Registry.registry_info(reg, entry)
    catch err
        err isa MethodError || rethrow()
        Pkg.Registry.registry_info(entry)
    end
    append!(found, keys(info.version_info))
end

# JLL versions carry a `+N` build suffix; compare on major.minor.patch.
bare(v) = VersionNumber(v.major, v.minor, v.patch)
published = any(v -> bare(v) == wanted, found)

println("published=", published)
println("wanted=", wanted)
if !isempty(found)
    println("latest=", maximum(found))
end
