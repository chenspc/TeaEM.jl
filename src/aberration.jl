using Configurations
using Unitful
import Base.convert


abstract type AbstractAberration end
Base.Broadcast.broadcastable(x::AbstractAberration) = Ref(x)

abstract type RealAberration <: AbstractAberration end
abstract type ComplexAberration <: AbstractAberration end

@option struct SaxtonNotationPolar <: RealAberration
    # A₀::typeof(0.0u"nm") = 0.0u"nm" 
    # α₀::typeof(0.0u"°")  = 0.0u"°" 

    C₁::typeof(0.0u"nm") = 0.0u"nm" 
    A₁::typeof(0.0u"nm") = 0.0u"nm" 
    α₁::typeof(0.0u"°")  = 0.0u"°" 

    B₂::typeof(0.0u"nm") = 0.0u"nm" 
    β₂::typeof(0.0u"°")  = 0.0u"°" 
    A₂::typeof(0.0u"nm") = 0.0u"nm" 
    α₂::typeof(0.0u"°")  = 0.0u"°" 

    C₃::typeof(0.0u"μm") = 0.0u"μm" 
    A₃::typeof(0.0u"μm") = 0.0u"μm" 
    α₃::typeof(0.0u"°")  = 0.0u"°" 
    S₃::typeof(0.0u"μm") = 0.0u"μm" 
    σ₃::typeof(0.0u"°")  = 0.0u"°" 

    B₄::typeof(0.0u"μm") = 0.0u"μm" 
    β₄::typeof(0.0u"°")  = 0.0u"°" 
    A₄::typeof(0.0u"μm") = 0.0u"μm" 
    α₄::typeof(0.0u"°")  = 0.0u"°" 
    D₄::typeof(0.0u"μm") = 0.0u"μm" 
    δ₄::typeof(0.0u"°")  = 0.0u"°" 

    C₅::typeof(0.0u"mm") = 0.0u"mm" 
    A₅::typeof(0.0u"mm") = 0.0u"mm" 
    α₅::typeof(0.0u"°")  = 0.0u"°" 
    S₅::typeof(0.0u"mm") = 0.0u"mm" 
    σ₅::typeof(0.0u"°")  = 0.0u"°" 
    R₅::typeof(0.0u"mm") = 0.0u"mm" 
    ρ₅::typeof(0.0u"°")  = 0.0u"°" 
end

@option struct KrivanekNotationPolar <: RealAberration
    # C₀₁::typeof(0.0u"nm") = 0.0u"nm" 
    # ϕ₀₁::typeof(0.0u"°")  = 0.0u"°" 

    C₁₀::typeof(0.0u"nm") = 0.0u"nm" 
    C₁₂::typeof(0.0u"nm") = 0.0u"nm" 
    ϕ₁₂::typeof(0.0u"°")  = 0.0u"°" 

    C₂₁::typeof(0.0u"nm") = 0.0u"nm" 
    ϕ₂₁::typeof(0.0u"°")  = 0.0u"°" 
    C₂₃::typeof(0.0u"nm") = 0.0u"nm" 
    ϕ₂₃::typeof(0.0u"°")  = 0.0u"°" 

    C₃₀::typeof(0.0u"μm") = 0.0u"μm" 
    C₃₂::typeof(0.0u"μm") = 0.0u"μm" 
    ϕ₃₂::typeof(0.0u"°")  = 0.0u"°" 
    C₃₄::typeof(0.0u"μm") = 0.0u"μm" 
    ϕ₃₄::typeof(0.0u"°")  = 0.0u"°" 

    C₄₁::typeof(0.0u"μm") = 0.0u"μm" 
    ϕ₄₁::typeof(0.0u"°")  = 0.0u"°" 
    C₄₃::typeof(0.0u"μm") = 0.0u"μm" 
    ϕ₄₃::typeof(0.0u"°")  = 0.0u"°" 
    C₄₅::typeof(0.0u"μm") = 0.0u"μm" 
    ϕ₄₅::typeof(0.0u"°")  = 0.0u"°" 

    C₅₀::typeof(0.0u"mm") = 0.0u"mm" 
    C₅₂::typeof(0.0u"mm") = 0.0u"mm" 
    ϕ₅₂::typeof(0.0u"°")  = 0.0u"°" 
    C₅₄::typeof(0.0u"mm") = 0.0u"mm" 
    ϕ₅₄::typeof(0.0u"°")  = 0.0u"°" 
    C₅₆::typeof(0.0u"mm") = 0.0u"mm" 
    ϕ₅₆::typeof(0.0u"°")  = 0.0u"°" 
