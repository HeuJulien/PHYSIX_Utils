#include "sim.h"

Sim emptySim() {
  std::vector<Atom> atoms;
 Cell cell = { 0, 0, 0 , 0, 0, 0 };
 Sim sim = { atoms , cell};
 return sim;
}

Sim compressBox( Sim sim_set , double frac_a , double frac_b , double frac_c )
{
  sim_set.cell = compressBox( sim_set.cell , frac_a , frac_b , frac_c );
  sim_set.atoms = compressAtoms( sim_set.atoms, frac_a , frac_b , frac_c );
  return sim_set;
}