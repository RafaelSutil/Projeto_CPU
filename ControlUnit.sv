module ControlUnit (
	input logic clock, reset,
	input logic [6:0] opcode, funct7, 
    input logic [2:0] funct3,
    input logic Zero,

	output logic PCWrite, MemRead, IRWrite, RegWrite, AWrite, BWrite, AluOutWrite, MDRWrite, DMemReadWrite,
	output logic [2:0] ALUOpOut, // ,
	output logic [3:0] IorD, PCSource, AluSrcA, AluSrcB, MemtoReg,
	output logic [5:0] State_out
	
	

);

/*
    PRIMEIRA ENTREGA
    ADD,    OK
    SUB,    OK
    ADDI,   OK
    LD,     ?
    SD,     ?
    BEQ,    OK
    BNE,    OK
    LUI,    OK

*/
enum logic [5:0]{
	Fetch_Reset, Fetch_PC, Fetch_E1, Decode, // Fetch and Decode [0-3]

	Arit_Calc, Arit_Store,// Tipo R [4-5]
	AritImmRead, AritImmStore, MemComputation, MemRead_E0, MemRead_E1, MemWrite,// Tipo I [6 - 11]
	// Tipo S
	Branch,// Tipo SB
	LoadImm// Tipo U
	

}state, nextState;


enum logic [2:0]{LOAD, ADD, SUB, COMP} ALUOp;
assign ALUOpOut = ALUOp;
assign State_out = state;


always_ff @(posedge clock, posedge reset)
	if(reset) 
		state <= Fetch_PC;
	else
		state <= nextState;

