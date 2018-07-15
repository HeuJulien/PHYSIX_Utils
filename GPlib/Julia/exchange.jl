include("contactmatrix.jl")


function getMax(x)
    size_x=size(x)[1]
    max=x[1]
    for i=2:size_x
        if x[i] > max
            max=x[i]
        end
    end
    return max
end
function getMin(x)
    min=x[1]
    size_x=size(x)[1]
    for i=2:size_x
        if min > x[i]
            min=x[i]
        end
    end
    return min
end
function sortmatrixwithindex( x )
    sizex=size(x)[1]
    indexes=zeros(sizex)
    for i=1:sizex
        indexes[i]=i
    end
    for i=1:sizex
        for j=i:sizex
            if x[i] > x[j]
                stock=x[i]
                stock2=indexes[i]
                x[i]=x[j]
                indexes[i]=indexes[j]
                x[j]=stock
                indexes[j]=stock2
            end
        end
    end
    return x,indexes
end



func="PBE-MT"
temperature=3000
volume=[8.82,9.0,9.05,9.1,9.15,9.2,9.25,9.3,9.35,9.375,9.4,9.5,9.8]


T=temperature
for V in volume

    folder=string("/media/moogmt/Stock/CO2/AIMD/Liquid/",func,"/",V,"/",T,"K/")
    #folder=string("/home/moogmt/CO2/CO2_AIMD/",V,"/",T,"K/")
    file_in=string(folder,"TRAJEC_wrapped.xyz")
    #==========================================================================#

    #================#
    # Sim parameters
    #==========================================================================#
    stride_sim=5
    fs2ps=0.001
    time_sim=0.5 # in fs
    unit=time_sim*fs2ps*stride_sim# in ps
    stride_analysis=1
    start_time=5
    start_step=Int(start_time/(unit*stride_sim))
    nbC=32
    nbO=64
    cut_off=1.6
    #==========================================================================#

    #=====================#
    # Reading trajectory
    #==========================================================================#
    atoms = filexyz.read( file_in, stride_analysis, start_step )
    cell=cell_mod.Cell_param( V, V, V )
    #==========================================================================#

    #==============================================#
    nb_steps=size(atoms)[1]
    nb_atoms=size(atoms[1].names)[1]
    #==============================================#

    #==================#
    # Aggregating Data
    #==========================================================================#
    lifes=[]
    oxygens2=[]
    carbons2=[]
    starts=[]
    ends=[]
    end_at_endsim=[]
    count=0
    for oxygen=1:nbO
        print("Progress - Oxygen: ",oxygen/nbO*100,"%\n")
        neighbours=zeros(nb_steps,2)
        indexs=zeros(nb_steps,2)
        for step=1:nb_steps
            distances=zeros(32)
            for carbon=1:32
                distances[carbon] = cell_mod.distance(atoms[step],cell,carbon,oxygen+nbC)
            end
            distances, indexes = sortmatrixwithindex(distances)
            for i=1:2
                if distances[i] < cut_off
                    neighbours[step,i] = 1
                end
            end
            indexs[step,:]=[indexes[1], indexes[2]]
        end
        count=0
        list_index=[]
        list_start=[]
        list_end=[]
        # Aggregate
        for neigh=1:2
            for i=1:nb_steps
                if neighbours[i,1] > 0
                    neighbours[i,1] = 0
                    print("Progress - Oxygen: ",oxygen/nbO*100," ")
                    print("Counting Life:",i/nb_steps*100,"%\n")
                    j=i+1
                    push!(list_index,indexs[i,neigh])
                    push!(list_start,i)
                    while j <= nb_steps
                        if indexs[j,1] == indexs[i,neigh] && neighbours[j,1] > 0
                            neighbours[j,1] = 0
                            j+=1
                        elseif indexs[j,2] == indexs[i,neigh] && neighbours[j,1] > 0
                            neighbours[j,2] = 0
                            j+=1
                        else
                            break
                        end
                    end
                    push!(list_end,j)
                end
            end
        end
        used=zeros(size(list_index)[1])
        for i=1:size(list_index)[1]
            if used[i] == 0
                used[i] = 1
                for j=i+1:size(list_index)[1]
                    if used[j] == 0
                        if list_index[i] == list_index[j]
                            list_end[i]=list_end[j]
                            used[j]=1
                        end
                    end
                end
                push!(lifes,list_end[i]-list_start[i])
                push!(oxygens2,oxygen)
                push!(carbons2,list_index[i])
                push!(starts,list_start[i])
                push!(ends,list_end[i])
                x=0
                if list_end[i] == nb_steps+1
                    x=1
                end
                push!(end_at_endsim,x)
            end
        end
    end
    #==========================================================================#

    #==============================================#
    # Looking at creation and destructions of bonds
    #==========================================================================#
    total_sim_time = nb_steps*unit
    time_window=[0.5,1,2] # Time window in picosecondes
    for tw in time_window
        nb_window=Int(trunc(total_sim_time/tw)+1)
        hist1d_loss=zeros(nb_window)
        for end_time in ends
            for win=1:nb_window
                if end_time*unit > (win-0.5)*tw && end_time*unit < (win+0.5)*tw
                    hist1d_loss[win] += 1
                end
            end
        end
        file=open(string("/home/moogmt/LossTime-",tw,"-",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
        for i=1:nb_window
            write(file,string(unit+i*tw," ",hist1d_loss[i],"\n"))
        end
        hist1d_gain=zeros(nb_window)
        for gain_time in starts
            for win=1:nb_window
                if gain_time*unit > (win-0.5)*tw && gain_time*unit < (win+0.5)*tw
                    hist1d_gain[win] += 1
                end
            end
        end
        file=open(string("/home/moogmt/LossTime-",tw,"-",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
        for i=1:nb_window
            write(file,string(i*tw," ",hist1d_gain[i],"\n"))
        end
        close(file)
    end
    #==========================================================================#

    #============================#
    # Counting actual exchange
    #==========================================================================#
    count=0
    exchanges=[]
    nb_bonds=size(ends)[1]
    for i=1:nb_bonds
        for j=i:nb_bonds
            if oxygens2[i] == oxygens2[j] && carbons2[i] != carbons2[j]
                if ends[i]-starts[j] < 10
                    count += 1
                    push!(exchange,ends[j])
                end
            end
        end
    end
    file=open(string("/home/moogmt/ExchangeCounterTime",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    for i=1:size(exchanges)[1]
        write(file,string(exchange[i],"\n"))
    end
    close(file)
    file=open(string("/home/moogmt/ExchangeCounterTotal",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    write(file,string(count,"\n"))
    close(file)
    total_sim_time = nb_steps*unit
    time_window=[0.5,1,2] # Time window in picosecondes
    for tw in time_window
        nb_window=Int(trunc(total_sim_time/tw)+1)
        hist=zeros(nb_window)
        for i=1:nb_window
            for j=1:size(exchanges)[1]
                if end_time*unit > (i-0.5)*tw && end_time*unit < (i+0.5)*tw
                    hist[i] += 1
                end
            end
        end
    end
    file=open(string("/home/moogmt/ExchangeHist",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    for i=1:size(hist)[1]
        write(file,string(i*tw," ",hist[i],"\n"))
    end
    close(file)
    file=open(string("/home/moogmt/ExchangeHist",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    write(file,string(size(ends)[1]-count,"\n"))
    close(file)
    #==========================================================================#

    #=============================#
    # Priting summary of all data
    #==========================================================================#
    file=open(string("/home/moogmt/ExchangeGen",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    for i=1:size(oxygens2)[1]
        print(string("O:",oxygens2[i]," C:",carbons2[i]," Life:",lifes[i]," or ",lifes[i]*unit," ps Start at step: ",starts[i]+start_step," Ends at: ",ends[i]," Last Till End:",end_at_endsim[i],"\n"))
        write(file,string(oxygens2[i]," ",carbons2[i]," ",lifes[i]," ",lifes[i]*unit," ",starts[i]+start_step," ",ends[i]," ",end_at_endsim[i],"\n"))
    end
    close(file)
    #==========================================================================#

    #==========================
    # Computing lifes of bonds
    #==========================================================================#
    max=getMax(lifes)
    min=getMin(lifes)
    nb_lifes=100
    count=0
    delta_life=(max-min)/nb_lifes
    hist1D2=zeros(nb_lifes)
    for j=1:size(lifes)[1]
        for i=1:nb_lifes
            if lifes[j] > min+delta_life*i && lifes[j] < min+delta_life*(i+1)
                hist1D2[i] += 1
                count += 1
            end
        end
    end
    hist1D2 /= count
    file=open(string("/home/moogmt/ExchangeLife-",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    for i=1:size(hist1D2)[1]
        write(file,string(i*delta_life*unit," ",hist1D2[i],"\n"))
    end
    close(file)
    #==========================================================================#

    #====================#
    # Counting remaining
    #==========================================================================#
    count=0
    for i=1:size(ends)[1]
        if ends[i]-starts[i] == nb_steps
            count += 1
        end
    end
    file=open(string("/home/moogmt/Remaining-",V,"-",T,"-",cut_off,"-",func,".dat"),"w")
    write(file,string(V," ",T," ",count,"\n"))
    close(file)
    #==========================================================================#

end