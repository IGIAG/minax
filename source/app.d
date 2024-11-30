import std.stdio;
import std.format;
import std.algorithm.mutation : reverse;
void main()
{
	char[] column_names = ['A','B','C','D'];
	uint[] F = [
		0b0010,
		0b0011,
		0b0100,
		0b0101,
		0b0110,
		0b1000,
		0b1001
	];
	uint[] R = [
		0b0000,
		0b0001,
		0b0111
	];
	foreach (uint cube; F)
	{
		uint[] block_matrix = generate_block_matrix(cube,R);
		writeln(get_simple_implicant_string(cube,block_matrix,column_names));
	}
	
	
}

uint[] generate_block_matrix(uint cube,uint[] R){
	uint[] block_matrix = R.dup;
	for(int i = 0;i < block_matrix.length;i++){
		block_matrix[i] = block_matrix[i] ^ cube;
	}
	return block_matrix;
}

char[] get_simple_implicant_string(uint cube,uint[] block_matrix,char[] column_names){
	uint mask = 0;
	while (mask < 9){
		uint[] matrix = block_matrix.dup;
		//writefln("Testing mask %b",mask);
		for(int i = 0;i < matrix.length;i++){
			matrix[i] = matrix[i] & mask;
		}
		for(int i = 0;i < matrix.length;i++){
			matrix[i] = (matrix[i] > 0) ? 1 : 0;
		}
		uint sum = matrix[0];
		for(int i = 1;i < matrix.length;i++){
			sum = matrix[i] & sum;
		}
		if (sum > 0){
			writefln("Found implicant %b",mask);
			string product = "";
			uint cube_mod = cube;
			uint i = 0;
			while(mask > 0){
				uint mask_bit_value = mask & 0b1;
				if(mask_bit_value == 0){
					//product ~= '*';
				}
				else {
					//product ~= (cube_mod & 0b1) == 1 ? '1' : '0';
					product ~= (cube_mod & 0b1) == 1 ? format("%s",column_names[column_names.length - i - 1]) : format("'%s",column_names[column_names.length - i - 1]);
				}
				cube_mod = cube_mod >> 1;
				mask = mask >> 1;
				i++;
			}
			return (cast(char[])product).reverse;
		}
		mask++;
	}
	return [];
}