/*
 * Author: Mark Norris
 * Test case for sim2 full adder with no carryIn or carryOut.
 */
public class Test_04_FullAdderNoCarry {
	// carryIn = 0
	// a = 1
	// b = 0
	// sum = 1
	// carryOut = 0
	public static void main(String[] args) {
		Sim2_FullAdder adder = new Sim2_FullAdder();
		RussWire carryIn = new RussWire();
		carryIn.set(false);
		RussWire a = new RussWire();
		a.set(true);
		RussWire b = new RussWire();
		b.set(false);
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
