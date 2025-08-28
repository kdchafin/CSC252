/*
 * Author: Kieran Chafin
 * Date: 4/15/2025
 * Description: This file contains the implementation of a CPU instruction set
 * that can be used to simulate the execution of MIPS assembly code.
 * The CPU has a 32-bit instruction set, 32 32-bit registers, and a 32-bit
 * memory array. The CPU can execute the following instructions:
 * - add, addu, sub, subu, and, or, xor, slt, addi, addiu, slti, lw, sw, beq, j
 */

public class Sim5 {

	/*
	 * extracts the fields from an instruction. The fields are placed in the
	 * instructionFields object.
	 */
	public static void extractInstructionFields(int instruction, InstructionFields fields) {
		// Extract fields from the instruction
		fields.opcode = (instruction >>> 26) & 0x3F;
		fields.rs = (instruction >>> 21) & 0x1F;
		fields.rt = (instruction >>> 16) & 0x1F;
		fields.rd = (instruction >>> 11) & 0x1F;
		fields.shamt = (instruction >>> 6) & 0x1F;
		fields.funct = instruction & 0x3F;
		fields.imm16 = instruction & 0xFFFF;
		fields.imm32 = signExtend16to32(fields.imm16);
		fields.address = instruction & 0x3FFFFFF;
	}
	
	/*
	 * executes the MEM phase, filling in the MEM/WB pipeline register.
	 * handles memory read/write operations and data forwarding.
	 */
	static void execute_MEM(EX_MEM in, MEM_WB old_memWb, int[] mem, MEM_WB new_memwb) {
		// IF memRead is 1 then get the data at the specific memory address.
		if (in.memRead == 1) {
			new_memwb.memResult = mem[in.aluResult / 4];
		} else {
			// If memWrite is 1 write the specified data to memory
			if (in.memWrite == 1) {
				if (old_memWb.writeReg == in.rt && old_memWb.memToReg == 1 && old_memWb.regWrite == 1) {
					// Get memResult if load word was previously called
					mem[in.aluResult / 4] = old_memWb.memResult;
					// Get aluResult from write back phase if forwarding is necessary
				} else if (old_memWb.writeReg == in.rt && old_memWb.memToReg == 0 && old_memWb.regWrite == 1) {
					mem[in.aluResult / 4] = old_memWb.aluResult;
				} else {
					mem[in.aluResult / 4] = in.rtVal;
				}
			}
			new_memwb.memResult = 0;
		}
		// Pass on other control bits
		new_memwb.regWrite = in.regWrite;
		new_memwb.memToReg = in.memToReg;
		new_memwb.aluResult = in.aluResult;
		new_memwb.writeReg = in.writeReg;
	}
	
	/*
	 * returns the value for ALU input 1 in the EX phase.
	 * handles data forwarding from MEM/WB if necessary.
	 */
	public static int EX_getALUinput1(ID_EX in, EX_MEM old_exMem, MEM_WB old_memWb) {
		// Forwarding from previous instruction
		if (old_exMem.regWrite == 1 && old_exMem.writeReg == in.rs) {
			return old_exMem.aluResult;
		}
		// Forwarding from instruction two cycles ago
		if (old_memWb.regWrite == 1 && old_memWb.writeReg == in.rs) {
			if (old_memWb.memToReg == 1) {
				return old_memWb.memResult;
			}
			return old_memWb.aluResult;
		}
		return in.rsVal;
	}

	/*
	 * returns the value for ALU input 2 in the EX phase.
	 * handles data forwarding from MEM/WB if necessary.
	 */
	public static int EX_getALUinput2(ID_EX in, EX_MEM old_exMem, MEM_WB old_memWb) {
		// Forwarding from the previous instruction
		if (old_exMem.regWrite == 1 && old_exMem.writeReg == in.rt && in.ALUsrc == 0) {
			return old_exMem.aluResult;
		}
		// Forwarding from the instruction two cycles ahead
		if (old_memWb.regWrite == 1 && old_memWb.writeReg == in.rt && in.ALUsrc == 0) {
			if (old_memWb.memToReg == 1) {
				return old_memWb.memResult;
			}
			return old_memWb.aluResult;
		}
		// Determining if using rt or immediate fields
		if (in.ALUsrc == 0) {
			return in.rtVal;
		// Zero extending for andi and ori
		} else if (in.ALUsrc == 2) {
			return in.imm16 & 0x0000FFFF;
		}
		return in.imm32;
	}

