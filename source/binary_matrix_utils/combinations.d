module combinations;

import std.stdio;

/** 
 * Generates all combinations of N bit numbers with K bits set to 1
 * Params:
 *   bits_allowed = The mask of bits allowed, Ex. if N=3 bits_allowed = 0b111
 *   bits_set = K
 * Returns: 
 */
ulong[] binary_combinations(ulong bits_allowed,ulong bits_set){

	ulong[] array = [];

	ulong mul = 1;
	while(bits_allowed > 0){
		if((bits_allowed & 1) == 1){
			array ~= mul;
			bits_allowed = bits_allowed >> 1;
		}
		mul = mul << 1;
	}

	ulong[][] combinations = combinations(array,bits_set);

	ulong[] returnable = [];
	foreach (ulong[] combination; combinations)
	{
		ulong t = 0;
		foreach (ulong v; combination)
		{
			t = t | v;
		}
		returnable ~= t;
	}
	return returnable;
}

private T[][] combinations(T)(T[] array, size_t k) {
    T[][] result;

    void helper(T[] currentCombination, size_t start) {
        if (currentCombination.length == k) {
            result ~= currentCombination.dup;
            return;
        }

        for (size_t i = start; i <= array.length - k + currentCombination.length; ++i) {
            helper(currentCombination ~ array[i], i + 1);
        }
    }

    helper([], 0);
    return result;
}