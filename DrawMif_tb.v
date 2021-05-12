/*
 * Draw Mif Test bench
 * ------------------------
 * By: Henry Fielding
 * For: University of Leeds
 * Date: 12th May 2021
 *
 * Short Description
 * -----------------
 * synchronous test bench designed to autoverifiy the functionality of the DrawMif module
 *
 */

`timescale 1 ns/100 ps
// declare parameters
parameter CLOCK_FREQ = 50000000;
parameter RST_CYCLES = 5;

//declare testbench generated signals
reg clock;
reg reset;

reg	[15:0]	xOrigin;
reg	[15:0]	yOrigin;
reg	[ 7:0]	mifId;
reg				draw;


