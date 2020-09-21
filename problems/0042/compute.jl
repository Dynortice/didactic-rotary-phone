function compute(words::Array)::Int64
    triangles = [1]

    function add_triangle()
        n = length(triangles)
        append!(triangles, n * (n + 1) ÷ 2)
    end

    chars = Dict(Char(Int('A') + i) => i + 1 for i in 0:25)
    triangle_words = 0

    for word in words
        value = sum(chars[letter] for letter in word)
        while value > maximum(triangles)
            add_triangle()
        end
        if value in triangles
            triangle_words += 1
        end
    end
    return triangle_words
end