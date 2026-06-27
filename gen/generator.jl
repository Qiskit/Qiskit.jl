using Clang.Generators
import Clang.Generators: collect_top_level_nodes!
import Clang: CLLinkageSpec, children

using Qiskit_jll

cd(@__DIR__)

include_dir = normpath(Qiskit_jll.artifact_dir, "include")
qiskit_dir = joinpath(include_dir, "qiskit")

# Clang.jl cannot handle `extern "C"` blocks (CLLinkageSpec cursors), but the
# cbindgen-generated headers activate these with -D__cplusplus, which is needed
# to avoid the C idiom "typedef uint8_t EnumName" conflicting with "enum EnumName".
# Descend into linkage-spec children so declarations inside extern "C" are found.
function collect_top_level_nodes!(nodes::Vector{Generators.ExprNode}, cursor::CLLinkageSpec, options::Dict)
    for child in children(cursor)
        collect_top_level_nodes!(nodes, child, options)
    end
    return nodes
end

# wrapper generator options
options = load_options(joinpath(@__DIR__, "generator.toml"))

# Use C++ mode so that the cbindgen-generated headers use proper enum typedefs
# (i.e. `enum X : uint8_t { ... };` with no separate `typedef uint8_t X`).
# C++ mode activates `extern "C"` blocks around function declarations (handled above).
# We also need a stub <complex> header since qiskit/complex.h includes it in C++ mode.
stub_dir = joinpath(@__DIR__, "stub_cxx")
mkpath(stub_dir)
write(joinpath(stub_dir, "complex"),
    """
    #pragma clang system_header
    #ifndef _GLIBCXX_COMPLEX
    #define _GLIBCXX_COMPLEX 1
    namespace std {
      template<typename> class complex;
      template<>
      class complex<double> {
        double _M_value[2];
      public:
        complex(double __re = 0.0, double __im = 0.0) : _M_value{__re, __im} {}
        double real() const { return _M_value[0]; }
        double imag() const { return _M_value[1]; }
      };
    }
    #endif
    """)
args = get_default_args()
push!(args, "-I$include_dir")
push!(args, "-x", "c++")
push!(args, "-std=c++11")
push!(args, "-nostdinc++")
push!(args, "-isystem$stub_dir")
push!(args, "-D__cplusplus")

# Only parse the top-level qiskit.h — it transitively includes everything we need.
headers = [joinpath(include_dir, "qiskit.h")]

# create context
ctx = create_context(headers, args, options)

# run generator
build!(ctx)
