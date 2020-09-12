struct Big_Int
    str::AbstractString
    digits::Array
    positive::Bool

    function Big_Int(str::AbstractString)
        if str ≠ ""
            str[1] ≡ '-' ? new(str[2:end], [parse(Int, i) for i in str[2:end]], false) : new(str, [parse(Int, i) for i in str], true)
        else
            new("0", [0], true)
        end
    end
end

pad(a::AbstractString, n::Integer, right::Bool = true)::String = right ? string(a, repeat("0", n)) : string(repeat("0", n), a)

function zero_pad(a::AbstractString, b::AbstractString, right::Bool = true)::Tuple{String, String}
    if length(a) > length(b)
        b = pad(b, length(a) - length(b), right)
    elseif length(b) > length(a)
        a = pad(a, length(b) - length(a), right)
    end
    return a, b
end

Base.show(io::IO, x::Big_Int) = show(x.str)

Base.length(x::Big_Int) = length(x.digits)

Base.getindex(x::Big_Int, i::Integer) = x.str[i]

Base.getindex(x::Big_Int, r::UnitRange{Int64}) = x.str[r]

Base.lastindex(x::Big_Int) = lastindex(x.str)

Base.:-(x::Big_Int) = Big_Int(string("-", x.str))

function Base.isless(x::Big_Int, y::Big_Int)
    if x.positive ≡ y.positive
        if length(x) ≡ length(y)
            if x ≡ y
                return false
            else
                for i in 1:length(x)
                    if x[i] ≡ y[i]
                        continue
                    else
                        return (x[i] < y[i]) & x.positive
                    end
                end
            end
        else
            return !((length(x) < length(y)) ⊻ x.positive)
        end
    else
        return !x.positive
    end
end

function Base.:+(x::Big_Int, y::Big_Int)::Big_Int
    if x.positive ≡ y.positive
        a, b = zero_pad(x.str, y.str, false)
        result = ""
        carry = 0
        for i in 1:Int(ceil(length(a) / 18))
            carry += parse(Int, a[max(1 - 18 * i + end, 1):end - 18 * (i - 1)]) + parse(Int, b[max(1 - 18 * i + end, 1):end - 18 * (i - 1)])
            result = string(repeat("0", 18 - min(length(string(carry)), 18)), string(carry)[max(end - 17, 1):end], result)
            carry ÷= 10 ^ 18
        end
        if carry ≠ 0
            result = string(carry, result)
        else
            result = lstrip(result, '0')
        end
        if x.positive
            return Big_Int(result)
        else
            return Big_Int(string("-", result))
        end
    else
        if x.positive
            return x - -y
        else
            return y - -x
        end
    end
end

function Base.:-(x::Big_Int, y::Big_Int)::Big_Int
    if x.positive ≠ y.positive
        if x.positive
            return x + -y
        else
            return -(-x + y)
        end
    else
        if x ≡ y
            return Big_Int('0')
        end
        if x.positive
            if x > y
                positive = true
                a, b = x.str, y.str
            else
                positive = false
                a, b = y.str, x.str
            end
        else
            if x > y
                positive = true
                a, b = y.str, x.str
            else
                positive = false
                a, b = x.str, y.str
            end
        end
        a, b = zero_pad(a, b, false)
        result = ""
        carry = 0
        for i in 1:Int(ceil(length(a) / 18))
            carry += parse(Int, a[max(1 - 18 * i + end, 1):end - 18 * (i - 1)]) - parse(Int, b[max(1 - 18 * i + end, 1):end - 18 * (i - 1)])
            if carry < 0
                result = string(repeat("0", 18 - length(string(10 ^ 18 + carry))), string(10 ^ 18 + carry), result)
                carry = -1
            else
                result = string(repeat("0", max(18 - length(string(carry)), 0)), carry, result)
                carry = 0
            end
        end
        result = lstrip(result, '0')
        if positive
            return Big_Int(result)
        else
            return Big_Int(string("-", result))
        end
    end
end

function Base.:*(x::Big_Int, y::Big_Int)::Big_Int
    function mul(x::Big_Int, y::Big_Int)::Big_Int
        if max(length(x), length(y)) < 10
            return Big_Int(string(parse(Int, x.str) * parse(Int, y.str)))
        end
        a, b = reverse(x.digits), reverse(y.digits)
        result = Big_Int("0")
        for i in 1:length(a)
            carry = 0
            sub_result = repeat("0", i)
            for j in 1:length(b)
                carry += a[i] * b[j]
                sub_result = string(carry % 10, sub_result)
                carry ÷= 10
            end
            result += Big_Int(lstrip(string(carry, sub_result), '0'))
        end
        return result
    end

    if (max(length(x), length(y)) < 10) | (min(length(x), length(y)) ≡ 1)
        return mul(x, y)
    end
    n = max(length(x), length(y))
    m = n ÷ 2
    a, b, c, d = Big_Int(x[1:end-m]), Big_Int(x[max(end-m+1, 1):end]), Big_Int(y[1:end-m]), Big_Int(y[max(end-m+1, 1):end])
    ac, bd, ab_cd = a * c, b * d, (a + b) * (c + d)
    println([ac, bd, ab_cd])
    r = Big_Int(pad(ac.str, 2 * m))
    s = Big_Int(pad((ab_cd - ac - bd).str, m))
    return r + s + bd
end
