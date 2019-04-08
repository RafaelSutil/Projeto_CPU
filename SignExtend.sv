module SignExtend(
	input logic [31:0] in,
	output logic [63:0] out);

	logic temp;

	always_comb begin
		case(in[6:0])
			7'b0000011, 7'b0010011:begin //ld, addi
				if (in[31] == 0)
					out = {52'b0, in[31:20]}; 
				else 
					out = {52'b1111111111111111111111111111111111111111111111111111, in[31:20]};
			end

			7'b0110111:begin //lui
				if (in[31] == 0)
					out = {32'b0, in[31:12], 12'b0}; 
				else 
					out = {32'b11111111111111111111111111111111, in[31:12], 12'b0};
			end

			7'b1100011, 7'b1100111:begin //beq, bne
            	if(in[31] == 0) 
            		out = {51'b0, in[31], in[7], in[30:25], in[11:8], 1'b0}; //shiftleft
            	else
            		out = {51'b1111111111111111111111111111111111111111111111111, in[31], in[7], in[30:25], in[11:8], 1'b0};//shiftleft
            	
            end

			default: out = 64'b0;
		endcase
	end

endmodule

