GPfolder=string("/home/moogmt/PHYSIX_Utils/GPlib/Julia/")
push!(LOAD_PATH, GPfolder)

using atom_mod
using cell_mod
using cube_mod
using filexyz
using clustering
using markov
using conversion

# Folder for data
folder_base="/media/moogmt/Stock/Mathieu/CO2/AIMD/Liquid/PBE-MT/"
#folder_base="/home/moogmt/Data/CO2/CO2_AIMD/"

# Number of atoms
nbC=32
nbO=nbC*2

cut_off_bond = 1.75
max_neigh=5

min_lag=1
max_lag=50001
d_lag=2
unit=0.005

Volumes=[8.82]

V=8.82
T=3000

folder_in=string(folder_base,V,"/",T,"K/")
file=string(folder_in,"TRAJEC_wrapped.xyz")
folder_out=string(folder_in,"Data/")


print("Reading Trajectory\n")
traj=filexyz.readFastFile(file)
cell=cell_mod.Cell_param(V,V,V)

data,types,type_atoms=buildCoordinationMatrix( traj , cell , cut_off_bond, max_neigh )
nb_types=size(types)[1]

states, state_matrix, count_ = assignDataToStates( data, nb_types, type_atoms )

transitions_matrix=[transitionMatrix(states[1],state_matrix[1],nb_types,type_atoms,min_lag,max_lag,d_lag)]
transitions_matrix_CK=[chappmanKormologov( transitions_matrix[1])]

nb_states=size(states)[1]
nb_tau=size(transitions_matrix[1])[3]
# Lifetime of CO2:
# - Reduce the transition matrix to CO2 and others
# - Compute MFTP from CO2 to others -> lifetime of CO2
# - Repeat for various tau to determine whether this change significantly
file_out=open(string(folder_out,"lifetime_markov.dat"),"w")
for tau=1:nb_tau
    Base.write(file_out,string(tau*unit*d_lag," ",1/(1-transitions_matrix[1][1,1,tau]),"\n"))
end
close(file_out)