	/*
	 * core of the EX phase.
	 * executes the ALU operation and updates the EX/MEM pipeline register.
	 */
	public static void execute_EX(ID_EX in, int input1, int input2, EX_MEM new_exMem) {
		// AND
		if (in.ALU.op == 0) {
			new_exMem.aluResult = (input1 & input2);
		// OR
		} else if (in.ALU.op == 1) {
			if (in.ALU.bNegate == 0) {
				new_exMem.aluResult = (input1 | input2);
			// NOR
			} else {
				new_exMem.aluResult = ~(input1 | input2);
			}
		// ADDER
		} else if (in.ALU.op == 2) {
			// Adding
			if (in.ALU.bNegate == 0) {
				new_exMem.aluResult = (input1 + input2);
			// Subtracting
			} else {
				new_exMem.aluResult = (input1 - input2);
			}
		// LESS
		} else if (in.ALU.op == 3) {
			// return 0 if input1 is greater than or equal to input2
			if (input1 >= input2) {
				new_exMem.aluResult = 0;
			// Otherwise return 1
			} else {
				new_exMem.aluResult = 1;
			}
		// XOR
		} else if (in.ALU.op == 4) {
			new_exMem.aluResult = (input1 ^ input2);
		// NOP
		} else if (in.ALU.op == 5) {
			new_exMem.aluResult = 0;
		// Shifting bits for LUI
		} else if (in.ALU.op == 6) {
			new_exMem.aluResult = in.imm16 << 16;
		}
		// Determine zero output
		if (new_exMem.aluResult == 0) {
			new_exMem.extra1 = 1;
		} else {
			new_exMem.extra1 = 0;
		}
		// Pass on the rest of the control bits
		new_exMem.memRead = in.memRead;
		new_exMem.memToReg = in.memToReg;
		new_exMem.memWrite = in.memWrite;
		new_exMem.regWrite = in.regWrite;
		new_exMem.rt = in.rt;
		new_exMem.rtVal = in.rtVal;
		// Determine which register is being written to
		if (in.regDst == 1) {
			new_exMem.writeReg = in.rd;
		} else {
			new_exMem.writeReg = in.rt;
		}
	}

	/*
	 * determines if a stall is needed in the ID phase.
	 * checks for data hazards and control hazards.
	 */
	public static int IDtoIF_get_stall(InstructionFields fields, ID_EX old_idex, EX_MEM old_exmem) {
		// Checking if an R format instruction following a load word is using the register the load word loads to.
		if (fields.opcode == 0 && old_idex.memRead == 1 && (old_idex.rt == fields.rs || old_idex.rt == fields.rt)) {
			return 1;
		}
		// Same check but for I format registers
		if (fields.opcode != 0 && old_idex.memRead == 1 && old_idex.rt == fields.rs) {
			return 1;
		}
		// Checking if the instruction two cycles ago has write register in common with the instruction one cycle after it.
		if (old_exmem.regWrite == 1 && (old_exmem.writeReg != old_idex.rd && old_exmem.writeReg != old_idex.rt) 
				&& (old_exmem.writeReg == fields.rt) && fields.opcode == 0x2B) {
			return 1;
		}
		// Checking if current instruction is a store word and if its storing registers are modified
		// by the instruction two cycles ahead of it.
		if (fields.opcode == 0x2B) {
			if (old_exmem.regWrite == 1 && old_exmem.writeReg == fields.rt) {
				// R format
				if (old_idex.regDst == 1 && old_idex.regWrite == 1) {
					if (old_idex.rd != old_exmem.writeReg) {
						return 1;
					}
				// I format
				} else if (old_idex.regDst == 0 && old_idex.regWrite == 1) {
					if (old_idex.rt != old_exmem.writeReg) {
						return 1;
					}
				}
			}
		}
		return 0;
	}

	/*
	 * determines the type of branch instruction.
	 * returns 1 for conditional branches (BEQ, BNE), 2 for unconditional jumps (J, JAL), and 0 for others.
	 */
	public static int IDtoIF_get_branchControl(InstructionFields fields, int rsVal, int rtVal) {
		// Checking for branch statements
		if ((fields.opcode == 0x4 && rsVal == rtVal) || (fields.opcode == 0x5 && rsVal != rtVal)) {
			return 1;
		}
		// Checking for jump statements
		if (fields.opcode == 0x2) {
			return 2;
		}
		return 0;
	}

	/*
	 * calculates the branch address for conditional branches (BEQ, BNE).
	 * uses the PC+4 value and the immediate value from the instruction.
	 */
	public static int calc_branchAddr(int pcPlus4, InstructionFields fields) {
        return pcPlus4 + (fields.imm32 << 2);
    }

	/*
	 * calculates the jump address for unconditional branches (J, JAL).
	 */
	public static int calc_jumpAddr(int oldPC, InstructionFields fields) {
		return (oldPC & 0xF0000000) | (fields.address << 2);
	}

