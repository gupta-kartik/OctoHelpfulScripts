# Define working variables
$octopusURL = ""
$octopusAPIKey = ""
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "default"
$projectName = "Project"
$projectDescription = "MyDescription"
$projectGroupName = "Default project group"
$lifecycleName = "Default lifecycle"
$numberOfProjectsToCreate = 
$i=1

# Get space
$space = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/spaces/all" -Headers $header) | Where-Object {$_.Name -eq $spaceName}

# Get project group
$projectGroup = (Invoke-RestMethod -Method Get "$octopusURL/api/$($space.Id)/projectgroups/all" -Headers $header) | Where-Object {$_.Name -eq $projectGroupName}

# Get Lifecycle
$lifeCycle = (Invoke-RestMethod -Method Get "$octopusURL/api/$($space.Id)/lifecycles/all" -Headers $header) | Where-Object {$_.Name -eq $lifecycleName}


for(;$i -le $numberOfProjectsToCreate;$i++)
{
    # Create project json payload
    $jsonPayloadProject = @{
        Name = "$projectName$($i)"
        Description = $projectDescription
        ProjectGroupId = $projectGroup.Id
        LifeCycleId = $lifeCycle.Id
    }

    # Create project
    Invoke-RestMethod -Method Post -Uri "$octopusURL/api/$($space.Id)/projects" -Body ($jsonPayloadProject | ConvertTo-Json -Depth 10) -Headers $header

    # Get Project
    $project = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/all" -Headers $header) | Where-Object {$_.Name -eq "$projectName$($i)"}
    # Write-Host $project.Name $project.Id
    
    # Get Deployment Process
    $deploymentProcess = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/deploymentprocesses" -Headers $header)
    # Write-Host $deploymentProcess

    # Create Steps
    $steps = @(@{
        Name = "Run a script"
        PackageRequirement = "LetOctopusDecide"
        Properties = @{}
        Condition = "Success"
        StartTrigger = "StartAfterPrevious"
        Actions = @(
        @{
            Name = "Run a script"
            ActionType = "Octopus.Script"
            Notes=$null
            IsDisabled = $false
            CanBeUsedForProjectVersioning = $true
            IsRequired = $false
            WorkerPoolId = ""
            WorkerPoolVariable = ""
            Container = @{
                "FeedId" = $null
                "Image" = $null
            }
            Environments = @()
            ExcludedEnvironments = @()
            Channels = @()
            TenantTags = @()
            Packages = @(@{
                Id=$null
                PackageId="Hello${i}World"
                FeedId="feeds-builtin"
                AcquisitionLocation="Server"
                Properties=@{
                    SelectionMode="immediate"
                }
            })
            Properties = @{
                'Octopus.Action.RunOnServer' = "true"
                'Octopus.Action.EnabledFeatures' = ""
                'Octopus.Action.Script.ScriptSource' = "Package"
                'Octopus.Action.Script.ScriptFileName' = "SimpleHello.ps1"
                'Octopus.Action.Script.Syntax' = $null
                'Octopus.Action.Script.ScriptBody' = $null
            }
        }
        )
    })

    # Update Steps object
    $deploymentProcess.Steps = $steps

    # Push Steps
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/deploymentprocesses" -Body ($deploymentProcess | ConvertTo-Json -Depth 10) -Headers $header


    # Get Channel
    $channels = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/projects/$($project.Id)/channels" -Headers $header)
    $defaultChannel = @{}
    foreach ($channel in $channels.Items) {
        if ($channel.IsDefault = $true) {
            $defaultChannel = $channel
            break
        }
    }

    # Turn ARC on
    $project.AutoCreateRelease = $true
    $project.ReleaseCreationStrategy.ReleaseCreationPackage = @{DeploymentAction="Run a script"}
    $project.ReleaseCreationStrategy.ChannelId = $defaultChannel.Id
    $project.VersioningStrategy = @{
        Template = ""
        DonorPackage = @{
            DeploymentAction = "Run a script"
        }
        DonorPackageStepId = "Run a script"
    }

    # Update Project
    Invoke-RestMethod -Method Put -Uri "$octopusURL/api/$($space.Id)/projects/$($project.id)" -Body ($project | ConvertTo-Json -Depth 10) -Headers $header
}
