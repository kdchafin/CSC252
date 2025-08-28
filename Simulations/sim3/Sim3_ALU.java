/*
 * File: Sim3_ALU
 * Author: Kieran Chafin
 * Class: CSC252
 * Purpose: This file simulates an ALU in hardware using
 *          ALU elements fron the ALUElement class 
 */

public class Sim3_ALU {

    //inputs 
	public RussWire[] aluOp, a, b;
	public RussWire bNegate;
	public int x;
    
    //output
	public RussWire[] result;

    // aluE used for each itteration of the ALU
	public Sim3_ALUElement[] aluE;
	
    /*
     * Main execute method for the ALU
     * Uses x gate so simulate all possibilities
     */
	public void execute() {

		// the first alu must be manually created as we 
        // need the carryout of alu[i-1] (line 36)
		aluE[0].aluOp[0].set(aluOp[0].get());
		aluE[0].aluOp[1].set(aluOp[1].get());
		aluE[0].aluOp[2].set(aluOp[2].get());
		aluE[0].bInvert.set(bNegate.get());
		aluE[0].a.set(a[0].get());
		aluE[0].b.set(b[0].get());
		aluE[0].carryIn.set(bNegate.get());
		aluE[0].execute_pass1();

		// now simulate 1 to (n-1) ALU passes
		for (int i = 1; i < x; i++) {
			aluE[i].aluOp[0].set(aluOp[0].get());
			aluE[i].aluOp[1].set(aluOp[1].get());
			aluE[i].aluOp[2].set(aluOp[2].get());

            // check for negation
			aluE[i].bInvert.set(bNegate.get());
			aluE[i].a.set(a[i].get());
			aluE[i].b.set(b[i].get());

            // get previous ALU's carryout value
			aluE[i].carryIn.set(aluE[i - 1].carryOut.get());
			aluE[i].less.set(false);
			aluE[i].execute_pass1();
		}

        // set the the first ALU value
		aluE[0].less.set(aluE[x - 1].addResult.get());

		// set the result for every ALU
        for (int i = 0; i < x; i++) {
			aluE[i].execute_pass2();
			result[i].set(aluE[i].result.get());
        }
	}

    /*
     * Constructor to set all reuqired variables for the ALU
     * Takes in the int representation for the ALU
     */
	public Sim3_ALU(int x) {

        // main variables for the alu
		aluOp = new RussWire[3];

        for (int i = 0; i < 3; i++) {
			aluOp[i] = new RussWire();
		}

		a = new RussWire[x];
		b = new RussWire[x];
		result = new RussWire[x];
        this.x = x; // size of alu

        aluE = new Sim3_ALUElement[x];

        // create all alu gates
        for (int i = 0; i < x; i++) {
			a[i] = new RussWire();
			b[i] = new RussWire();
			result[i] = new RussWire();
			aluE[i] = new Sim3_ALUElement();
		}

        bNegate = new RussWire();
	}
}