end

@option struct SawadaNotationPolar <: RealAberration
    # A₁::typeof(0.0u"nm") = 0.0u"nm" 
    # ∠A₁::typeof(0.0u"°")  = 0.0u"°" 

    O₂::typeof(0.0u"nm") = 0.0u"nm" 
    A₂::typeof(0.0u"nm") = 0.0u"nm" 
    ∠A₂::typeof(0.0u"°")  = 0.0u"°" 

    P₃::typeof(0.0u"nm") = 0.0u"nm" 
    ∠P₃::typeof(0.0u"°")  = 0.0u"°" 
    A₃::typeof(0.0u"nm") = 0.0u"nm" 
    ∠A₃::typeof(0.0u"°")  = 0.0u"°" 

    O₄::typeof(0.0u"μm") = 0.0u"μm" 
    Q₄::typeof(0.0u"μm") = 0.0u"μm" 
    ∠Q₄::typeof(0.0u"°")  = 0.0u"°" 
    A₄::typeof(0.0u"μm") = 0.0u"μm" 
    ∠A₄::typeof(0.0u"°")  = 0.0u"°" 

    P₅::typeof(0.0u"μm") = 0.0u"μm" 
    ∠P₅::typeof(0.0u"°")  = 0.0u"°" 
    R₅::typeof(0.0u"μm") = 0.0u"μm" 
    ∠R₅::typeof(0.0u"°")  = 0.0u"°" 
    A₅::typeof(0.0u"μm") = 0.0u"μm" 
    ∠A₅::typeof(0.0u"°")  = 0.0u"°" 

    O₆::typeof(0.0u"mm") = 0.0u"mm" 
    Q₆::typeof(0.0u"mm") = 0.0u"mm" 
    ∠Q₆::typeof(0.0u"°")  = 0.0u"°" 
    ignored_C₅₄::typeof(0.0u"mm") = 0.0u"mm" 
    ignored_∠C₅₄::typeof(0.0u"°")  = 0.0u"°" 
    A₆::typeof(0.0u"mm") = 0.0u"mm" 
    ∠A₆::typeof(0.0u"°")  = 0.0u"°" 
end

@option struct HaiderNotationPolar <: RealAberration
    # A₀::typeof(0.0u"nm") = 0.0u"nm" 
    # α₀::typeof(0.0u"°")  = 0.0u"°" 

    C₁::typeof(0.0u"nm") = 0.0u"nm" 
    A₁::typeof(0.0u"nm") = 0.0u"nm" 
    α₁::typeof(0.0u"°")  = 0.0u"°" 

    B₂::typeof(0.0u"nm") = 0.0u"nm" 
    β₂::typeof(0.0u"°")  = 0.0u"°" 
    A₂::typeof(0.0u"nm") = 0.0u"nm" 
    α₂::typeof(0.0u"°")  = 0.0u"°" 

    C₃::typeof(0.0u"μm") = 0.0u"μm" 
    S₃::typeof(0.0u"μm") = 0.0u"μm" 
    σ₃::typeof(0.0u"°")  = 0.0u"°" 
    A₃::typeof(0.0u"μm") = 0.0u"μm" 
    α₃::typeof(0.0u"°")  = 0.0u"°" 

    B₄::typeof(0.0u"μm") = 0.0u"μm" 
    β₄::typeof(0.0u"°")  = 0.0u"°" 
    D₄::typeof(0.0u"μm") = 0.0u"μm" 
    δ₄::typeof(0.0u"°")  = 0.0u"°" 
    A₄::typeof(0.0u"μm") = 0.0u"μm" 
    α₄::typeof(0.0u"°")  = 0.0u"°" 

    C₅::typeof(0.0u"mm") = 0.0u"mm" 
    S₅::typeof(0.0u"mm") = 0.0u"mm" 
    σ₅::typeof(0.0u"°")  = 0.0u"°" 
    R₅::typeof(0.0u"mm") = 0.0u"mm" 
    ρ₅::typeof(0.0u"°")  = 0.0u"°" 
    A₅::typeof(0.0u"mm") = 0.0u"mm" 
    α₅::typeof(0.0u"°")  = 0.0u"°" 
end

