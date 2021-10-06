using Parameters: @with_kw

using Unitful
using UnPack: @unpack

export wavelength
export focal_spread


"""
    wavelength(V)

Compute the electron wavelength of the accelerating voltage `V`, e.g. `300u"kV"` or 300_000u"V".
"""
function wavelength(V)::typeof(1.0u"nm")
    e  = 1.60217663e-19u"C" 
    m₀ = 9.10938370e-31u"kg" 
    c  = 2.99792458e8u"m/s" 
    h  = 6.62607015e-34u"N*m*s" 

    λ = h / sqrt(2m₀ * e * V * (1 + e * V / (2m₀ * c^2)))
    return λ
end

"""
    focal_spread(Cc::Unitful.Length; dE=3.0e-3u"kV", E=300u"kV", dU=1u"V", U=1000u"V", dI=1u"nA", I=1000u"nA")
Calculate the focal spread based on, `Cc`, `dE/E`, `dI/I`, `dU/U`.
"""
function focal_spread(Cc::Unitful.Length; dE=3.0e-3u"kV", E=300u"kV", dU=1u"V", U=1000u"V", dI=1u"nA", I=1000u"nA")
    Δf = uconvert(u"nm", Cc) * sqrt((dE/E)^2 + (dU/U)^2 + 4*(dI/I)^2)
    return Δf
end

"""
    χ(K, λ, aberration::RealAberration)
    χ(ω::Complex, aberration::ComplexAberration)
    χ(K, λ, aberration::ComplexAberration) 

Wave aberration function as defined in 
"""
function χ(K, λ::typeof(1.0u"nm"), aberration::RealAberration) 
    Cₙₘ = convert(KrivanekNotationPolar, aberration)
    @unpack C₁₀, C₁₂, ϕ₁₂, C₂₁, ϕ₂₁, C₂₃, ϕ₂₃, C₃₀, C₃₂, ϕ₃₂, C₃₄, ϕ₃₄, C₄₁, ϕ₄₁, C₄₃, ϕ₄₃, C₄₅, ϕ₄₅, C₅₀, C₅₂, ϕ₅₂, C₅₄, ϕ₅₄, C₅₆, ϕ₅₆ = Cₙₘ

    k = abs(uconvert(u"nm^-1", K))
    ϕ = angle(K)

    # δ =   C₀₁ * λ   * k   * cos(  ϕ - ϕ₀₁ ) +
    δ =  
    1/2 * C₁₀ * λ^2 * k^2                   +
    1/2 * C₁₂ * λ^2 * k^2 * cos(2(ϕ - ϕ₁₂)) +
    1/3 * C₂₁ * λ^3 * k^3 * cos( (ϕ - ϕ₂₁)) +
    1/3 * C₂₃ * λ^3 * k^3 * cos(3(ϕ - ϕ₂₃)) +
    1/4 * C₃₀ * λ^4 * k^4                   +
    1/4 * C₃₂ * λ^4 * k^4 * cos(2(ϕ - ϕ₃₂)) +
    1/4 * C₃₄ * λ^4 * k^4 * cos(4(ϕ - ϕ₃₄)) +
    1/5 * C₄₁ * λ^5 * k^5 * cos( (ϕ - ϕ₄₁)) +
    1/5 * C₄₃ * λ^5 * k^5 * cos(3(ϕ - ϕ₄₃)) +
    1/5 * C₄₅ * λ^5 * k^5 * cos(5(ϕ - ϕ₄₅)) +
    1/6 * C₅₀ * λ^6 * k^6                   +
    1/6 * C₅₂ * λ^6 * k^6 * cos(4(ϕ - ϕ₅₂)) +
    1/6 * C₅₄ * λ^6 * k^6 * cos(2(ϕ - ϕ₅₄)) +
    1/6 * C₅₆ * λ^6 * k^6 * cos(6(ϕ - ϕ₅₆))
    return upreferred(2π*δ/λ)
end

# TODO: What should this do?
function χ(wave::DiffractionWave)
    K = similar(wave.data) * unit(wave.space.du)
    λ = wave.beam.λ
    Cₙₘ = wave.aberration
    return χ.(K, λ, Cₙₘ)
end

function χ(ω::Complex, aberration::ComplexAberration)
    Cₙₘ = convert(KrivanekNotationComplex, aberration)
    @unpack C₁₀, C₁₂, C₂₁, C₂₃, C₃₀, C₃₂, C₃₄, C₄₁, C₄₃, C₄₅, C₅₀, C₅₂, C₅₄, C₅₆ = Cₙₘ

    ω̅ = conj(ω)
    δ =   C₀₁ * ω         +
    1/2 * C₁₀ * ω   * ω̅   +
    1/2 * C₁₂ * ω̅^2       +
    1/3 * C₂₁ * ω^2 * ω̅   +
    1/3 * C₂₃ * ω̅^3       +
    1/4 * C₃₀ *(ω * ω̅)^2  +
    1/4 * C₃₂ * ω^3 * ω̅   +
    1/4 * C₃₄ * ω̅^4       +
    1/5 * C₄₁ * ω^3 * ω̅^2 +
    1/5 * C₄₃ * ω^4 * ω̅   +
    1/5 * C₄₅ * ω̅^5       +
    1/6 * C₅₀ *(ω * ω̅)^3  +
    1/6 * C₅₂ * ω^4 * ω̅^2 +
    1/6 * C₅₄ * ω^5 * ω̅   +
    1/6 * C₅₆ * ω̅^6 
    return upreferred(real(2π*δ/λ))
end

χ(K, λ::typeof(1.0u"nm"), aberration::ComplexAberration) = χ(λ * K, aberration)

"""
    temporal_coherence_envelope(λ, k, Δf)

Temporal coherence envelope function. 
"""
function temporal_coherence_envelope(λ, k, Δf)
    return exp(-0.5*π^2*Δf^2*k^4*λ^2)
end

"""
    spatial_coherence_envelope(λ, k, beam_divergence, c1, c3)

Spatial coherence envelope function. 
"""
function spatial_coherence_envelope(λ, k, sd, c1, c3)
    return exp(-π^2*sd^2 * (c1*k + c3*k^3*λ^2))
end

# When used correctly, quantities with units shouldn't generate much, if any, overhead.

# function wavelength_unitless(V)
#     e  = 1.60217663e-19 # C
#     m₀ = 9.10938370e-31 # kg
#     c  = 2.99792458e8 # m/s
#     h  = 6.62607015e-34 # N·m·s

#     λ = h/sqrt(2*m₀*e*V*(1 + e*V/(2*m₀*c^2)))
#     return λ
# end

# @btime wavelength(300000u"V")
# @btime wavelength_unitless(300000)