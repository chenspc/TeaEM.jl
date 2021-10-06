# This file contains functions that operate on Space objects and well as functions that deal with sampling

"""
    fresnel_number(w::Unitful.Length, λ::Unitful.Length, z::Unitful.Length)

Calculate the Fresnel number.
w: half width of a square aperture in the source plane, or the radius of a circular aperture, 
λ: wavelength
z: distance to the observation plane.
"""
function fresnel_number(w::Unitful.Length, λ::Unitful.Length, z::Unitful.Length)
    N = w^2 / (λ * z)
    return N
end


"""
    critical_sampling(L::Unitful.Length, λ::Unitful.Length, z::Unitful.Length)

Calculate the critical sampling.
λ: wavelength
z: distance to the observation plane.
L: array side lenght
"""
function critical_sampling(L::Unitful.Length, λ::Unitful.Length, z::Unitful.Length)
    Δx = (λ * z) / L
    return Δx
end
