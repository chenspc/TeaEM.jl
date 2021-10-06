module TeaEM

const Illumination = Probe
const Specimen = Object

import Base: conj, abs, max
# using TeaEM: wavelength
# using TeaEMAberration: ...
using Setfield # https://www.youtube.com/watch?v=vkAOYeTpLg0

"Page 827, Eq.(17.1)"
Base.@kwdef struct ComputingParameters
    ncores::Int = 64
    nthreads::Int = 12
    memory_size::Int = 1024^3*64
    gpu::Vector{Int} = [0]
end

"""A list of parameters related to the computation of ptychography reconstruction
Page 827, Eq.(17.1)

    λ: wavelength of radiation 
    Δθ: angular dimension of one detector pixel
    detector_size: 
    D: field of view in the object space

"""
# Base.@kwdef struct PtychoParameters
    # λ::Int = wavelength(300) |> ustrip
    # Δθ::Float64
    # detector_size::Vector{Int} = [512,512]
    # D::Vector{Float64}
# end

struct ElectronBeam
    λ::typeof(1.0u"nm")
    α::typeof(1.0u"mrad")
end

abstract type Space end
abstract type RealSpace <: Space end
abstract type ReciprocalSpace <: Space end

# TODO: Maybe it's better to make Fourier plan when creating space. (Or at least make it optional.)
# TODO: Think about the whether to use "spatial frequency (u"nm^-1")" or scattering angle (dimensionless) for reciprocal space. 
struct RealSpace2D <: RealSpace
    origin::Vector{typeof(1.0u"nm")}
    dr::typeof(1.0u"nm")
    boundary::Vector{Vector{Float64}}
    RealSpace2D(origin, dr, boundary) = begin
        if length(origin) == 2 
            if length.(boundary) == [2, 2] && all(boundary[1] .< boundary[2])
                new(origin, dr, boundary)
            else
                error("Incorrect boundary points for 2D Space") 
            end
        else
            error("Incorrect dimensions for 2D Space") 
        end
    end
end 

struct RealSpace3D <: RealSpace
    origin::Vector{typeof(1.0u"nm")}
    dr::typeof(1.0u"nm")
    boundary::Vector{Vector{Float64}}
    RealSpace3D(origin, dr, boundary) = begin
        if length(origin) == 2 
            if length.(boundary) == [3, 3] && all(boundary[1] .< boundary[2])
                new(origin, dr, boundary)
            else
                error("Incorrect boundary points for 3D Space") 
            end
        else
            error("Incorrect dimensions for 3D Space") 
        end
    end
end 

struct ReciprocalSpace2D <: ReciprocalSpace
    origin::Vector{typeof(1.0u"nm^-1")}
    du::typeof(1.0u"nm^-1")
    boundary::Vector{Vector{Float64}}
    ReciprocalSpace2D(origin, du, boundary) = begin
        if length(origin) == 2 
            if length.(boundary) == [2, 2] && all(boundary[1] .< boundary[2])
                new(origin, du, boundary)
            else
                error("Incorrect boundary points for 2D Space") 
            end
        else
            error("Incorrect dimensions for 2D Space") 
        end
    end
end 

struct ReciprocalSpace3D <: ReciprocalSpace
    origin::Vector{typeof(1.0u"nm^-1")}
    du::typeof(1.0u"nm^-1")
    boundary::Vector{Vector{Float64}}
    ReciprocalSpace3D(origin, du, boundary) = begin
        if length(origin) == 2 
            if length.(boundary) == [3, 3] && all(boundary[1] .< boundary[2])
                new(origin, du, boundary)
            else
                error("Incorrect boundary points for 3D Space") 
            end
        else
            error("Incorrect dimensions for 3D Space") 
        end
    end
end 

abstract type Intensity end

"""
    data: 2D array that represent the diffraction wave (if complex), or the diffraction intensity (if real)
    # Δθ: angular sampling
    # center: pixel index corresponds to the center of the diffraction plane where the optical axis passes through
    space: reciprocal 2d space that the difraction is at
"""
struct DiffractionIntensity{T} <: Intensity where T <: AbstractFloat
    data::Array{T,2}
    space::ReciprocalSpace2D
end 

struct ImageIntensity{T} <: Intensity where T <: AbstractFloat
    data::Array{T,2}
    space::RealSpace2D
end 

abstract type AbstractObject end

struct Object2D{T} <: AbstractObject where T <: AbstractFloat
    data::Array{T,2}
    space::RealSpace2D
end 
Object2D(data) = Object2D(data, RealSpace2D([0, 0], 1, [[0, 0], collect(size(data))]))

