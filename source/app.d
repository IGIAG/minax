import std.stdio;
import std.range;
import simple_implicant;
import block_matrix;
import input_output;
import methods.heuristic;
import methods.smart;
import methods.systemic;
import methods.none;
import darg;
import state;
import methods.systematic;

struct Options
{
	@Option("help", "h")
	@Help("Wyświetla tę wiadomość")
	OptionFlag help;

	@Argument("file", Multiplicity.optional)
	@Help("Opcjonalna ścieżka do pliku")
	string path = "";
	@Option("method", "m")
	@Help("Opcjonalna metoda do minimalizacji (HEURISTIC,SMART,NONE,FULL)")
	string method = "";
	@Option("cap", "c")
	@Help("Tylko dla metody FULL. Opcjonalny parametr, ogranicza przeszukiwane kombinacje implikantów. Ustawnienie tego parametru neguje systematyczność tej metody ale ma duże zyski wydajnościowe")
	int full_cap = 0;
	@Option("show-progress", "s")
	@Help("(Działa tylko dla metody FULL) Wypisuje nr. iteracji oraz ilość znalezionych ścieżek w czasie rzeczywistym.")
	bool show_progress = false;

}

immutable usage = usageString!Options("minax");
immutable help = helpString!Options;

void main(string[] args)
{
	writeln(import("intro.txt"));

	Options options;

	try
	{
		options = parseArgs!Options(args[1 .. $]);
	}
	catch (ArgParseError e)
	{
		writeln(e.msg);
		writeln(usage);
		return;
	}
	catch (ArgParseHelp e)
	{
		writeln(usage);
		write(help);
		return;
	}

	char[] column_names = [];
	uint[] F = [];
	uint[] R = [];
	if (options.path == "")
	{
		input_output.read_from_input(column_names, F, R);
	}
	else
	{
		input_output.read_from_file(options.path, column_names, F, R);
	}
	SimpleImplicant[] simple_implicants;
	switch (options.method)
	{
	case "SMART":
		simple_implicants = smart_method(F, R, column_names);
		break;
	case "HEURISTIC":
		simple_implicants = heuristic_method(F, R, column_names);
		break;
	case "NONE":
		simple_implicants = minterms(F, R, column_names);
		break;
	case "FULL":
		if (options.show_progress)
		{
			SHOW_PROGRESS = true;
		}
		state.FULL_CAP = options.full_cap;
		simple_implicants = systemic(F, R, column_names);
		break;
	case "SYSTEMATIC":
		simple_implicants = systematic(F, R, column_names);
		break;
	default:
		simple_implicants = heuristic_method(F, R, column_names);
		break;
	}

	writefln("Uproszczone wyrazenie booleowskie: %s", simple_implicant_to_string(
			simple_implicants, column_names));
}
