"""
    update(q₁, a, Δψ; method="ePIE", α=0.2) 

The base function of `update_object` and `update_probe`. Support al
"""
function update(q₁, a, Δψ; method="ePIE", α=0.2) 
    a̅ = conj(a)
    aₘ = max(abs(a))
    aₘ² = aₘ ^ 2
    a² = a ^ 2

    if method == "ePIE"
        w = a̅ / aₘ²
    elseif method == "rPIE"
        w = a̅ / ((1 - α) * a² + α * aₘ²)
    elseif method == "PIE"
        ε = eps(eltype(a.data))
        w = (abs(a) / aₘ) * (a̅ / (a² + ε))
    else
        error("$method is not a supported object update method.")
    end

    q₂ = q₁ + w * Δψ
    return q₂ 
end

"""
    update_object(𝒪::AbstractObject, 𝒫::AbstractProbe, Δψ; method="ePIE", α=0.2) 

Given object `𝒪`, probe `𝒫`, and difference in exit wave `Δψ`, update `𝒪`.
"""
update_object(𝒪::AbstractObject, 𝒫::AbstractProbe, Δψ; method="ePIE", α=0.2) = update(𝒪, 𝒫, Δψ; method=method)

"""
    update_probe(𝒫::AbstractProbe, 𝒪::AbstractObject, Δψ; method="ePIE", β=0.2) 

Given object `𝒪`, probe `𝒫`, and difference in exit wave `Δψ`, update `𝒫`.
"""
update_probe(𝒫::AbstractProbe, 𝒪::AbstractObject, Δψ; method="ePIE", β=0.2) = update(𝒫, 𝒪, Δψ; method=method, α=β)

"""
    ptycho_iteration(𝒪₁::AbstractObject, 𝒫₁::AbstractProbe, ℐ::DiffractionIntensity; method="ePIE", α=0.2, β=0.2)

Perform an iteration of ptychography update to object `𝒪` and probe `𝒫`.
"""
function ptycho_iteration(𝒪₁::AbstractObject, 𝒫₁::AbstractProbe, ℐ::DiffractionIntensity; method="ePIE", α=0.2, β=0.2)
    ψ₁ = ExitWave(𝒪₁, 𝒫₁)
    𝒟 = repace_modulus(forward_propagate(ψ₁), sqrt(ℐ))
    ψ₂ = backward_propagate(𝒟)
    Δψ = ψ₂ - ψ₁
    𝒪₂ = update_object(𝒪₁, 𝒫₁, Δψ; method=method, α=α)
    𝒫₂ = update_probe(𝒫₁, 𝒪₂, Δψ; method=method, β=β)
    return 𝒪₂, 𝒫₂
end

"""
    replace_modulus(wave::Wave, modulus)

Replace the modulus of `wave` with `modulus`.
"""
function replace_modulus(wave::Wave, modulus)
    ε = eps(eltype(wave.data))
    wave = @set wave.data = wave.data ./ (abs(wave.data) .+ ε) .* modulus
    return wave 
end

"""
    shift_phase(wave::Wave, ϕ)
    
Apply phase shift `ϕ` to `wave`.
"""
function shift_phase(wave::Wave, ϕ)
    wave = @set wave.data = wave.data .* cis.(ϕ)
    return wave 
end

"P835, Eq.(17.7)"
function minimum_ptychographic_sampling_condition(𝒪::AbstractObject)
    ΔR = 𝒪.sampling
    return Δu = 1/2ΔR
end

"""
    gerchberg_saxton_algorithm(ℐ₁::Intensity, ℐ₂::Intensity; iteration=100)

Simple implementation of Gerchberg-Saxton algorithm.
Ref: [Gerchberg–Saxton algorithm](https://en.wikipedia.org/wiki/Gerchberg%E2%80%93Saxton_algorithm)
"""
function gerchberg_saxton_algorithm(ℐ₁::Intensity, ℐ₂::Intensity; iteration=100)
    A = propagate(ℐ₂; backwards=true)
    for i in 1:iteration
        B = repace_modulus(A, sqrt(ℐ₁))
        C = propagate(B)
        D = repace_modulus(C, sqrt(ℐ₂))
        A = propagate(D; backwards=true)
    end
    return angle(A)
end

function circle_overlap(r, d; pct=false)
    overlap_area = 2 * r^2 * acos(d/2r) - 0.5d * √(4r^2 - d^2)
    circle_area = pi * r^2
    overlap_pct = upreferred(overlap_area / circle_area) * 100u"percent"
    return pct ? (overlap_area, overlap_pct) : overlap_area
end