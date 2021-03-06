GPfolder=string("/home/moogmt/PHYSIX_Utils/GPlib/Julia/")
CO2folder=string("/home/moogmt/PHYSIX_Utils/CO2_analysis/")

include(string(CO2folder,"markovCO2.jl"))

# Folder for data
#folder_base="/media/moogmt/Stock/Mathieu/CO2/AIMD/Liquid/PBE-MT/"
folder_base="/home/moogmt/CO2/CO2_AIMD/"

# Number of atoms
nbC=32
nbO=nbC*2

T=3000
V=9.8

time_step=1.0
stride_step=5
dt=time_step*stride_step

folder_in=string(folder_base,V,"/",T,"K/")
file=string(folder_in,"TRAJEC.xyz")
folder_out=string(folder_in,"Data/")

print("Reading Trajectory\n")
traj=filexyz.readFastFile(file)
cell=cell_mod.Cell_param(V,V,V)

nb_step=size(traj)[1]
nb_atoms=size(traj[1].names)[1]

nb_step_velo=nb_step-1

# compute the velocities
velocities=zeros(nb_step_velo,nb_atoms,3)
for step=1:nb_step-1
    for atom=1:nb_atoms
        for i=1:3
            velocities[step,atom,i]=(traj[step].positions[atom,i]-traj[step+1].positions[atom,i])/dt
        end
    end
end

velo_scal=zeros(nb_step_velo,nb_atoms)
for atom=1:nb_atoms
    for step=1:nb_step_velo
        for i=1:3
            velo_scal[step,atom] += velocities[step,atom,i]*velocities[step,atom,i]
        end
    end
end

max_lag=5000
nb_step_velo=nb_step-1
# Compute the autocorrelation
autocor_v=zeros(nb_step-1,3)
for atom=1:nb_atoms
    print("Progress: ",atom/nb_atoms*100," %\n")
    autocor_loc=zeros(nb_step_velo)
    # Loop over tau
    for step_lag=1:max_lag
        for step=1:nb_step_velo-step_lag
            autocor_loc[step_lag] += velo_scal[step,atom]*velo_scal[step+step_lag,atom]
        end
        autocor_loc[step_lag] /= (nb_step-step_lag)
    end
    for i=1:nb_step_velo
        autocor_v[i] += autocor_loc[i]
    end
end
autocor_v /= nb_atoms

file_out=open(string(folder_base,"VDOS_test.dat"),"w")
for tau=1:max_lag
    write(file_out,string(tau," ",autocor_v[tau],"\n"))
end
close(file_out)

using GR
using FFTW

autocor_v=autocor_v[1:max_lag]

GR.xlabel("test")

GR.plot(autocor_v[1:500],xlim=(1,500))


GR.plot(dct(autocor_v[1:500])[1:20],"r-")
