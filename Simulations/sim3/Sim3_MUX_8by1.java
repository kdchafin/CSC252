/*
 * File: Sim3_ALUElement
 * Author: Kieran Chafin
 * Class: CSC252
 * Purpose: This file simulates an 8by1 MUX in hardware. This
 *          is used in the ALU Element class to help with
 *          the calculation done for an ALU element.
 */

public class Sim3_MUX_8by1 {

    public RussWire[] control, in;
    public RussWire[] and;

    public RussWire out;

    /*
     * secondary execute for 2 bits
     */
    public void execute2() {
        and[0].set(in[0].get() & !control[0].get());
        and[1].set(in[1].get() & control[0].get());

        out.set(and[0].get() | and[1].get());
    }

    /*
     * main execute for 8 bits
     */
    public void execute() {
        // all 8 and gates for all posibilities of the control
        and[0].set(in[0].get() & !control[0].get() & !control[1].get() & !control[2].get());
        and[1].set(in[1].get() & control[0].get() & !control[1].get() & !control[2].get());
        and[2].set(in[2].get() & !control[0].get() & control[1].get() & !control[2].get());
        and[3].set(in[3].get() & control[0].get() & control[1].get() & !control[2].get());
        and[4].set(in[4].get() & !control[0].get() & !control[1].get() & control[2].get());
        and[5].set(in[5].get() & control[0].get() & !control[1].get() & control[2].get());
        and[6].set(in[6].get() & !control[0].get() & control[1].get() & control[2].get());
        and[7].set(in[7].get() & control[0].get() & control[1].get() & control[2].get());

        // the Y product of all and gates
        out.set(and[0].get() | and[1].get() | and[2].get() | and[3].get() | and[4].get() |
                and[5].get() | and[6].get() | and[7].get());
    }

    /*
     * constructor that defines all necessary variables
     */
    public Sim3_MUX_8by1() {
        control = new RussWire[3];
        in = new RussWire[8];
        and = new RussWire[8];
        out = new RussWire();

        for (int a = 0; a < 3; a++) {
            control[a] = new RussWire();
        }

        for (int a = 0; a < 8; a++) {
            in[a] = new RussWire();
            and[a] = new RussWire();
        }
    }
}
