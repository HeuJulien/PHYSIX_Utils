GPfolder=string("/home/moogmt/PHYSIX_Utils/GPlib/Julia/")

include(string(GPfolder,"contactmatrix.jl"))

# Folder for data
folder_base="/media/moogmt/Stock/CO2/AIMD/Liquid/PBE-MT/"

# Thermo data
Volumes=[8.82,9.0,9.05,9.1,9.15,9.2,9.25,9.3,9.35,9.375,9.4,9.5,9.8,10.0]
Temperatures=[2000,2500,3000]
Cut_Off=[1.75]

# Number of atoms
nbC=32
nbO=nbC*2
max_coord=5

restart=false

V=8.82
T=3000
cut_off=1.75

folder_in=string(folder_base,V,"/",T,"K/")
file=string(folder_in,"TRAJEC_wrapped.xyz")

folder_out=string(folder_in,"Data/")

traj = filexyz.readFastFile(file)
cell=cell_mod.Cell_param(V,V,V)

nb_atoms=size(traj[1].names)[1]
nb_steps=size(traj)[1]

restart=true

coord_matrix=zeros(nb_steps,nbC,2)

file_out=open(string(folder_out,"coordinance-C-",cut_off,".dat"),"w")
for step_sim=1:nb_steps

    print("Progress: ",step_sim/nb_steps*100,"%\n")
    write(file_out,string(step_sim," "))
    bond_matrix=zeros(nb_atoms,nb_atoms)
    for atom1=1:nb_atoms
        for atom2=atom1+1:nb_atoms
            if cell_mod.distance(traj[step_sim],cell,atom1,atom2) < cut_off
                bond_matrix[atom1,atom2]=1
                bond_matrix[atom2,atom1]=1
            end
        end
    end
    for carbon=1:nbC
        coord_matrix[step_sim,carbon,1]=sum(bond_matrix[carbon,1:nbC])
        coord_matrix[step_sim,carbon,2]=sum(bond_matrix[carbon,nbC+1:nbC+nbO])
        write(file_out,string(sum(bond_matrix[carbon,1:nbC])," ",sum(bond_matrix[carbon,nbC+1:nbC+nbO])," ") )
    end
    write(file_out,string("\n"))
end
close(file_out)

global cases=ones(0,1)
global count_cases=[1]

for step_sim=1:nb_steps
    print("Progress: ",step_sim/nb_steps*100,"%\n")
    global cases
    global count_cases
    for carbon=1:nbC
        global cases
        global count_cases
        if size(cases)[1] == 0
            global cases=ones(1,2)
            cases[1,1]= coord_matrix[step_sim,carbon,1]
            cases[1,2]= coord_matrix[step_sim,carbon,2]
        else
            global new=true
            if size(cases)[2] == 1
                if cases[1] == coord_matrix[step_sim,carbon,1] && cases[2] == coord_matrix[step_sim,carbon,2]
                    global count[i] += 1
                    global new=false
                end
            else
                for i=1:size(cases)[1]
                    if cases[i,1] == coord_matrix[step_sim,carbon,1] && cases[i,2] == coord_matrix[step_sim,carbon,2]
                        global count_cases[i] += 1
                        global new=false
                    end
                end
            end
            if new
                global cases=[cases; transpose(coord_matrix[step_sim,carbon,:]) ]
                push!(count_cases,1)
            end
        end
    end
end

case_matrix=zeros(Int,nb_steps,nbC)
file_out=open(string(folder_out,"cases_simple-",cut_off,".dat"),"w")
for step_sim=1:nb_steps
    print("Case affectation - Progress:",step_sim/nb_steps*100,"%\n")
    for carbon=1:nbC
        for i=1:size(cases)[1]
            if cases[i,1] == coord_matrix[step_sim,carbon,1] && cases[i,2] == coord_matrix[step_sim,carbon,2]
                case_matrix[step_sim,carbon]=i
            end
        end
        write(file_out,string(case_matrix[step_sim,carbon]," "))
    end
    write(file_out,string("\n"))
end
close(file_out)

lag_min=2
d_lag=100
lag_max=10002
case_transition=zeros(Float64,size(cases)[1],size(cases)[1],Int(trunc((lag_max-lag_min)/d_lag)))
case_transition=zeros(Float64,size(cases)[1],size(cases)[1],Int(trunc((lag_max-lag_min)/(d_lag))))
global count_lag=1
for lag=lag_min:d_lag:lag_max-1
    print("Lag Compute - Progress: ",lag/lag_max*100,"%\n")
    for carbon=1:nbC
        for step_sim=lag+1:nb_steps
            case_transition[ case_matrix[step_sim-lag,carbon], case_matrix[step_sim,carbon], count_lag ] += 1
            case_transition2[ case_matrix[step_sim-Int(trunc(lag/2)),carbon], case_matrix[step_sim,carbon], count_lag ] += 1
        end
    end
    global count_lag += 1
end


global max_case=5
file_lag=open(string(folder_out,"markovian_evolution_test.dat"),"w")
for lag=1:count_lag-1
    write(file_lag,string(lag*d_lag*0.005," "))
    for i=1:max_case
        for j=1:max_case
            # Specific i-j transition
            global p_truth=case_transition[i,j,lag]/sum(case_transition[i,:,lag])
            global p_test=0
            global p_test2=0
            for k=1:max_case
                global p_test += case_transition[i,k,lag]/sum(case_transition[i,:,lag])*case_transition[k,j,lag]/sum(case_transition[k,:,lag])
                global p_test2 += case_transition2[i,k,lag]/sum(case_transition2[i,:,lag])*case_transition2[k,j,lag]/sum(case_transition2[k,:,lag])
            end
            write(file_lag,string(p_truth," ",p_test," ",(p_test*(1-p_test))/(1+max_case+(count_cases[i]-lag)/lag)," "))
        end
    end
    write(file_lag,string("\n"))
end
close(file_lag)