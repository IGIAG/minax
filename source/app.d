import std.stdio;
import std.format;
import std.algorithm.mutation : reverse;
import std.algorithm;
import std.array;
import std.container;
import std.range;

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
	SimpleImplicantValue[][] simple_implicants = [];
	int it = 0;
	while(F.length > 0 && it < 200){

		uint cube = F[0];
		uint[] block_matrix = generate_block_matrix(cube,R);
		SimpleImplicantValue[] cubes_simple_implicant = get_simple_implicant(cube,block_matrix,uint.max);
		simple_implicants ~= cubes_simple_implicant;
		auto F_cut = Array!uint(F);
		//writefln("For implicant %s:",cubes_simple_implicant);
		foreach (uint row; F)
		{
			if(value_matches_simple_implicant(row,cubes_simple_implicant)){
				auto range = F_cut[];
				//writefln("Would remove: %s",row);
				auto found = range.find(row);
				F_cut.linearRemove(found.take(1));
			}
		}
		F = F_cut.data;
		it++;
	}
	if(it == 200){
		writeln("COŚ POSZŁO BARDZO NIE TAK! (Przekroczono 200 iteracji w głównej pętli)");
	}
	string[] stringed_simple_implicants = [];
	foreach (SimpleImplicantValue[] simple_implicant; simple_implicants)
	{
		stringed_simple_implicants ~= simple_implicant_to_string(simple_implicant,column_names);
	}
	writefln("%s",stringed_simple_implicants.join(" + "));
}

string simple_implicant_to_string(SimpleImplicantValue[] simple_implicant,char[] column_names){
	simple_implicant = simple_implicant;
	int shift = cast(int)column_names.length - 1;
	string returnable = "";
	foreach (simple_implicant_bit; simple_implicant)
	{
		//writefln("Converting %s for column name %s",simple_implicant_bit,column_names[shift]);
		if(simple_implicant_bit != SimpleImplicantValue.DONT_CARE){
			returnable ~= (simple_implicant_bit == SimpleImplicantValue.TRUE) ? format("%s",column_names[shift]) :format("%s'",column_names[shift]) ;
		}
		
		shift--;
	}
	return returnable;
}


bool value_matches_simple_implicant(uint value,SimpleImplicantValue[] simple_implicant){
	int shift = 0;
	foreach (SimpleImplicantValue simple_implicant_bit; simple_implicant)
	{
		uint bit = (value >> shift) & 0b1;
		if(simple_implicant_bit == SimpleImplicantValue.TRUE && bit == 0){return false;}
		if(simple_implicant_bit == SimpleImplicantValue.FALSE && bit == 1){return false;}
		shift++;
	}

	return true;	
}

uint[] generate_block_matrix(uint cube,uint[] R){
	uint[] block_matrix = R.dup;
	for(int i = 0;i < block_matrix.length;i++){
		block_matrix[i] = block_matrix[i] ^ cube;
	}
	return block_matrix;
}

enum SimpleImplicantValue {
	TRUE,
	FALSE,
	DONT_CARE
}

SimpleImplicantValue[] get_simple_implicant(uint cube,uint[] block_matrix,uint max_value){
	uint mask = 0;
	while (mask < max_value){
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
			//writefln("Found implicant %b",mask);
			SimpleImplicantValue[] product = [];
			uint cube_mod = cube;
			uint i = 0;
			while(mask > 0){
				uint mask_bit_value = mask & 0b1;
				if(mask_bit_value == 0){
					product ~= SimpleImplicantValue.DONT_CARE;
				}
				else {
					//product ~= (cube_mod & 0b1) == 1 ? '1' : '0';
					product ~= (cube_mod & 0b1) == 1 ? SimpleImplicantValue.TRUE : SimpleImplicantValue.FALSE;
				}
				cube_mod = cube_mod >> 1;
				mask = mask >> 1;
				i++;
			}
			return product;
		}
		mask++;
	}
	return [];
}