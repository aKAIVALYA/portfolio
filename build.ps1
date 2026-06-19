# Build script for Windows (PowerShell)
if (Test-Path dist) {
    Remove-Item -Recurse -Force dist -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path dist -Force | Out-Null

Write-Host "Building Tailwind CSS to dist/index.css..."
& npx tailwindcss -i ./src/index.css -o ./dist/index.css --minify

if ($LASTEXITCODE -ne 0) {
    Write-Error "Tailwind build failed"
    exit 1
}

Write-Host "Building HTML files to dist..."
& python src/build.py --output dist --no-clean

if ($LASTEXITCODE -ne 0) {
    Write-Error "HTML build failed"
    exit 1
}

Write-Host "Copying static assets..."
if (Test-Path public) {
    Get-ChildItem -Path public\* | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination dist\ -Recurse -Force
    }
}

Write-Host "Optimizing images..."
& python src/optimize_images.py

if ($LASTEXITCODE -ne 0) {
    Write-Error "Image optimization failed"
    exit 1
}

Write-Host "Build completed successfully!"
