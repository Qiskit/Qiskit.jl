using JuliaFormatter

# Format the project directories explicitly rather than the repository root, so that a
# run here never descends into git worktrees or other checkouts that may sit inside
# this directory.
dirs = ["benchmark", "docs", "ext", "gen", "lib", "src", "test"]

if format([joinpath(dirname(@__DIR__), dir) for dir in dirs])
    println("All files are already formatted.")
else
    println("Some files were reformatted.")
end
