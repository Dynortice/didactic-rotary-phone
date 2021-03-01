include("euler/euler.jl")
using .Calculus: len_collatz_chain

function compute(n::Int)::Int
    result, max_chain, hashmap = 0, 0, Dict(1 => 1)
    for i ∈ 2:n-1
        if len_collatz_chain(i, hashmap) > max_chain result, max_chain = i, hashmap[i] end
    end
    return result
end
