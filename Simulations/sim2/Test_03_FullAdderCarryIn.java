/*
 * Author: Mark Norris
 * Test case for sim2 full adder carryIn.
 */
public class Test_03_FullAdderCarryIn {
	// carryIn = 1
	// a = 0
	// b = 1
	// sum = 0
	// carryOut = 1
	public static void main(String[] args) {
		Sim2_FullAdder adder = new Sim2_FullAdder();
		RussWire carryIn = new RussWire();
		carryIn.set(true);
		RussWire a = new RussWire();
		a.set(false);
		RussWire b = new RussWire();
		b.set(true);
		adder.carryIn = carryIn;
		adder.a = a;
		adder.b = b;
		adder.execute();
		System.out.print("a:"+bit(a.get())+"\n");
		System.out.print("b:"+bit(b.get())+"\n");
		System.out.print("carryIn:"+bit(carryIn.get())+"\n");
		System.out.print("sum:"+bit(adder.sum.get())+"\n");
		System.out.print("CarryOut:"+bit(adder.carryOut.get())+"\n");
		

	}
	
	private static char bit(boolean b)
	{
		if (b)
			return '1';
		else
			return '0';
	}

}
