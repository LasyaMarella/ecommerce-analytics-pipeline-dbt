# Sync dbt documentation (descriptions, display names, semantic types) to Metabase.
# Run from the dbt-metabase virtual environment. Credentials come from environment variables.
param(
    [string]$MetabaseUrl = "http://localhost:3000",
    [string]$Database = "ECOMMERCE Snowflake (marts)"
)

if (-not $env:METABASE_USERNAME -or -not $env:METABASE_PASSWORD) {
    Write-Error "Set METABASE_USERNAME and METABASE_PASSWORD first."
    exit 1
}

$manifest = Join-Path $PSScriptRoot "..\target\manifest.json"
if (-not (Test-Path $manifest)) {
    Write-Error "manifest.json not found. Run 'dbt parse' in the project first."
    exit 1
}

dbt-metabase models `
    --manifest-path $manifest `
    --metabase-url $MetabaseUrl `
    --metabase-database $Database `
    --include-models rpt_order_items `
    --order-fields