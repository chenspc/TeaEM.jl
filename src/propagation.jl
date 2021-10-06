
# TODO: Implement band-width limit for propagation. This might be better fit into Space. 

"""
    fresnel_propagate(wave::Wave, z::Unitful.Length; type="auto")
Propagate `wave` by distance `z`.
Fresnel transfer function (TF) propagator
Fresnel impulse response (IR) propagator
"""
function fresnel_propagate(w₁::Wave, z::Unitful.Length; type="auto")
    λ = w₁.beam.λ
    # k = 2π/λ
    # TODO: Sampling determination should be automated.
    Δx = w₁.space.dr
    Δy = Δx
    # TODO: This is a placeholder. Need to think about how to generate Fx, Fy from `space`.
    Fx = range(0,Δfx,length=100)'  # note ': this is a row vector
    Fy = range(0,Δfy,length=100)

    # TODO: This is a placeholder. Need to think about how to generate X, Y from `space`.
    X = range(0,Δx,length=100)'  # note ': this is a row vector
    Y = range(0,Δy,length=100)

    if method == "auto"
        method = Δx >= critical_sampling(L, λ, z) ? "TF" : "IR"
    
    if method == "TF"
        # TODO: Double check the quation. 
        ℋ = @. cis(-π * λ * z * (Fx^2 + Fy^2))
        ℋ = fftshift(ℋ)
    elseif method == "IR"
        # TODO: Double check the quation. 
        h = @. 1/(im * λ * z) * cis(π / (λ * z) * (X^2 + Y^2)) * Δx^2
        ℋ = fft(fftshift(ℋ))
    else
        error("Unsupported propagator type: $method. Please choose between \"TF\" (transfer function) and \"IR\" (impulse response)")
    end
    u₁ = w₁.data
    𝒰₁ = fft(fftshift(u₁))
    𝒰₂ = ℋ .* 𝒰₁
    u₂ = ifftshift(ifft(𝒰₂))
    w₂ = @set w₁.data = u₂
    return w₂
end
