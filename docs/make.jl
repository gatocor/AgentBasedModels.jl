push!(LOAD_PATH,"../docs/src/")
push!(LOAD_PATH,"./src")

using Documenter, AgentBasedModels

makedocs(sitename="AgentModel.jl",
pages = [
    "Home" => "index.md",
    "First steps.md",
    "API.md",
    "APIdevelopers.md"
],
format = Documenter.HTML(prettyurls = false)
)

deploydocs(
    repo = "github.com/gatocor/AgentBasedModels.jl",
)