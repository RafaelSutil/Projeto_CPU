module SignExtend(
	input logic [31:0] instruction,
	output logic [63:0] imediate);

	always_comb begin
		case(instruction[6:0])
			7'b0010011:
				if (instruction[31] == 0) begin
					imediate = {52'b0000000000000000000000000000000000000000000000000000,instruction[31:20]}; end
				else begin imediate = {52'b1111111111111111111111111111111111111111111111111111,instruction[31:20]}; end
			7'b1100111:
				if (instruction[31] == 0) begin
					imediate = {52'b0000000000000000000000000000000000000000000000000000,instruction[31:20]}; end
				else begin imediate = {52'b1111111111111111111111111111111111111111111111111111,instruction[31:20]}; end
			7'b0000011:
				if (instruction[31] == 0 | instruction[14:12] == 3'b100) begin
					imediate = {52'b0000000000000000000000000000000000000000000000000000,instruction[31:20]}; end
				else begin imediate = {52'b1111111111111111111111111111111111111111111111111111,instruction[31:20]}; end
			7'b1110011: imediate = 64'b00000000000100000000000000000000000000000000000000001110011;
			7'b0100011:
				if (instruction[31] == 0) begin
					imediate = {52'b0000000000000000000000000000000000000000000000000000,instruction[31:25], instruction[11:7]}; end
				else begin imediate = {52'b1111111111111111111111111111111111111111111111111111,instruction[31:25], instruction[11:7]}; end
			7'b1100011:
				if (instruction[30] == 0) begin
					imediate = {52'b0000000000000000000000000000000000000000000000000000,instruction[30],instruction[6], instruction[29:24], instruction[10:7]}; end
				else begin imediate = {52'b1111111111111111111111111111111111111111111111111111,instruction[30],instruction[6], instruction[29:24], instruction[10:7]}; end
			7'b0110111:
				if(instruction[31] == 0) begin
					imediate = {32'b00000000000000000000000000000000,instruction[31:12],12'd0}; end
				else begin imediate = {32'b11111111111111111111111111111111,instruction[31:12],12'd0}; end
			7'b1101111:
				if(instruction[30] == 0) begin
					imediate = {44'd0,instruction[30],instruction[18:11],instruction[19],instruction[29:20]}; end
				else begin imediate = {44'b11111111111111111111111111111111111111111111,instruction[30],instruction[18:11],instruction[19],instruction[29:20]}; end
			default: imediate = 64'd0;
		endcase
	end

endmodule 