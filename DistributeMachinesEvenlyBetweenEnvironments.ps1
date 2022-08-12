# Define working variables
$octopusURL = ""
$octopusAPIKey = ""
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$environments = @("Environments-1", "Environments-61")

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object {$_.Name -eq $spaceName}

# Get machine list
$machines = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/machines/all" -Headers $header) | Where-Object {$_}

# Loop through list
foreach ($machine in $machines)
{
    $idx = $machines.IndexOf($machine);

    # Update the machine object
    $machine.EnvironmentIds = @($environments[$idx%$environments.Count])

    # Update the Machine
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/machines/$($machine.Id)" -Body ($machine | ConvertTo-Json -Depth 10) -Headers $header
}
