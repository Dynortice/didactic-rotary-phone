include("euler/Julia/calculus.jl")

function compute(n::Integer)::Integer
    result, max_chain, hashmap = 0, 0, Dict(1 => 1)
    for i in 2:n-1
        chain = calculus.len_collatz_chain(i, hashmap)
        if chain > max_chain
            result, max_chain = i, chain
        end
    end
    return result
end
