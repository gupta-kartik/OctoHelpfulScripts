<Query Kind="Statements">
  <NuGetReference>Newtonsoft.Json</NuGetReference>
  <NuGetReference>System.Text.Json</NuGetReference>
  <Namespace>Newtonsoft.Json</Namespace>
</Query>

// Export raw data from trello using the following steps:
// 1. Go to the trello board
// 2. Show Menu -> More -> Print and Export -> Export as JSON
// 3. Save the file in at C:\temp\CPPTRELLO.json
dynamic board = JsonConvert.DeserializeObject(File.ReadAllText(@"c:\temp\CPPTRELLO.json"));

// We want labels prefixed with qrf AND the area/QRF label
var qrfRelatedLabels = (
	from card in (IEnumerable<dynamic>)board.cards // Trello limits the board.labels list to only 50. Using the cards.labels object instead.
		from label in (IEnumerable<dynamic>)card.labels
		select new
		{
			Id = (string)label.id,
			Name = (string)label.name,
			Color = (string)label.color
		}
)
.Where(l => (l.Color != null) && (l.Name.StartsWith("area/QRF") || l.Name.StartsWith("qrf")))
.Distinct()
.Dump()
.ToArray();

// Set the list to analyze
var ListToAnalyse = "Done Q3";
var listsToAnalyze = (
	from list in (IEnumerable<dynamic>)board.lists
	where ((string)list.name).Contains(ListToAnalyse)
	select new
	{
		Id = (string)list.id,
		Name = (string)list.name
	}
)
.Dump()
.ToArray();

// Filtering
var cards =
	from card in (IEnumerable<dynamic>)board.cards where card.idLabels.ToString().Contains("62183a3471e1503c6b0cf27a") // Only get the cards that have area/QRF label (top level filtering) 
	join list in listsToAnalyze on (string)card.idList equals list.Id
	from cardLabel in (IEnumerable<dynamic>)card.idLabels 
	join label in qrfRelatedLabels on (string)cardLabel equals label.Id 
	select new
	{
		Label = label.Name,
		Id = label.Id
	};

// Counting
cards.GroupBy(l => l.Label).Select(x => new
{
	Label = x.Key,
	Count = x.Select(l => l.Label).Count()

}).OrderBy(a => a.Label).Dump(true);