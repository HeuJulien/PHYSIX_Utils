#ifndef ATOMS_H
#define ATOMS_H

#include <fstream>
#include <iterator>
#include <iostream>
#include <vector>
#include <string>
#include <stdio.h>  
#include <stdlib.h>    
#include <math.h>

//======
// ATOM
//==============================
struct Atom
{
  std::string name;    // name
  double x, y, z; // position
  int index;      // index
};
//==============================

//==========
// MOLECULE
//=============================================
struct Molecule
{
  std::string name;        // Name of molecule
  std::vector<Atom> atoms; // Atoms
};
//=============================================

//===========
// TYPES LUT
//=============================================
struct typeLUT
{
  std::string type_name;
  int type_index;
  std::vector<int> atom_index;
};
struct listType
{
  std::vector<typeLUT> type_LUT;
};
//=============================================

//===========
// Distances
//=============================================================================================
double distanceAtoms(Atom i, Atom j);
//=============================================================================================

//=====
// LUT
//=============================================================================================
bool testType ( typeLUT lut , std::string specie );
bool testType ( typeLUT lut , int index );
bool typeExists ( std::vector<typeLUT> list , std::string specie );
bool typeExists( std::vector<typeLUT> list , int index );
//=============================================================================================

//=======
// MOVE 
//=============================================================================================
std::vector<Atom> compressAtoms( std::vector<Atom> atoms, double frac_a , double frac_b , double frac_c );
//=============================================================================================

//=====
// IO
//=============================================================================================
//-------
// File
//-----------------------------------------------------------------------------------------
// -> Write
//-----------------------------------------------------------------------------------------
void writePositions( std::ofstream & file , std::vector<Atom> atoms, std::string specie );
//-----------------------------------------------------------------------------------------
// -> Read
//-----------------------------------------------------------------------------------------
//----------
// Console
//-----------------------------------------------------------------------------------------
void writePositions( std::ofstream & file , std::vector<Atom> atoms, std::string specie );
//=============================================================================================

#endif 
