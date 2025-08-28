/*
 * Author: Mark Norris
 * Test case for sim2 with overflow.
 */
public class Test_01_AdderXOverflow {
	// 01010
	// 01011
	// -----
	// 10101
	// carryout = 0
	// overflow = 1
	public static void main(String[] args) {
		Sim2_AdderX adder = new Sim2_AdderX(5);
		adder.a[0].set(false);
		adder.b[0].set(true);
		adder.a[1].set(true);
		adder.b[1].set(true);
		adder.a[2].set(false);
		adder.b[2].set(false);
		adder.a[3].set(true);
		adder.b[3].set(true);
		adder.a[4].set(false);
		adder.b[4].set(false);
		adder.execute();
		System.out.print("a:01010\n");
		System.out.print("b:01011\n");
		System.out.print("Result:");
		for (int i = 4; i > -1; i--) {
			RussWire item = adder.sum[i];
			if (item.get()) {
				System.out.print("1");
			}
			else System.out.print("0");
		}
		System.out.print("\n");
		System.out.print("carryout:" + bit(adder.carryOut.get())+"\n");
		System.out.print("overflow:" + bit(adder.overflow.get())+"\n");
	}
	
	private static char bit(boolean b)
	{
		if (b)
			return '1';
		else
			return '0';
	}
	
	
}
