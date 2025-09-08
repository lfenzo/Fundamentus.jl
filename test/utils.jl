function _test_valid_dataframe(df::AbstractDataFrame) :: Nothing
    @test df isa DataFrame
    @test nrow(df) > 0
    return nothing
end


function _test_ticker_against_methods(; ticker::AbstractString, methods::Vector{Function}) :: Nothing
    for method in methods
        @testset "$method" begin
            method(ticker) |> _test_valid_dataframe
        end
    end
end
