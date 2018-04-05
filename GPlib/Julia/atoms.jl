module atom_mod

mutable struct Atom
    name::AbstractString
    index::Int
    position::Vector{Real}
    function Atom()
        new("",-1,[0,0,0]);
    end
end

mutable struct AtomList
    names::Vector{AbstractString}
    index::Vector{Int}
    positions::Array{Real}
    function AtomList()
        new(Vector{Real}(),Vector{Real}(),Array{Real}(0,3))
    end
    function AtomList{T1 <: Int}( nb_atoms::T1)
        new( Vector{AbstractString}(nb_atoms), Vector{Int}(nb_atoms), Array{Real}(nb_atoms,3) )
    end
end

mutable struct AtomMolList
    atom_names::Vector{AbstractString}
    atom_index::Vector{Int}
    mol_names::Vector{AbstractString}
    mol_index::Vector{Int}
    positions::Array{Real}
    function AtomMolList()
        new(Vector{AbstractString}(),Vector{Int}(),Vector{AbstractString}(),Vector{Int}(),Array{Real}(0,3))
    end
    function AtomMolList{ T1 <: Int }( nb_atoms::T1 )
        new(Vector{AbstractString}( nb_atoms ),Vector{Int}( nb_atoms ) ,Vector{AbstractString}( nb_atoms ), Vector{Int}(nb_atoms), Array{Real}(nb_atoms,3))
    end
end

function distance{ T1 <: Real, T2 <: Real }( atom1::Vector{T1}, atom2::Vector{T2} )
    dist=0
    for i=1:3
        dist+=(atom1[i]-atom2[i])^2
    end
    return sqrt(dist)
end

function distance{ T1 <: Atom, T2 <: Atom }( atom1::T1, atom2::T2 )
    dist=0
    for i=1:3
        dist += (atom1.position[i]-atom2.position[i])^2
    end
    return sqrt(dist)
end

function distance{ T1 <: AtomList, T2 <: Int, T3 <: Int}( atoms::T1, index1::T2, index2::T3 )
    dist=0
    for i=1:3
        dist += ( atoms.positions[index1,i] - atoms.positions[index2,i])^2
    end
    return sqrt(dist)
end

end