always_comb
	case (state)
	

	Fetch_PC: begin
	    
	   
            PCWrite = 0;
            MemRead = 1; // read
            IRWrite = 0;
            RegWrite = 0;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 1;
            DMemReadWrite = 0;


            IorD = 0; // PC
            MemtoReg = 4'bxxxx;
            PCSource = 0; // ALU


            AluSrcA = 0; // PC
            AluSrcB = 1; // 4
            ALUOp = LOAD;



            nextState = Fetch_E1;
	end

	Fetch_E1: begin //espera 1

            PCWrite = 1;
            MemRead = 0;
            IRWrite = 1;
            RegWrite = 0;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 1;
            DMemReadWrite = 0;


            IorD = 0; // PC
            MemtoReg = 4'bxxxx;
            PCSource = 0; // ALU


            AluSrcA = 0; // PC
            AluSrcB = 1; // 4
            ALUOp = ADD;


            nextState = Decode;


	end

	Decode: begin
            PCWrite = 0;
            MemRead = 0;
            IRWrite = 0;
            RegWrite = 0;
            AWrite = 1;
            BWrite = 1;
            AluOutWrite = 1; // PC + branch address << 2
            MDRWrite = 0;
            DMemReadWrite = 0;


            IorD = 0; // PC
            MemtoReg = 4'bxxxx;
            PCSource = 0; // ALU


            AluSrcA = 0; // PC
            AluSrcB = 3; // branch address << 2 

            ALUOp = ADD;


            case (opcode)
            	7'b0110011:begin //arit
            		nextState = Arit_Calc;
            	end

            	7'b0010011:begin //addi
            		nextState = AritImmRead;
            	end

            	7'b0000011, 7'b0100011:begin //ld, sd
                    nextState = MemComputation;
            	end

                7'b0110111: begin //lui
                    nextState = LoadImm;
                end

            	7'b1100011, 7'b1100111:begin //beq, bne
            		nextState = Branch;
            	end

           
            endcase
        end

    Arit_Calc: begin
        PCWrite = 0;
        MemRead = 0;
        IRWrite = 0;
        RegWrite = 0;
        AWrite = 0;
        BWrite = 0;
        AluOutWrite = 1;
        MDRWrite = 1'bx;
        DMemReadWrite = 0;



        IorD = 0;
        MemtoReg = 4'bxxxx;
        PCSource = 0;

        AluSrcA = 1;
        AluSrcB = 0;


        case (funct7)
           //add
           	7'b0000000:begin
            	ALUOp = ADD;
            end

            //sub
            7'b0100000:begin
            	ALUOp = SUB;
            end

            default : begin
            	ALUOp = LOAD;
            end
        endcase  
		nextState =Arit_Store;
    	
    end

    Arit_Store: begin
        PCWrite = 0;
        MemRead = 1'bx;
        IRWrite = 0;
        RegWrite = 1;
        AWrite = 0;
        BWrite = 0;
        AluOutWrite = 0;
        MDRWrite = 1'bx;
        DMemReadWrite = 0;



        IorD = 0;
        PCSource = 0;


        AluSrcA = 1;
        AluSrcB = 0;

        ALUOp = COMP;

        MemtoReg = 0;


		nextState = Fetch_PC;
    end

    AritImmRead: begin
        PCWrite = 0;
        MemRead = 1'bx;
        IRWrite = 0;
        RegWrite = 0;
        AWrite = 0;
        BWrite = 0;
        AluOutWrite = 1;
        MDRWrite = 1'bx;
        DMemReadWrite = 0;

        IorD = 0;
        MemtoReg = 4'bxxxx;
        PCSource = 0;

        AluSrcA = 1;
        AluSrcB = 2;

        case (funct3)
            //  addi
            3'b000:
                ALUOp = ADD;

        default:
            ALUOp = LOAD;
        endcase

         nextState = AritImmStore;

    end

        AritImmStore: begin
            PCWrite = 0;
            MemRead = 1'bx;
            IRWrite = 0;
            RegWrite = 1;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 0;
            DMemReadWrite = 0;

            IorD = 0;
            PCSource = 0;

            AluSrcA = 1;
            AluSrcB = 2;


            MemtoReg = 0;


            ALUOp = COMP;

            nextState = Fetch_PC;
        end

        MemComputation: begin
            PCWrite = 0;
            MemRead = 1'bx;
            IRWrite = 0;
            RegWrite = 0;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 1;
            MDRWrite = 1'bx;
            DMemReadWrite = 0;


            IorD = 0;
            MemtoReg = 4'bxxxx;
            PCSource = 0;

            AluSrcA = 1;
            AluSrcB = 2;

            ALUOp = ADD;

            if(opcode == 7'b0100011)//sd
                nextState = MemWrite;
            else
                nextState = MemRead_E0;//ld    
        end


        MemRead_E0: begin
            PCWrite = 0;
            MemRead = 1'bx;
            IRWrite = 0;
            RegWrite = 0;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 1; //escrita no mdr
            DMemReadWrite = 0; //leitura da memoria

            IorD = 1;
            MemtoReg = 1;
            PCSource = 0;


            AluSrcA = 1;
            AluSrcB = 0;

            ALUOp = ADD;


            nextState = MemRead_E1;
        end

        MemRead_E1: begin
            PCWrite = 0;
            MemRead = 0;
            IRWrite = 0;
            RegWrite = 1;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 1;
            DMemReadWrite = 0;


            IorD = 1;
            MemtoReg = 1;
            PCSource = 0;


            AluSrcA = 1;
            AluSrcB = 0;

            ALUOp = ADD;


            nextState = Fetch_PC;
        end


        MemWrite: begin
            PCWrite = 0;
            MemRead = 0;
            IRWrite = 0;
            RegWrite = 0;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 1;
            DMemReadWrite = 1; //escrita na memoria

            IorD = 1;
            MemtoReg = 1;
            PCSource = 0;

            AluSrcA = 1;
            AluSrcB = 0;

            ALUOp = ADD;


            nextState = Fetch_PC;
        end

        LoadImm: begin
            PCWrite = 0;
            MemRead = 1'bx;
            IRWrite = 0;
            RegWrite = 1;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 1'bx;
            DMemReadWrite = 0;


            IorD = 1'bx;
            MemtoReg = 2;
            PCSource = 0;


            AluSrcA = 1'bx;
            AluSrcB = 2'bxx;


            nextState = Fetch_PC;
        end

        Branch: begin
            MemRead = 0;
            IRWrite = 0;
            RegWrite = 0;
            AWrite = 0;
            BWrite = 0;
            AluOutWrite = 0;
            MDRWrite = 0;
            DMemReadWrite = 0;

            IorD = 0;
            MemtoReg = 2;

            AluSrcA = 1;
            AluSrcB = 0;

            ALUOp = SUB;


            if (opcode == 7'b1100011) begin // beq
                if (Zero == 1) begin
                    PCSource = 2;
                    PCWrite = 1;
                end
                else begin
                    PCSource = 0;
                    PCWrite = 0;
                end
            end
            else begin // bne
                if (Zero != 1) begin
                    PCSource = 2;
                    PCWrite = 1;
                end
                else begin
                    PCSource = 0;
                    PCWrite = 0;
                end
            end

            nextState = Fetch_PC;
        end

	endcase
endmodule: ControlUnit