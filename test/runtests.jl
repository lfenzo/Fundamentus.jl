using Test
using Dates
using DataFrames
using Fundamentus


include("utils.jl")


testsets = Dict{String, String}(
   "Utils" => "test_utils.jl",
   "Acoes" => "test_acoes.jl",
   "FIIs" => "test_fiis.jl",
)

@testset "Fundamentus" begin
    for (setname, test_file) in testsets
        @testset "$setname" begin
            include(test_file)
        end
    end
end
