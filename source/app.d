import std.stdio;
import std.format;
import std.algorithm;

import std.array;
import std.container;
import std.range;

import simple_implicant;

import block_matrix;

import std.conv;

import std.uni;

void main()
{
	char[] column_names = [];
	while (true)
	{
		writeln("Podaj nazwy kolumn (pojedyncze litery) albo nic aby przejsc dalej:");
		string input = readln();
		if (input == "\n")
		{
			break;
		}
		column_names ~= input[0];
	}

	uint[] F = [];
	while (true)
	{
		writeln("Podaj stan on-set albo nic aby przejsc dalej");
		string input = readln();
		if (input == "\n")
		{
			break;
		}
		F ~= parse!uint(input);
	}
	uint[] R = [];
	while (true)
	{
		writeln("Podaj stan off-set albo nic aby przejsc dalej");
		string input = readln();
		if (input == "\n")
		{
			break;
		}
		R ~= parse!uint(input);
	}
	SimpleImplicantValue[][] simple_implicants = [];
	int iteration = 0;
	while (F.length > 0 && iteration < 200)
	{
		uint cube = F[0];
		uint[] block_matrix = generate_block_matrix(cube, R);
		SimpleImplicantValue[] cubes_simple_implicant = get_simple_implicant(cube, block_matrix, cast(
				int)(column_names.length * column_names.length));
		simple_implicants ~= cubes_simple_implicant;
		F = simple_implicant.remove_values_matching_simple_implicant(F, cubes_simple_implicant);
		iteration++;
	}
	if (iteration == 200)
	{
		writeln("Przekroczono 200 iteracji w głównej pętli");
		return;
	}
	string[] stringed_simple_implicants = [];
	foreach (SimpleImplicantValue[] simple_implicant; simple_implicants)
	{
		stringed_simple_implicants ~= simple_implicant_to_string(simple_implicant, column_names);
	}
	writefln("%s", stringed_simple_implicants.join(" + "));
}
