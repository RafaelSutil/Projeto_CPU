`timescale 1ps/1ps
module Main (	
	output logic wr, IRWrite, Dwr,
	output logic [5:0] Estado,
	output logic [63:0] PC, PCin, Ain, Aout, Bin, Bout, Alu, AluOut, Address, WriteDataReg, MemData64,
	output logic [31:0] MemData, I31_0,


	output logic [11:0] I31_20,
	output logic [2:0] I14_12,
	output logic [4:0] I11_7, I24_20, I19_15,
	output logic [6:0] I6_0, I31_25
);
logic [3:0] count;
logic clock, reset;

//nomeDoArquivo nome (.nomeDentroDoArquivo(nomeDaqui));

assign I31_25 = I31_0[31:25];
assign I31_20 = I31_0[31:20];
assign I14_12 = I31_0[14:12];

//Saidas --> Entradas
logic [63:0] ALU_A, ALU_B, MDRout, imm;
logic [2:0] ALUOpOut;


//UNIDADE DE CONTROLE
logic PCWrite, AWrite, BWrite, AluOutWrite, Zero;
logic [3:0] AluSrcA, AluSrcB, PCSource, MemtoReg, IorD;

ControlUnit ControlUnit(
	.clock(clock), .reset(reset),
	.opcode(I6_0), .funct7(I31_25), .funct3(I14_12),
	.PCWrite(PCWrite), .IorD(IorD), .MemRead(wr), .MemtoReg(MemtoReg), .IRWrite(IRWrite), .DMemReadWrite(Dwr),
	.AluSrcA(AluSrcA), .RegWrite(RegWrite), .AWrite(AWrite), .BWrite(BWrite), .AluOutWrite(AluOutWrite),
	.PCSource(PCSource), .AluSrcB(AluSrcB), .ALUOpOut(ALUOpOut), .State_out(Estado), .MDRWrite(MDRWrite),
	.Zero(Zero)
);


//MEMORIA 32
Memoria32 Memoria32(.Clk(clock), .waddress(), .raddress(Address[31:0]), .Datain(), .Dataout(MemData), .Wr(wr));

//MEMORIA 64
Memoria64 Memoria64(.raddress(AluOut), .waddress(AluOut), .Clk(clock), .Datain(Bout), .Dataout(MemData64), .Wr(Dwr));

//MDR
register MDR(.clk(clock), .reset(reset), .regWrite(MDRWrite), .DadoIn(MemData64), .DadoOut(MDRout));

/*iord*/Mux64_16 MemMux (.in0(PC), .in1(AluOut), .sel(IorD), .out(Address));
/*memtoreg*/Mux64_16 WriteDataMux (.in0(AluOut), .in1(MDRout), .in2(imm), .sel(MemtoReg), .out(WriteDataReg));
//*regdst*/Mux5_8 WriteRegisterMux (.in0(I19_15)/*rs1*/, .in1(I11_7)/*rd*/, .in2(I24_20)/*rs2*/, .sel(RegDst), .out(WriteRegister));

//MEMORIA 64


//BANCO DE REG
bancoReg bancoReg(.write(RegWrite), .clock(clock), .reset(reset), .regreader1(I19_15), .regreader2(I24_20), .regwriteaddress(I11_7), .datain(WriteDataReg), .dataout1(Ain), .dataout2(Bin));

//REGISTRADOR DE INSTRUÇOES
Instr_Reg_RISC_V InstructionRegister (.Clk(clock), .Reset(reset), .Load_ir(IRWrite), .Entrada(MemData), .Instr19_15(I19_15), .Instr24_20(I24_20), .Instr11_7(I11_7), .Instr6_0(I6_0), .Instr31_0(I31_0));

//SIGN EXTEND
//SignExtend SignExtend (.instruction(I31_0[31:20]), .imediate(imediate));
SignExtend SignExtend(.in(I31_0), .out(imm));


//ALU

register A_reg(.clk(clock), .reset(reset), .regWrite(AWrite), .DadoIn(Ain), .DadoOut(Aout));
register B_reg(.clk(clock), .reset(reset), .regWrite(BWrite), .DadoIn(Bin), .DadoOut(Bout));

/*alusourceA*/Mux64_16 ALU_A_Mux (.in0(PC), .in1(Aout), .sel(AluSrcA), .out(ALU_A));
/*alusourceB*/Mux64_16 ALU_B_Mux (.in0(Bout), .in1(64'd4), .in2(imm), .in3({32'b0, I31_0[31:0]}), .sel(AluSrcB), .out(ALU_B));

ula64 ula64 (.A(ALU_A), .B(ALU_B), .Seletor(ALUOpOut), .S(Alu), .z(Zero));

register AluOut_reg (.clk(clock), .reset(reset), .regWrite(AluOutWrite), .DadoIn(Alu), .DadoOut(AluOut));


//PC
register PC_reg(.clk(clock), .reset(reset), .regWrite(PCWrite), .DadoIn(PCin), .DadoOut(PC));


/*Pcsource*/Mux64_16 PC_mux (.in0(Alu), .in1(AluOut), .in2(imm), .sel(PCSource), .out(PCin));

initial begin
		clock = 0;
		reset = 1'b1;
		#2;
		reset = 0;
		count = 10'd1000;
		//$monitor($time, "%b %b %b %b %b %b %b %b %b %b %b %b %b", PCOutWire, PCInWire, PCWriteWire, InsMemOutWire, ALUSrcAWire, ALUSrcBWire, ALUResultWire, ALUAWire, ALUBWire, ALUFctWire);
		while(count > 0) begin
			if(clock) begin
				clock = 0;
			end
			else begin
				clock = 1'b1;
			end
		#10;
		end
		//$finish;
	end


endmodule: Main