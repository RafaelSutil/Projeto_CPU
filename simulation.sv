module simulation;
	logic clk;
	logic [31:0] ins;
	logic reset;
	logic [6:0] opcode;
	logic PCWrite, IMemRead, ALUSrcA,  ALUFct;
	logic [1:0] ALUSrcB;

	UC controller(.clk(clk), .reset(reset), .instru(ins), .opcode(opcode), .PcWrite(PCWrite), .IMemRead(IMenRead), .AluSrcA(ALUSrcA), .AluSrcB(ALUSrcB), .AluFct(ALUFct));

	initial begin
		$monitor($time,"%b %b %b %b %b", PCWrite, IMemRead, ALUSrcA, ALUSrcB, ALUFct);
		clk = 0;
		ins = 32'b00000000000000000000000000010011;
		clk = 1;
		#5 $finish;
	end

endmodule: simulation