convert(::Type{SaxtonNotationPolar}, x::KrivanekNotationPolar) = SaxtonNotationPolar(collect(values(to_dict(x; include_defaults=true)))...)
convert(::Type{KrivanekNotationPolar}, x::SaxtonNotationPolar) = KrivanekNotationPolar(collect(values(to_dict(x; include_defaults=true)))...)
convert(::Type{SawadaNotationPolar}, x::KrivanekNotationPolar) = SawadaNotationPolar(collect(values(to_dict(x; include_defaults=true)))...)
convert(::Type{SawadaNotationPolar}, x::SaxtonNotationPolar) = SawadaNotationPolar(collect(values(to_dict(x; include_defaults=true)))...)
convert(::Type{SaxtonNotationPolar}, x::SawadaNotationPolar) = SaxtonNotationPolar(collect(values(to_dict(x; include_defaults=true)))...)
convert(::Type{KrivanekNotationPolar}, x::SawadaNotationPolar) = KrivanekNotationPolar(collect(values(to_dict(x; include_defaults=true)))...)


@option struct KrivanekNotationCartesian <: RealAberration
    # C01a::typeof(0.0u"nm") = 0.0u"nm" 
    # C01b::typeof(0.0u"nm") = 0.0u"nm" 

    C10::typeof(0.0u"nm") = 0.0u"nm" 
    C12a::typeof(0.0u"nm") = 0.0u"nm" 
    C12b::typeof(0.0u"nm") = 0.0u"nm" 

    C21a::typeof(0.0u"nm") = 0.0u"nm" 
    C21b::typeof(0.0u"nm") = 0.0u"nm" 
    C23a::typeof(0.0u"nm") = 0.0u"nm" 
    C23b::typeof(0.0u"nm") = 0.0u"nm" 

    C30::typeof(0.0u"μm") = 0.0u"μm" 
    C32a::typeof(0.0u"μm") = 0.0u"μm" 
    C32b::typeof(0.0u"μm") = 0.0u"μm" 
    C34a::typeof(0.0u"μm") = 0.0u"μm" 
    C34b::typeof(0.0u"μm") = 0.0u"μm" 

    C41a::typeof(0.0u"μm") = 0.0u"μm" 
    C41b::typeof(0.0u"μm") = 0.0u"μm" 
    C43a::typeof(0.0u"μm") = 0.0u"μm" 
    C43b::typeof(0.0u"μm") = 0.0u"μm" 
    C45a::typeof(0.0u"μm") = 0.0u"μm" 
    C45b::typeof(0.0u"μm") = 0.0u"μm" 

    C50::typeof(0.0u"mm") = 0.0u"mm" 
    C52a::typeof(0.0u"mm") = 0.0u"mm" 
    C52b::typeof(0.0u"mm") = 0.0u"mm" 
    C54a::typeof(0.0u"mm") = 0.0u"mm" 
    C54b::typeof(0.0u"mm") = 0.0u"mm" 
    C56a::typeof(0.0u"mm") = 0.0u"mm" 
    C56b::typeof(0.0u"mm") = 0.0u"mm" 
end

@option struct KrivanekNotationComplex <: ComplexAberration
    # C₀₁::typeof((0.0 + 0.0im)u"nm") = 0.0u"nm" 

    C₁₀::typeof(0.0u"nm") = 0.0u"nm" 
    C₁₂::typeof((0.0 + 0.0im)u"nm") = 0.0u"nm" 

    C₂₁::typeof((0.0 + 0.0im)u"nm") = 0.0u"nm" 
    C₂₃::typeof((0.0 + 0.0im)u"nm") = 0.0u"nm" 

    C₃₀::typeof(0.0u"μm") = 0.0u"μm" 
    C₃₂::typeof((0.0 + 0.0im)u"μm") = 0.0u"μm" 
    C₃₄::typeof((0.0 + 0.0im)u"μm") = 0.0u"μm" 

    C₄₁::typeof((0.0 + 0.0im)u"μm") = 0.0u"μm" 
    C₄₃::typeof((0.0 + 0.0im)u"μm") = 0.0u"μm" 
    C₄₅::typeof((0.0 + 0.0im)u"μm") = 0.0u"μm" 

    C₅₀::typeof(0.0u"mm") = 0.0u"mm" 
    C₅₂::typeof((0.0 + 0.0im)u"mm") = 0.0u"mm" 
    C₅₄::typeof((0.0 + 0.0im)u"mm") = 0.0u"mm" 
    C₅₆::typeof((0.0 + 0.0im)u"mm") = 0.0u"mm" 
end