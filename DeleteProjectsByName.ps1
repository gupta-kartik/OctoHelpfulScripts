# Define working variables
$octopusURL = ""
$octopusAPIKey = ""
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "Default"
$projectName = "Project"
$numberOfProjectsToDelete = 
$i = 1

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object {$_.Name -eq $spaceName}

for(;$i -le $numberOfProjectsToDelete;$i++) {
    # Get project
    $project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object {$_.Name -eq "$projectName$($i)"}

    # Delete ARC
    $project.AutoCreateRelease = $false
    $project.ReleaseCreationStrategy.ReleaseCreationPackageStepId = ""
    $project.ReleaseCreationStrategy.ChannelId = $null
    $project.VersioningStrategy.DonorPackageStepId = $null
    $project.VersioningStrategy.DonorPackage = $null
    $Project.VersioningStrategy.Template = "#{Octopus.Version.LastMajor}.#{Octopus.Version.LastMinor}.#{Octopus.Version.NextPatch}"

    $projectJson = $project | ConvertTo-Json

    Invoke-WebRequest $OctopusURL/api/projects/$($project.id) -Method Put -Headers $header -Body $projectJson

    # Delete project
    Invoke-RestMethod -Method Delete -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)" -Headers $header
}