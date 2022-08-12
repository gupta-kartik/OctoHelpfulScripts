<Query Kind="Program" />

void Main()
{
	int pkgCounter = 0;
	int arcCounter = 0;
	
	var NodeName = "";

	foreach (var file in Directory.EnumerateFiles(@$"C:\Unzipped\{NodeName}", "*.txt"))
	{
		foreach (string line in System.IO.File.ReadLines(file))
		{
			if (Regex.IsMatch(line, "(Package)(.*)(was uploaded. Assessing whether to automatically create any releases)"))
			{
				string outFile = @$"C:\Unzipped\{NodeName}\PackageUploaded.txt";
				GrabTimestamp(line, outFile);
				GrabPackageAndVersion(line, outFile, NodeName);
				pkgCounter++;
			}

			if (Regex.IsMatch(line, "(Package with Id:)(.*)(and Version:)(.*)(was uploaded)"))
			{
				string outFile = @$"C:\Unzipped\{NodeName}\ReleaseCreated.txt";
				GrabTimestamp(line, outFile);
				GrabPackageAndVersionForRelease(line, outFile, NodeName);
				arcCounter++;
			}
		}
	}

	System.Console.WriteLine("{0} packages were uploaded and {1} releases created", pkgCounter, arcCounter);
}

async void GrabTimestamp(string line, string fileOut)
{
	using StreamWriter file = new(fileOut, append: true);

	string regexPatternTimestamp = @"\S{1,}\s{1,}";
	MatchCollection matches = Regex.Matches(line, regexPatternTimestamp);
	await file.WriteAsync(matches[0].Value + matches[1].Value);

}

async void GrabPackageAndVersion(string line, string fileOut, string NodeName)
{
	using StreamWriter file = new(fileOut, append: true);

	string regexPatternPackageAndVersion = "\"[^\"]*\"";
	MatchCollection matches2 = Regex.Matches(line, regexPatternPackageAndVersion);
	await file.WriteLineAsync(matches2[0].Value.Replace("\"", "") + " " + matches2[1].Value.Replace("\"", ""));
}
	
async void GrabPackageAndVersionForRelease(string line, string fileOut, string NodeName)
{
	using StreamWriter file = new(fileOut, append: true);

	string regexPatternPackageAndVersion = "\"[^\"]*\"";
	MatchCollection matches2 = Regex.Matches(line, regexPatternPackageAndVersion);
	
	string regexDuration = @"\s{0}[0-9]*(ms)";
	MatchCollection matches3 = Regex.Matches(line, regexDuration);
	
	await file.WriteLineAsync(matches2[0].Value.Replace("\"", "") + " " + matches2[1].Value.Replace("\"", "") + " " + matches3[0].Value);
}

