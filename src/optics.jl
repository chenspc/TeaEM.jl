abstract type OpticalElement end

"""
DriftSpace
L = the length of the drift space. 
γ = relativistic factor.
"""
struct DriftSpace{T} <: OpticalElement
    R::Matrix{T}
    L::typeof(1.0u"mm")
    γ::T
end

function transfer_matrix_1st(ds::DriftSpace)
    L = ds.L
    γ = ds.γ

    R = 
    [1 L 0 0 0 0;
     0 1 0 0 0 0;
     0 0 1 L 0 0;
     0 0 0 1 0 0;
     0 0 0 0 1 L/γ^2
     0 0 0 0 0 1]
     return R
end


abstract type Multipole <: OpticalElement end

struct Dipole{T} <: Multipole 
    R::Matrix{T}
end 



"""
Quadrupole
L = the effective length of the quadrupole. 
a = the radius of the aperture.
B = the eld at the radius a.
kq^2 = (B₀ / a)(1 / (B₀ * ρ₀), where (B₀ * ρ₀) the magnetic rigidity (momentum) of the central trajectory. 
γ = relativistic factor.
"""
struct Quadrupole <: Multipole
    R::Matrix
    L::T
    a::T
    B::T
    kq::T
    γ::T
end 

function transfer_matrix_1st(qp::Type{Quadrupole})
    L = qp.L
    a = qp.a
    B = qp.B
    kq = qp.kq
    γ = qp.γ

    R = 
    kq = sqrt((B₀ / a) * (1 / (B₀ * ρ₀)))
    [cos(kq * L)          1/kq * sin(kq * L)    0                    0                     0   0;
     -kq * sin(kq * L)    cos(kq * L)           0                    0                     0   0;
     0                    0                     cosh(kq * L)         1/kq * sinh(kq * L)   0   0;
     0                    0                     kq * sinh(kq * L)    cosh(kq * L)          0   0;
     0                    0                     0                    0                     1   L/γ^2;
     0                    0                     0                    0                     0   1]
     return R
end



struct Hexapole <: Multipole
end 



struct Octupole <: Multipole
end 



