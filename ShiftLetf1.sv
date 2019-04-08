module ShiftLeft1 (input logic [63:0] in,
                   output logic [63:0] out);

assign out[63:2] = in[61:0];
assign out[0] = 0;

endmodule: ShiftLeft1