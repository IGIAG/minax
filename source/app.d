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
import std.random;

void main(string[] args)
{
	writeln(args);
	auto rnd = MinstdRand0(42);
	char[] column_names = [];
	uint[] F = [];
	uint[] R = [];
	if(args.length == 1){
		read_from_input(column_names,F,R);
	}
	else {
		read_from_file(args[1],column_names,F,R);
	}
	
	SimpleImplicantValue[][] simple_implicants = [];
	int iteration = 0;
	while (F.length > 0 && iteration < 10000)
	{
		uint cube = F[0];
		uint[] block_matrix = generate_block_matrix(cube, R);
		try
		{
			SimpleImplicantValue[] cubes_simple_implicant = get_simple_implicant(cube, block_matrix, cast(
					int)(column_names.length * column_names.length), column_names);
			simple_implicants ~= cubes_simple_implicant;
			F = simple_implicant.remove_values_matching_simple_implicant(F, cubes_simple_implicant);
		}
		catch (Exception e)
		{
			F = F.randomShuffle(rnd);
		}
		iteration++;
	}
	if (iteration == 10000)
	{
		writeln("Przekroczono 10000 iteracji w głównej pętli");
		return;
	}
	string[] stringed_simple_implicants = [];
	foreach (SimpleImplicantValue[] simple_implicant; simple_implicants)
	{
		stringed_simple_implicants ~= simple_implicant_to_string(simple_implicant, column_names);
	}
	writefln("%s", stringed_simple_implicants.join(" + "));
}

void read_from_input(ref char[] column_names,ref uint[] F,ref uint[] R){
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
}
void read_from_file(string path,ref char[] column_names,ref uint[] F,ref uint[] R){
	File file = File(path,"r");
	string mode = file.readln();
	bool binary_mode = false;
	if (mode == "BINARY\n"){
		binary_mode = true;
	}
	//Skip line
	file.readln();

	string[] col_names_long = file.readln().split(",");
	foreach (string col_name; col_names_long)
	{
		column_names ~= col_name[0];
	}

	//Skip file
	file.readln();

	string row = file.readln();
	while(row != "\n"){
		row = row.replace("\n","");
		if(binary_mode){
			F ~= parse!uint(row,2);
		}
		else {
			F ~= parse!uint(row,10);
		}
		row = file.readln();
	}
	row = file.readln();
	while(row != "\n" && row.length != 0){
		row = row.replace("\n","");
		if(binary_mode){
			R ~= parse!uint(row,2);
		}
		else {
			R ~= parse!uint(row,10);
		}
		row = file.readln();
	}
}