struct Object3D{T} <: AbstractObject where T <: AbstractFloat
    data::Array{T,3}
    space::RealSpace3D
end 
Object3D(data) = Object3D(data, RealSpace3D([0, 0, 0], 1, [[0, 0, 0], collect(size(data))]))

abstract type Wave end 
conj(x::Wave) = ;
abs(x::Wave) = ;
max(x::Wave) = ;

"""
    data: 2D array that represent the probe wave (if complex), or the probe intensity (if real)
    sampling: angular sampling
    position: pixel index corresponds to the center of the diffraction plane where the optical axis passes through
"""
struct ProbeWave{T} <: Wave where T <: AbstractFloat
    data::Array{Complex{T},2}
    position::Vector{Float64}
    beam::ElectronBeam
    # Maybe `aberration` should be put inside beam rather than next to it.
    aberration::AbstractAberration
    space::RealSpace2D
end 
ProbeWave(data, beam::ElectronBeam, aberration::AbstractAberration) = ProbeWave(data, [0,0], beam, aberration::AbstractAberration, RealSpace2D([0, 0], 1, [[0, 0], collect(size(data))]))
ProbeWave(data, beam::ElectronBeam) = ProbeWave(data, [0,0], beam, KrivanekNotation())

struct DiffractionWave{T} <: Wave where T <: AbstractFloat
    data::Array{Complex{T},2}
    beam::ElectronBeam
    # Maybe `aberration` should be put inside beam rather than next to it.
    aberration::AbstractAberration
    space::ReciprocalSpace2D
end 
DiffractionWave(data, beam::ElectronBeam, aberration::AbstractAberration) = DiffractionWave(data, beam, aberration::AbstractAberration, ReciprocalSpace2D([0, 0], 1, [[0, 0], collect(size(data))]))
DiffractionWave(data, beam::ElectronBeam) = DiffractionWave(data, beam, KrivanekNotation())

"""
Exit wave is the electron wave at the sample's exit plane. Most phase retrival techniques aim to retrivel the phase 
information of this wave since it carries the most amount of information about the object.  
"""
struct ExitWave{T} <: Wave where T <: AbstractFloat
    data::Array{Complex{T},2}
    beam::ElectronBeam
    space::RealSpace2D
end
ExitWave(d, beam) = ExitWave(d, beam, RealSpace2D([0, 0], 1, [[0, 0], collect(size(d))]))
# import Base.^
# ^(x::ExitWave, y::Int)  = y == 2 ? ImageIntensity(abs2.(x.data), x.space) : ExitWave(abs.(x.data).^y, x.λ, x.space)
# ^(x::ExitWave, y::Int)  = y == 2 ? ImageIntensity(abs2.(x.data), x.space) : error("Not sure if $x^$y makes sense.")

function ExitWave(obj::Object2D, pb::Probe) 
    rescale_factor = obj.sampling == pb.sampling ? 1 : pb.sampling / obj.sampling
    # sub_obj = view()
    probe = zero(obj.data)
end


function rescale(obj::AbstractObject, factor)

end

# abstract type TransmisionFunction end 
struct TransmisionFunction{T} where T <: AbstractFloat
    data::Array{T,3}
    space::RealSpace3D
end

function TransmisionFunction(obj::Object3D, pb::Probe) 
    # rescale_factor = obj.sampling == pb.sampling ? 1 : pb.sampling / obj.sampling
    # probe = zero(obj.data)
end

function fft(ew::Wave)

end

function ifft(ew::Wave)

end

function diffraction_intensity(ex::ExitWave)
    return (fft(ex)).^2
end

function propagate(wave::Wave; backwards=false)

end

forward_propagate(wave::Wave) = propagate(wave::Wave; backwards=false)
backward_propagate(wave::Wave) = propagate(wave::Wave; backwards=true)

function nyquist(dp::AbstractDiffraction)
    return dp.Δθ * size(dp.data) / 2
end


# TODO: If we start the iteration from multiple places, maybe it's worth saving/updating both the object and its complex conjugate. When two areas meet, this is particularly important

# TODO: Pick three random images and make them discrete (e.g. 1:128), raplace the region with corresponding atoms. Combine the three into one sample. Do the ptycho simulation, and then reconstruct it. 

# TODO: Figure out all the samplings: probe_real_space_sampling, object_real_space_sampling, diffraction_sampling, defocus, probe_real_space_size, object_real_space_size, convergence_semiangle, diffraction_frequency

probe_diameter = tan(α) * defocus
probe_array_diameter := diffraction_array_diameter

