/* An Adderx, whiched links Full Adders together to add an entire bit string
 * 
 * Author: Kieran Chafin
 */

public class Sim2_AdderX {
    
    // integer for binary size
    public int x;

    // inputs
    public RussWire[] a, b;

    // outputs
    public RussWire[] sum;
    public RussWire overflow, carryOut;

    // gates and components
    public Sim2_FullAdder[] fAdd;
    public XOR xor;

    /*
    * Execute method uses a for loop to simulate the linking of FullAdders.
    * uses an XOR gate to set the overflow
    */
    public void execute() {
        
        // set the first itteration of the full adder
        fAdd[0].a.set(a[0].get());
        fAdd[0].b.set(b[0].get());
        fAdd[0].carryIn.set(false);
        fAdd[0].execute();
        sum[0].set(fAdd[0].sum.get());

        // simulate the next 1 to x-1 full adders
        for (int i = 1; i < x; i++) {
            fAdd[i].a.set(a[i].get());
            fAdd[i].b.set(b[i].get());
            fAdd[i].carryIn.set(fAdd[i - 1].carryOut.get());
            fAdd[i].execute();

            // set sum
            sum[i].set(fAdd[i].sum.get());
        }

        // set finl carryout
        carryOut.set(fAdd[x-1].carryOut.get());
        
        // use XOR to find the overflow
        xor.a.set(fAdd[x - 2].carryOut.get());
        xor.b.set(carryOut.get());
        xor.execute();

        // set overflow
        overflow.set(xor.out.get());
    }

    public Sim2_AdderX(int x) {
        /*
         * Instantiate the RussWires and Gates
         */
        this.x = x;

        a = new RussWire[x];
        b = new RussWire[x];
        sum = new RussWire[x];
        fAdd = new Sim2_FullAdder[x];

        carryOut = new RussWire();
        overflow = new RussWire();
        xor = new XOR();

        // instantiate x amount of these variables
        for (int i = 0; i < x; i++) {
            a[i] = new RussWire();
            b[i] = new RussWire();
            sum[i] = new RussWire();
            fAdd[i] = new Sim2_FullAdder();
        }
    }
}