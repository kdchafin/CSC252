/* Simulates a Half Adder on 2 bits, a and b using an XOR gate and an AND gate
 * 
 * Author: Kieran Chafin
 */

public class Sim2_HalfAdder {
    
    // inputs
    public RussWire a, b;

    // outputs
    public RussWire sum, carry;

    // half adder logical componenets
    public XOR xor;
    public AND and;

    public void execute() {
        /*
         * execute method uses the XOR and AND gates to half add bits a and b
         */

        // xor of a and b
        xor.a.set(a.get());
        xor.b.set(b.get());
        xor.execute();
        
        // set sum
        sum.set(xor.out.get());

        // a ^ b
        and.a.set(a.get());
        and.b.set(b.get());
        and.execute();

        // set carry
        carry.set(and.out.get());
    }

    public Sim2_HalfAdder() {
        /*
         * Constructor to instantiate russwires and gates
         */

        // instantiating variables
        a = new RussWire();
        b = new RussWire();
        sum = new RussWire();
        carry = new RussWire();
        xor = new XOR();
        and = new AND();
    }
}
