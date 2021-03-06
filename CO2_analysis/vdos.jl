include("contactmatrix.jl")

using PyPlot

folder="/media/moogmt/Stock/CO2/AIMD/Liquid/PBE-MT/9.8/3000K/"
file_name="FTRAJECTORY"
file=string(folder,file_name)

function getNbLineFTRAJ{ T1 <: AbstractString }( file::T1 )
    nb=0
    open( file ) do f
        while ! eof(f)
            readline(f)
            nb += 1
        end
    end
    return nb
end

function autocorrelation2(x,frac)
    M=size(x)[1]
    N=Int(trunc(M*frac))
    C=zeros(N)
    for n=1:N
        for m=1:M-n
            C[n] += x[m]*x[m+n]
        end
        C[n] = C[n]/(M-n)
    end
    if C[1] > 0.
        return C/C[1]
    else
        return C
    end
end

function autocorrelation3(x,size2)
    M=size(x)[1]
    N=Int(size2)
    C=zeros(N)
    for n=1:N
        for m=1:M-n
            C[n] += x[m]*x[m+n]
        end
        C[n] = C[n]/(M-n)
    end
    if C[1] > 0.
        return C/C[1]
    else
        return C
    end
end

nb_atoms=96
lines_nb=getNbLineFTRAJ( file )
nb_steps=Int(trunc(lines_nb/nb_atoms))

velocities=zeros(nb_steps,96,3)
vnorms=zeros(nb_steps,96)

file_traj=open(file)
for i=1:nb_steps
    for k=1:96
        line=split(readline(file_traj))
        for j=1:3
            velocities[i,k,j]=parse(Float64,line[j+4])
            vnorms[i,k] += velocities[i,k,j]^2
        end
        vnorms[i,k] = sqrt(vnorms[i,k])
    end
end
close(file_traj)

using StatsBase

lags=[0]
for i=1:5000
    push!(lags,i)
end

data=StatsBase.autocor( vnorms[:,1], lags)
for k=2:nb_atoms
    data += StatsBase.autocor( vnorms[:,k], lags)
end
value = data[1]
data /= value
datafft=dct(data)
plot( data)
