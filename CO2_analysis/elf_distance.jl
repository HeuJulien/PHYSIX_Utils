include("atoms.jl")
include("cell.jl")
include("cubefile.jl")

step_max=1001
step_min=1
d_step=1

distance_data=[]
elf_data=[]
used=[]

for step=step_min:d_step:step_max

    #------------------------------------------------------------------------------
    atoms, cell1, ELF1 = cube_mod.readCube(string("/media/moogmt/Stock/cube_TS14_gly/ELF_shoot2_",step,".cube"))
    #---------------

end