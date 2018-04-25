include("cell.jl");

module filexyz

using atom_mod
using cell_mod

function getNbSteps{ T1 <: AbstractString }( file::T1)
  nb_step=0
  nb_atoms=0
  open( file ) do f
    while !eof(f)
      if nb_step == 0
        nb_atoms=parse(Float64,split(readline(f))[1])
      else
        readline(f)
      end
      nb_step+=1
    end
  end
  if nb_atoms != 0
    return Int(nb_step/(nb_atoms+2))
  else
    return 0
  end
end

function readFastFile{ T1 <: AbstractString }( file::T1 )
  #--------------
  # Reading file
  #----------------------
  file=open(file);
  lines=readlines(file);
  close(file);
  #------------------------

  #------------------------
  # Basic data about files
  #-----------------------------------------
  nb_atoms=parse(Int64,split(lines[1])[1])
  nb_steps=Int(size(lines)[1]/(nb_atoms+2))
  #------------------------------------------

  sim=Vector{ atom_mod.AtomList }( nb_steps )
  for step=1:nb_steps
      atom_list = atom_mod.AtomList( nb_atoms )
      for atom=1:nb_atoms
          line_nb=Int((step-1)*(nb_atoms+2)+atom+2)
          line_content=split( lines[line_nb] )
          atom_list.names[atom] = line_content[1]
          atom_list.index[atom] = atom
          for pos=1:3
              atom_list.positions[ atom, pos ] = parse( Float64, line_content[ pos+1 ] )
          end
      end
      sim[step]=atom_list
  end
  return sim
end

function write{ T1 <: IO, T2 <: atom_mod.AtomList }( file_handle::T1, atoms::T2 )

  for i=1:size( atoms.names )[1]
    Base.write( file_handle, string( atoms.names[i] , " "  ) )
    for j=1:3
      Base.write( file_handle, string( atoms.positions[i,j] , " " ) )
    end
    Base.write( file_handle, "\n" )
  end
end

function write{ T1 <: AbstractString, T2 <: atom_mod.AtomList }( file::T1, atoms::T2 )

  out=open(file,"w")

  for i=1:size(atoms.names)[1]
    Base.write(out, string( atoms.names[i]," " ) )
    for j=1:3
      Base.write(out, string( atoms.positions[i,j] , " ") )
    end
    Base.write(out,"\n")
  end

  close(out)
end

function write{ T1 <: AbstractString, T2 <: atom_mod.AtomList }( file::T1, atoms_blocks::Vector{T2} )
  f=open(file,"w")
  for atoms in atoms_blocks
    write(f,atoms)
  end
  close(file)
end

end