# There is no difference between an object and an empty object space in terms of guess. Need to come up a way to pub one space into another space's coordinates. (Larger space -> space -> subspace) 


# TODO: Lens, Source, Aperature

abstract type Lens end
mutable struct CondenserLens <: Lens
    axis::Float64
    f::Float64
    Δθ::Float64
    magnification::Float64
    aberration::Aberration
    # Δf::Float64
    # Δs::Float64
end

mutable struct ObjectiveLens <: Lens
    axis::Float64
    f::Float64
    Δθ::Float64
    magnification::Float64
    aberration::Aberration
    # Δf::Float64
    # Δs::Float64
    I::Float64
    ΔI::Float64
end

struct IntermediateLens <: Lens
    magnification::Float64
end


struct ProjectionLens <: Lens
    magnification::Float64
end



abstract type Aperture end
struct CondenserLensAperture <: Aperture
    data::Matrix{Bool}
    α::Float64
    space::ReciprocalSpace2D
end
struct SelectedAreaAperture <: Aperture
    data::Matrix{Bool}
    a::Float64
    space::RealSpace2D
end
struct ObjectiveLensAperture <: Aperture
    data::Matrix{Bool}
    α::Float64
    space::ReciprocalSpace2D
end

abstract type ElectronSource end
struct ColdFEG
    U::Float64
    ΔU::Float64
end

abstract type Monochromator end
# abstract type AccelerationTube end

struct AccelerationTube 
    E::Float64
    ΔE::Float64
end

abstract type AberrationCorrector end
mutable struct ProbeCorrector{T} <: AberrationCorrector
    data::Array{T, 2}
    space::ReciprocalSpace2D
end

mutable struct ImageCorrector{T} <: AberrationCorrector
    data::Array{T, 2}
    space::ReciprocalSpace2D
end

abstract type SampleHolder end
mutable struct SingleTiltHolder <: SampleHolder
    space::RealSpace3D
    x::Float64
    y::Float64
    z::Float64
    tiltx::Float64
    # tilty::Float64

    # x_min::Float64
    # x_max::Float64
    # y_min::Float64
    # y_max::Float64
    # z_min::Float64
    # z_max::Float64
    tiltx_min::Float64
    tiltx_max::Float64
    # tilty_min::Float64
    # tilty_max::Float64
end

mutable struct DoubleTiltHolder <: SampleHolder
    space::RealSpace3D
    x::Float64
    y::Float64
    z::Float64
    tiltx::Float64
    tilty::Float64

    # x_min::Float64
    # x_max::Float64
    # y_min::Float64
    # y_max::Float64
    # z_min::Float64
    # z_max::Float64
    tiltx_min::Float64
    tiltx_max::Float64
    tilty_min::Float64
    tilty_max::Float64
end

abstract type EnergyFilter end
abstract type Detector end
mutable struct Medipix <: Detector
    camera_length::Float64
    array_size::Vector{Int}
    pixel_size::Float64
    exposure_time::Float64
    mtf::Vector{Float64}
    nps::Vector{Float64}
    dqe::Vector{Float64}
end
mutable struct Celeritas <: Detector
    camera_length::Float64
    array_size::Vector{Int}
    pixel_size::Float64
    exposure_time::Float64
    mtf::Vector{Float64}
    nps::Vector{Float64}
    dqe::Vector{Float64}
end
mutable struct K2 <: Detector
    camera_length::Float64
    array_size::Vector{Int}
    pixel_size::Float64
    exposure_time::Float64
    mtf::Vector{Float64}
    nps::Vector{Float64}
    dqe::Vector{Float64}
end
mutable struct Orius <: Detector
    camera_length::Float64
    array_size::Vector{Int}
    pixel_size::Float64
    exposure_time::Float64
    mtf::Vector{Float64}
    nps::Vector{Float64}
    dqe::Vector{Float64}
end

# TODO: Think about what would be the difference between Beam and Probe.
# Maybe Probe can have probe position but Beam shouldn't?
# abstract type ElectronBeam end

abstract type Controller end
abstract type XboxController <: Controller end
abstract type Keyboard <: Controller end

abstract type ControllerComponent end
abstract type Knob <: ControllerComponent end
abstract type Button <: ControllerComponent end
abstract type NavigationStick <: ControllerComponent end

# struct ParalellBeam <: ElectronBeam
#     # data::Matrix{Float64}
#     λ::Float64
# end
# struct ConvergentBeam <: ElectronBeam
#     # data::Matrix{Float64}
#     α::Float64
#     λ::Float64
# end




end #module