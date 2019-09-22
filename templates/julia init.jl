# use include("init.jl")

initial_wd = pwd()
while !in(".git",readdir())
    if in(pwd(),["/"])
        cd(initial_wd)
        println("git folder not found")
        break
    end
    cd("..")
end
println(pwd())
