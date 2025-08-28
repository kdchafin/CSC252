/*
 * Author: Mark Norris
 * Test case for half adder with a carryOut.
 */
public class Test_05_HalfAdderCarryOut {
	// a = 1
	// b = 1
	// sum = 0
	// carryOut = 1
	public static void main(String[] args) {
		Sim2_HalfAdder adder = new Sim2_HalfAdder();
		RussWire a = new RussWire();
		a.set(true);
		RussWire b = new RussWire();
		b.set(true);
		adder.a = a;
		adder.b = b;
		adder.execute();
		System.out.print("a:"+bit(a.get())+"\n");
		System.out.print("b:"+bit(b.get())+"\n");
		System.out.print("sum:"+bit(adder.sum.get())+"\n");
		System.out.print("carryOut:"+bit(adder.carry.get())+"\n");
	}
	private static char bit(boolean b)
	{
		if (b)
			return '1';
		else
			return '0';
	}
	
}
