/*	Title: Sim4.java
 * 	Author: Kieran Chafin
 *  Class: CSC252 Spring 2025
 * 	Purpose: This file contains the implementation of a CPU instruction set
 *  that can be used to simulate the execution of MIPS assembly code.
 *  The CPU has a 32-bit instruction set, 32 32-bit registers, and a 32-bit
 *  memory array. The CPU can execute the following instructions:
 *  - add, addu, sub, subu, and, or, xor, slt, addi, addiu, slti, lw, sw, beq, j
 * 
 *  This is Part1 of a 2 part project
 */

public class Sim4 {

    /* HELPER FUNCTIONS THAT YOU CAN CALL */
	public int signExtend16to32(int val16) {
		if ((val16 & 0x8000) != 0)
			return val16 | 0xFFFF0000;
		else
			return val16;

	}

	/*
	 * Extracts the fields from an instruction. The fields are placed in the
	 * fieldsOut object.
	 */
	public void extractInstructionFields(int instruction, InstructionFields fieldsOut) {
		// opCode 26-31
		fieldsOut.opcode = instruction >> 26 & 0x3F;
		// rs 21-25
		fieldsOut.rs = instruction >> 21 & 0x1F;
		// rt 16-20
		fieldsOut.rt = instruction >> 16 & 0x1F;
		// rd 11-15
		fieldsOut.rd = instruction >> 11 & 0x1F;
		// shamt 6-10
		fieldsOut.shamt = instruction >> 6 & 0x1F;
		// funct 0-5
		fieldsOut.funct = instruction & 0x3F;

		// imm16 0-15, imm32 sign extended to 32
		fieldsOut.imm16 = instruction & 0xFFFF;
		fieldsOut.imm32 = signExtend16to32(fieldsOut.imm16);

		// address 0-25
		fieldsOut.address = instruction & 0x3FFFFFF;
	}

