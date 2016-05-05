/*
 * Avalon memory-mapped peripheral for the VGA LED Emulator
 *
 * Stephen A. Edwards
 * Columbia University
 */
`include "Const.vh"

module FOREX(input logic clk,
				 input logic reset,
				 input logic [`WEIGHT_WIDTH:0] writedata,
				 input logic write,
				 input chipselect,
				 input logic [2:0] address,

				 output [4:0] frame_char, //TESTING PURPOSES ONLY
				 output logic [31:0] test, //For testing purposes only
				 output logic [31:0] test1, //For testing purposes only
				 output logic [31:0] test2, //For testing purposes only

				 output logic [7:0] VGA_R, VGA_G, VGA_B,
				 output logic VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_n,
				 output logic VGA_SYNC_n);

		enum logic [3:0] {RESET, CONTAINER} state;

		logic [`PRED_WIDTH:0] src = 0;
	  logic [`PRED_WIDTH:0] u_src;
	  logic [`PRED_WIDTH:0] u_dst;
	  logic [`WEIGHT_WIDTH:0] u_e;
		logic [5:0] frame_x, frame_y;
		//logic [4:0] frame_char;
		logic frame_we;

		logic container_done;
		logic container_reset;

		//Frame buffer(.x(frame_x), .y(frame_y), .char(frame_char), .we(frame_we), .*);
		Container container(.*);

		always_comb begin
			u_src = 0;
			u_dst = 0;
			u_e = 0;
			if (reset) ;
			else if (chipselect && write) begin
				case (address)
					 3'd0 : begin //Write new source and dest
						u_src = writedata[2 * `PRED_WIDTH + 1:`PRED_WIDTH + 1];
						u_dst = writedata[`PRED_WIDTH:0];
					 end
					 3'd1 : begin
					 	u_e = writedata;
					 end
					 default: ;
				endcase
			end
		end

		always_ff @(posedge clk) begin
			if (reset) ;
			else if (chipselect && write) begin
				case (address)
					 3'd1 : begin
					 		state <= RESET;
					 end
					 default: ;
				endcase
			end
			case(state)
				RESET: begin
					state <= CONTAINER;
					container_reset <= 1;
				end
				CONTAINER: container_reset <= 0;
				default: ;
			endcase
		end

endmodule
