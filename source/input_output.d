module input_output;

import std.stdio;
import std.array;
import std.conv;

void read_from_input(ref char[] column_names,ref uint[] F,ref uint[] R){
	writeln("Reading from terminal be default. Use --help for more information.");

	while (true)
	{
		writeln("Input column name (1 character). Enter empty line to continue.");
		string input = readln();
		if (input == "\n")
		{
			break;
		}
		column_names ~= input[0];
	}

	
	while (true)
	{
		writeln("Enter On-Set vector. Enter empty line to continue.");
		string input = readln();
		if (input == "\n")
		{
			break;
		}
		F ~= parse!uint(input);
	}
	
	while (true)
	{
		writeln("Enter Off-Set vector. Enter empty line to continue.");
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