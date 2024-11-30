import std.stdio;
import std.format;
import std.algorithm.mutation : reverse;
import std.algorithm;


import std.array;
import std.container;
import std.range;

import simple_implicant;

import block_matrix;

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
		0b0111,
		0b1111
	];
	SimpleImplicantValue[][] simple_implicants = [];
	int it = 0;
	while(F.length > 0 && it < 200){

		uint cube = F[0];
		uint[] block_matrix = generate_block_matrix(cube,R);
		SimpleImplicantValue[] cubes_simple_implicant = get_simple_implicant(cube,block_matrix,uint.max);
		simple_implicants ~= cubes_simple_implicant;
		F = simple_implicant.remove_values_matching_simple_implicant(F,cubes_simple_implicant);
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