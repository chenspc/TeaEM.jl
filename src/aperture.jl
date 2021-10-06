"""
    circular_aperture(n::Integer, r<:Real; shift=CartesianIndex(0, 0))

Create a circular aperature of radius `r` at the centre of a `n×n` array. The centre can be offset by the optional parameter `shift` 
"""
function circular_aperture(n::Integer, r; shift=CartesianIndex(0, 0))
    data = Matrix{Bool}(undef, n, n)
    if n <= 2r 
        @warn("Aperature area exceeds the field of view even if centered.") 
    end
    origin =  CartesianIndex(ceil.(Int, size(data) ./ 2)...) + shift
    for ind in CartesianIndices(data)
        data[ind] = hypot(Tuple(ind - origin)...) <= r ? true : false
    end
    return data
end