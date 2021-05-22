//
// update obstacle 
// ----------------
// By: Henry Fielding
// For: University of Leeds
// Date: 13th May 2021
//
// Short Description
// -----------------
// This module is designed to update the position and variation (goomba/bulletbill) of the 
// obstacle based on the gamegameSpeed and a psuedo-random number from the random number ROM module

module UpdateObstacle (
	// declare ports
	input				update,
	input				reset,
	input	[ 8:0]	gameSpeed,
	input	[ 6:0]	randomSeed,
	
	output reg	[ 7:0]	xObstacle,
	output reg	[ 8:0]	yObstacle,
	output reg	[ 3:0]	IdObstacle,
	output reg				passed
);

//
// declare local wires and registers
//
reg	[6:0]	ROMAddr;
wire			randomNumber;

//
// instantiate modules
//
// ROM module containing list of pre-generated psuedorandom numbers in range 0-1
RandomNumbers	ROM (
	// define port connections
	.clock	(update			),
	.address	(ROMAddr			),
	.q			(randomNumber	)
);

//
// Declare statemachine registers and parameters
//
reg	[3:0]	state							= 4'd0;
localparam	RESET_OBSTACLE_STATE		= 4'd0;
localparam	UPDATE_OBSTACLE_STATE	= 4'd1;
localparam	SET_SEED_STATE				= 4'd2;

//
// define module logic
//
always @(posedge update or posedge reset) begin
	if (reset) begin
		xObstacle	<= 8'd63;
		yObstacle	<= 9'd419;
		IdObstacle	<= 4'd8;
		passed		<= 1'd0;
		state			<= SET_SEED_STATE;
	end else begin
		case (state)
			// when module first initialised reset the intial ROMaddress based 
			// on the random seed input
			SET_SEED_STATE : begin
				ROMAddr	<= randomSeed;
				state		<= RESET_OBSTACLE_STATE;
			end
			
			// reset obstacle position to the right of screen and randomly set
			// high or low deployment
			RESET_OBSTACLE_STATE : begin
				passed	<= 1'd0;
				yObstacle<= 9'd419;
				
				// if random = 1 deploy obstacle high, else deploy in low position
				if (randomNumber) begin
					xObstacle	<= 8'd110;
					IdObstacle	<= 4'd8;
				end else begin
					xObstacle	<= 8'd63;
					IdObstacle	<= 4'd6;
				end
				
				ROMAddr	<= ROMAddr + 7'd1;			// increment to next psuedorandom number
				state		<= UPDATE_OBSTACLE_STATE;
			end
			
			// gradually move the obstacle leftward across the screen at a 
			// rate determinend by the game gameSpeed
			UPDATE_OBSTACLE_STATE : begin
				passed		<= 1'd0;
				yObstacle	<= yObstacle - gameSpeed;
				update_obstacle_animation();
				
				// if obstacle has reached end of screen reset
				if (yObstacle <= (36 + (2 * gameSpeed))) begin
					state		<= RESET_OBSTACLE_STATE;
					passed	<= 1'd1;
				end
			end
		endcase
	end
end

//
// define statemachine tasks
//
// updates the IdObstacle to next Id in the animation
task update_obstacle_animation ();
	if (IdObstacle == 6) begin
		IdObstacle	<= 7;
	end else if (IdObstacle == 7) begin
		IdObstacle	<= 6;
	end else begin
		IdObstacle	<= 8;
	end
endtask

endmodule
