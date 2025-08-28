/* Simulates a Full adder on 2 bits, a and b using 2 half adders and an OR gate
 * 
 * Author: Kieran Chafin
 */

public class Sim2_FullAdder {

    // inputs
    public RussWire a, b, carryIn;

    // outputs
    public RussWire sum, carryOut;

    // full adder logical componenets
    public Sim2_HalfAdder hAdd1, hAdd2;
    public OR or;

    public void execute() {
        /*
         * the execute class uses both half adders to set the sum,
         * and an OR gate for the carryOut
         */
        
        // half add a and b
        hAdd1.a.set(a.get());
        hAdd1.b.set(b.get());
        hAdd1.execute();

        // half add hAdd1 and carryIn
        hAdd2.a.set(hAdd1.sum.get());
        hAdd2.b.set(carryIn.get());
        hAdd2.execute();

        // set sum
        sum.set(hAdd2.sum.get());

        // or hAdd1 carry and hAdd2 carry
        or.a.set(hAdd1.carry.get());
        or.b.set(hAdd2.carry.get());
        or.execute();

        // set carryOut
        carryOut.set(or.out.get());
    }

    public Sim2_FullAdder() {
        /*
         * Constructors for Instantiating RussWires and gates
         */
        a = new RussWire();
        b = new RussWire();
        carryIn = new RussWire();
        sum = new RussWire();
        carryOut = new RussWire();
        hAdd1 = new Sim2_HalfAdder();
        hAdd2 = new Sim2_HalfAdder();
        or = new OR();
    }
}