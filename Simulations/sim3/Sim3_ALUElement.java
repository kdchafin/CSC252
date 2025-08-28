/*
 * File: Sim3_ALUElement
 * Author: Kieran Chafin
 * Class: CSC252
 * Purpose: This file simulates an ALU Element in hardware. This
 *          is used in the ALU class to simaulate an entire ALU
 */

public class Sim3_ALUElement {
    
    public RussWire[] aluOp;
    public RussWire bInvert;
    public RussWire a,b;
    public RussWire carryIn;
    public RussWire less;

    public RussWire result;
    public RussWire addResult;
    // (If aluOp==2, then result and addResult will eventually be the same.)
    public RussWire carryOut;

    public Sim3_MUX_8by1 mux1, mux2;
    public AND and;
    public OR or;
    public XOR xor;
    public Sim2_FullAdder fullAdder;

    /*
     * Executes the first pass of the ALU element.
     */
	public void execute_pass1() {
		
        // b inversion script
		mux2.in[0].set(b.get());
		mux2.in[1].set(!b.get());
		mux2.control[0].set(bInvert.get());
		mux2.execute2();

		// (a ^ b)
		and.a.set(a.get());
		and.b.set(mux2.out.get());
		and.execute();
		
        // ( a v b)
		or.a.set(a.get());
		or.b.set(mux2.out.get());
		or.execute();

		// (a + b) unless bInvert is 1, then (a - b)
		fullAdder.a.set(a.get());
		fullAdder.b.set(mux2.out.get());
		fullAdder.carryIn.set(carryIn.get());
		fullAdder.execute();
		addResult.set(fullAdder.sum.get());
		carryOut.set(fullAdder.carryOut.get());

		// (a (+) b)
		xor.a.set(a.get());
		xor.b.set(mux2.out.get());
		xor.execute();
	}

    /*
     * The secnd pass for the ALUElement
     */
	public void execute_pass2() {

		// use mux1 on setResult
		mux1.in[0].set(and.out.get());
		mux1.in[1].set(or.out.get());
		mux1.in[2].set(fullAdder.sum.get());
		mux1.in[3].set(less.get());
		mux1.in[4].set(xor.out.get());

		// Set anything that isnt required to false
		mux1.in[5].set(false);
		mux1.in[6].set(false);
		mux1.in[7].set(false);
		mux1.control[0].set(aluOp[0].get());
		mux1.control[1].set(aluOp[1].get());
		mux1.control[2].set(aluOp[2].get());
		mux1.execute();

        // set result to the output of the mux
		result.set(mux1.out.get());
	}

    /*
     * Create required variables for the ALUElement.
     */
    public Sim3_ALUElement() {
		aluOp = new RussWire[3];
        //instantiate every bit for the aluOp
		for (int i = 0; i < 3; i++) {
			aluOp[i] = new RussWire();
		}

		bInvert = new RussWire();
		a  = new RussWire();
		b = new RussWire();
		carryIn = new RussWire();
		less = new RussWire();
		result = new RussWire();
		addResult = new RussWire();
		carryOut = new RussWire();

        //instantiate muxes
		mux1 = new Sim3_MUX_8by1();
		mux2 = new Sim3_MUX_8by1();

        //instantiate other required gates
		and = new AND();
		or = new OR();
		xor = new XOR();

        //make fullAdder from Sim2
        fullAdder = new Sim2_FullAdder();
	}
}
