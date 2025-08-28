/* Implementation of a 32-bit adder in C.
 *
 * Author: Kieran Chafin
 */
#include "sim1.h"

void execute_add(Sim1Data *obj)
{
    // Execute_add is called to execute the simulation for addition or subtraction on
    // the entered values.

    int carry;
    int b;

    // set nonNegativity flags for a and b
    obj->aNonNeg = (obj->a >= 0) ? 1 : 0;
    obj->bNonNeg = (obj->b >= 0) ? 1 : 0;

    // for subtraction, negate b, set carry to 1 
    if (obj->isSubtraction) {
        b = ~obj->b;
        carry = 1;
    }
    else {
        b = obj-> b;
        carry = 0;
    }
    //these 2 lines caused some compiler errors. I think the problem lies within the compiler itself
    //but who knows. The lines are correctly written but o well :(
    //int b = obj->isSubtraction ? ~obj->b : obj->b; // bitwise not for negation
    //int carry = obj->isSubtraction ? 1 : 0;

    obj->sum = 0;

    // addition on all 32 bits in a and b
    for (int i = 0; i < 32; i++) {
        int a_bit = (obj->a >> i) & 1;  // i'th bit of a
        int b_bit = (b >> i) & 1;      // i'th bit of b

        int sumBit = 0;

        // cases for sum and carry
        if (a_bit == 0 && b_bit == 0 && carry == 0) {
            sumBit = 0;
            carry = 0;
        } else if (a_bit == 0 && b_bit == 0 && carry == 1) {
            sumBit = 1;
            carry = 0;
        } else if (a_bit == 0 && b_bit == 1 && carry == 0) {
            sumBit = 1;
            carry = 0;
        } else if (a_bit == 0 && b_bit == 1 && carry == 1) {
            sumBit = 0;
            carry = 1;
        } else if (a_bit == 1 && b_bit == 0 && carry == 0) {
            sumBit = 1;
            carry = 0;
        } else if (a_bit == 1 && b_bit == 0 && carry == 1) {
            sumBit = 0;
            carry = 1;
        } else if (a_bit == 1 && b_bit == 1 && carry == 0) {
            sumBit = 0;
            carry = 1;
        } else if (a_bit == 1 && b_bit == 1 && carry == 1) {
            sumBit = 1;
            carry = 1;
        }
        // set bit in sum
        obj->sum |= (sumBit << i);
    }
    // set carryOut flag
    obj->carryOut = carry;

    // most significant bit for overflow check
    int aSign = (obj->a >> 31) & 1;
    int bSign = (b >> 31) & 1; // using b instead of obj->b as we want the 2's comp sign 
    int sumSign = (obj->sum >> 31) & 1;  // MSB of sum (sign bit)

    // overflow condition: if a and b have the same sign, but sum has a different sign
    obj->overflow = (aSign == bSign) && (aSign != sumSign);

    // set nonNeg flag
    obj->sumNonNeg = ((obj->sum >> 31) == 0);  // 1 if non-negative, 0 if negative
}
