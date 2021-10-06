
using UnPack: @unpack

"""
It is unlikely that the sampling of the object can accurately match the needs of probe sampling and step size. This helper function forces the object sampling (Δo) to be 1/2^n (n = 0, 1, 2...) of the real space probe sampling (Δp) while keeping the error percentage of step size (Δs) over Δp 
    Δo: object sampling
    Δp: probe sampling 
    Δs: step size
    max_error: the largest error percentage (over probe sampling) between adjacent probe positions.
"""
function object_sampling(Δp, Δs; max_error=1//20)
    Δo = Δp
    while max_error < mod(Δs, Δo) / Δp < 1 - max_error
        Δo /= 2
    end
    return Δo
end


    
# TODO: This might be a good place to use generated function (https://docs.julialang.org/en/v1/manual/metaprogramming/#Generated-functions)?

function aberration_phase(wave::Wave, aberration::AbstractAberration)
    λ = wave.beam.λ
end


function does_it_convert(a, b::Int)
    return (a::Float64, b)
end


# TODO: Need to figure out what coordinate systems Haider and Krivanek use and why there's a "star" when doing conversion.



function space2unitarray()
    
end 


