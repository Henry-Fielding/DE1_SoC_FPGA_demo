/*
 * Read ROMs
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 13th May 2021
 *
 * Short Description
 * -----------------
 * This module is designed to read the data stored at the given address in the selected ROM module
 *
 */

module ReadROM (
	// declare ports
	input clock,	// timing ports
	input reset,
	input ROM,		// general ports
	input ROMAddr,
	
	output reg	ROMOut,
	output reg	Ready
);

//
// Declare local registers/wires
//

//
// Instatiate modules
//

//
// Declare statemachine registers and parameters
//