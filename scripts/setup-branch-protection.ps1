Param(
  [string]$Owner = "RJF-72",
  [string]$Repo = "l32thestar",
  [string]$Branch = "main",
  [int]$RequiredApprovals = 1,
  [switch]$RequireLinearHistory = $true,
  [switch]$DisallowForcePushes = $true
)

if (-not $env:GITHUB_TOKEN) {
  Write-Error "GITHUB_TOKEN environment variable is not set. Create a PAT with 'repo' scope and set it: `$env:GITHUB_TOKEN='...'";
  exit 1
}

$uri = "https://api.github.com/repos/$Owner/$Repo/branches/$Branch/protection"

$body = @{ 
  required_status_checks = $null
  enforce_admins = $true
  required_pull_request_reviews = @{ 
    dismiss_stale_reviews = $true
    require_code_owner_reviews = $false
    required_approving_review_count = $RequiredApprovals
  }
  restrictions = $null
  required_linear_history = [bool]$RequireLinearHistory
  allow_force_pushes = (-not [bool]$DisallowForcePushes)
  allow_deletions = $false
  block_creations = $false
} | ConvertTo-Json -Depth 5

$headers = @{ 
  Authorization = "token $($env:GITHUB_TOKEN)"
  Accept = "application/vnd.github+json"
  "X-GitHub-Api-Version" = "2022-11-28"
}

Write-Host "Applying branch protection to $Owner/$Repo@$Branch ..."
try {
  $response = Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -Body $body
  Write-Host "Branch protection updated successfully." -ForegroundColor Green
} catch {
  Write-Error "Failed to update branch protection: $($_.Exception.Message)"
  if ($_.ErrorDetails.Message) { Write-Host $_.ErrorDetails.Message }
}