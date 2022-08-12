# Define working variables
$numberOfPackagesRequired = 
$serverUrl = ""
$apiKey = ""
$spaceName = "Default"
$i=1

for(;$i -le $numberOfPackagesRequired ;$i++)
{
    octo pack --id="Hello$($i)World" --format="zip" --version="1.0.$($i)" --basePath="c:\DevOcto\OctoHelpfulScripts\SimpleHello" --outFolder="c:\DevOcto\OctoHelpfulScripts\SamplePackages"
    octo push --package="c:\DevOcto\OctoHelpfulScripts\SamplePackages\Hello$($i)World.1.0.$($i).zip" --server=$serverUrl --apiKey=$apiKey --space=$spaceName
}