	/*
	 * Fills in the control signals for the CPU based on the instruction fields.
	 * Returns 1 if the instruction is supported, 0 if not.
	 */
	public int fillCPUControl(InstructionFields fields, CPUControl controlOut) {
		switch (fields.opcode) {

			case 0x00: // r-type instr.
				controlOut.ALUsrc = 0;
				controlOut.memRead = 0;
				controlOut.memWrite = 0;
				controlOut.memToReg = 0;
				controlOut.regDst = 1;
				controlOut.regWrite = 1;
				controlOut.branch = 0;
				controlOut.jump = 0;

				switch (fields.funct) {
					case 0x20: // add
					case 0x21: // addu
						controlOut.ALU.bNegate = 0;
						controlOut.ALU.op = 0x2;
						return 1;
					case 0x22: // sub
					case 0x23: // subu
						controlOut.ALU.bNegate = 1;
						controlOut.ALU.op = 0x2;
						return 1;
					case 0x24: // and
						controlOut.ALU.bNegate = 0;
						controlOut.ALU.op = 0x0;
						return 1;
					case 0x25: // or
						controlOut.ALU.bNegate = 0;
						controlOut.ALU.op = 0x1;
						return 1;
					case 0x26: // xor
						controlOut.ALU.bNegate = 0;
						controlOut.ALU.op = 0x4;
						return 1;
					case 0x2A: // slt
						controlOut.ALU.bNegate = 1;
						controlOut.ALU.op = 0x3;
						return 1;
					default:
						controlOut.ALUsrc = 0;
						controlOut.ALU.op = 0;
						controlOut.ALU.bNegate = 0;
						controlOut.memRead = 0;
						controlOut.memWrite = 0;
						controlOut.memToReg = 0;
						controlOut.regDst = 0;
						controlOut.regWrite = 0;
						controlOut.branch = 0;
						controlOut.jump = 0;
						return 0;
				}
			case 0x08: // addi
			case 0x09: // addiu
				controlOut.ALUsrc = 1;
				controlOut.ALU.op = 0x2;
				controlOut.ALU.bNegate = 0;
				controlOut.memRead = 0;
				controlOut.memWrite = 0;
				controlOut.memToReg = 0;
				controlOut.regDst = 0;
				controlOut.regWrite = 1;
				controlOut.branch = 0;
				controlOut.jump = 0;
				return 1;
			case 0x0A: // slti
				controlOut.ALUsrc = 1;
				controlOut.ALU.op = 0x3;
				controlOut.ALU.bNegate = 1;
				controlOut.memRead = 0;
				controlOut.memWrite = 0;
				controlOut.memToReg = 0;
				controlOut.regDst = 0;
				controlOut.regWrite = 1;
				controlOut.branch = 0;
				controlOut.jump = 0;
				return 1;
			case 0x23: // lw
				controlOut.ALUsrc = 1;
				controlOut.ALU.op = 0x2;
				controlOut.ALU.bNegate = 0;
				controlOut.memRead = 1;
				controlOut.memWrite = 0;
				controlOut.memToReg = 1;
				controlOut.regDst = 0;
				controlOut.regWrite = 1;
				controlOut.branch = 0;
				controlOut.jump = 0;
				return 1;
			case 0x2B: // sw
				controlOut.ALUsrc = 1;
				controlOut.ALU.op = 0x2;
				controlOut.ALU.bNegate = 0;
				controlOut.memRead = 0;
				controlOut.memWrite = 1;
				controlOut.memToReg = 0;
				controlOut.regDst = 0;
				controlOut.regWrite = 0;
				controlOut.branch = 0;
				controlOut.jump = 0;
				return 1;
			case 0x04: // beq
				controlOut.ALUsrc = 0;
				controlOut.ALU.op = 0x2;
				controlOut.ALU.bNegate = 1;
				controlOut.memRead = 0;
				controlOut.memWrite = 0;
				controlOut.memToReg = 0;
				controlOut.regDst = 0;
				controlOut.regWrite = 0;
				controlOut.branch = 1;
				controlOut.jump = 0;
				return 1;
			case 0x02: // j
				controlOut.ALUsrc = 0;
				controlOut.ALU.op = 0;
				controlOut.ALU.bNegate = 0;
				controlOut.memRead = 0;
				controlOut.memWrite = 0;
				controlOut.memToReg = 0;
				controlOut.regDst = 0;
				controlOut.regWrite = 0;
				controlOut.branch = 0;
				controlOut.jump = 1;
				return 1;
			default:
				controlOut.ALUsrc = 0;
				controlOut.ALU.op = 0;
				controlOut.ALU.bNegate = 0;
				controlOut.memRead = 0;
				controlOut.memWrite = 0;
				controlOut.memToReg = 0;
				controlOut.regDst = 0;
				controlOut.regWrite = 0;
				controlOut.branch = 0;
				controlOut.jump = 0;
				return 0;
		}
	}
    
    // Method signatures corresponding to function prototypes in sim4.h
	public int getInstruction(int curPC, int[] instructionMemory) {
		// TODO on milestone 2: Your code goes here
        
        return 0;
	}

	public int getALUinput1(CPUControl controlIn, InstructionFields fieldsIn,
                                   int rsVal, int rtVal, int reg32, int reg33, int oldPC) {
		// TODO on milestone 2: Your code goes here
        return 0;
	}

	public int getALUinput2(CPUControl controlIn, InstructionFields fieldsIn,
                                   int rsVal, int rtVal, int reg32, int reg33, int oldPC) {
		// TODO on milestone 2: Your code goes here
        return 0;
	}

	public void executeALU(CPUControl controlIn, int input1, int input2, ALUResult aluResultOut) {
		// TODO on milestone 2: Your code goes here

	}

	public void executeMEM(CPUControl controlIn, ALUResult aluResultIn,
                                  int rsVal, int rtVal, int[] memory, MemResult resultOut) {
		// TODO on milestone 2: Your code goes here

	}

	public int getNextPC(InstructionFields fields, CPUControl controlIn, int aluZero,
                                int rsVal, int rtVal, int oldPC) {
		// TODO on milestone 2: Your code goes here
        return 0;
	}

	public void executeUpdateRegs(InstructionFields fields, CPUControl controlIn,
                                         ALUResult aluResultIn, MemResult memResultIn, int[] regs) {
		// TODO on milestone 2: Your code goes here

	}
}