	/*
	 * executes the ID phase, filling in the ID/EX pipeline register.
	 * handles control signals and instruction types.
	 */
	public static int execute_ID(int IDstall, InstructionFields fieldsIn, int pcPlus4, int rsVal, int rtVal, ID_EX new_idex) {
		// Initializing all control bits to 0
		new_idex.ALUsrc = 0;
		new_idex.ALU.op = 0;
		new_idex.ALU.bNegate = 0;
		new_idex.memRead = 0;
		new_idex.memWrite = 0;
		new_idex.memToReg = 0;
		new_idex.regDst = 0;
		new_idex.regWrite = 0;

		// Passing on the instruction fields if it's not a stall, branch, or jump
		if (fieldsIn.opcode != 0x2 && fieldsIn.opcode != 0x4 && fieldsIn.opcode != 0x5 && IDstall == 0) {
			new_idex.rs = fieldsIn.rs;
			new_idex.rt = fieldsIn.rt;
			new_idex.rd = fieldsIn.rd;
			new_idex.rsVal = rsVal;
			new_idex.rtVal = rtVal;
			new_idex.imm16 = fieldsIn.imm16;
			new_idex.imm32 = fieldsIn.imm32;
		} else {
			// Setting all fields to 0 if a stall, branch, or jump
			new_idex.rs = 0;
			new_idex.rt = 0;
			new_idex.rd = 0;
			new_idex.rsVal = 0;
			new_idex.rtVal = 0;
			new_idex.imm16 = 0;
			new_idex.imm32 = 0;
		}

		if (IDstall == 1) {
			pcPlus4 -= 4;
			return 1;
		}

		// R format
		if (fieldsIn.opcode == 0) {
			// nop
			if (fieldsIn.funct == 0) {
				new_idex.ALU.op = 0x5;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// add or addu
			if (fieldsIn.funct == 0x20 || fieldsIn.funct == 0x21) {
				new_idex.ALU.op = 0x2;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// sub or subu
			if (fieldsIn.funct == 0x22 || fieldsIn.funct == 0x23) {
				new_idex.ALU.op = 0x2;
				new_idex.ALU.bNegate = 1;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// and
			if (fieldsIn.funct == 0x24) {
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// or
			if (fieldsIn.funct == 0x25) {
				new_idex.ALU.op = 0x1;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// xor
			if (fieldsIn.funct == 0x26) {
				new_idex.ALU.op = 0x4;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// nor
			if (fieldsIn.funct == 0x27) {
				new_idex.ALU.op = 0x1;
				new_idex.ALU.bNegate = 1;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
			// slt
			if (fieldsIn.funct == 0x2A) {
				new_idex.ALU.op = 0x3;
				new_idex.ALU.bNegate = 1;
				new_idex.regDst = 1;
				new_idex.regWrite = 1;
				return 1;
			}
		}

		// addi or addiu
		if (fieldsIn.opcode == 0x8 || fieldsIn.opcode == 0x9) {
			new_idex.ALUsrc = 1;
			new_idex.ALU.op = 0x2;
			new_idex.regWrite = 1;
			return 1;
		}

		// slti
		if (fieldsIn.opcode == 0xA) {
			new_idex.ALUsrc = 1;
			new_idex.ALU.op = 0x3;
			new_idex.ALU.bNegate = 1;
			new_idex.regWrite = 1;
			return 1;
		}

		// lw
		if (fieldsIn.opcode == 0x23) {
			new_idex.ALUsrc = 1;
			new_idex.ALU.op = 0x2;
			new_idex.memRead = 1;
			new_idex.memToReg = 1;
			new_idex.regWrite = 1;
			return 1;
		}

		// sw
		if (fieldsIn.opcode == 0x2B) {
			new_idex.ALUsrc = 1;
			new_idex.ALU.op = 0x2;
			new_idex.memWrite = 1;
			return 1;
		}

		// beq or bne
		if (fieldsIn.opcode == 0x4 || fieldsIn.opcode == 0x5) {
			return 1;
		}

		// j
		if (fieldsIn.opcode == 0x2) {
			return 1;
		}

		// andi
		if (fieldsIn.opcode == 0xC) {
			new_idex.ALUsrc = 2;
			new_idex.regWrite = 1;
			return 1;
		}

		// ori
		if (fieldsIn.opcode == 0xD) {
			new_idex.ALUsrc = 2;
			new_idex.ALU.op = 0x1;
			new_idex.regWrite = 1;
			return 1;
		}

		// lui
		if (fieldsIn.opcode == 0xF) {
			new_idex.ALUsrc = 1;
			new_idex.ALU.op = 0x6;
			new_idex.regWrite = 1;
			return 1;
		}

		return 0;
	}

	/*
	 * sign-extends a 16-bit value to a 32-bit value.
	 * used for immediate values in instructions.
	 */
	static public int signExtend16to32(int val16) {
		if ((val16 & 0x8000) != 0)
			return val16 | 0xFFFF0000;
		else
			return val16;
	}

	/*
	 * executes the WB phase, writing back to the register file.
	 * handles data forwarding from MEM/WB if necessary.
	 */
	public static void execute_WB(MEM_WB in, int[] regs) {
		if (in.regWrite == 1) {
			if (in.memToReg == 1) {
				// Write to register from memory if load word
				regs[in.writeReg] = in.memResult;
			} else {
				// Write to register from aluResult otherwise
				regs[in.writeReg] = in.aluResult;
			}
		}
	}
}