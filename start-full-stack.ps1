# TripBond Full Stack Startup Script
# Starts FastAPI Backend, Flask AI Server, and optionally Flutter Frontend
# Run with: powershell -ExecutionPolicy Bypass -File start-full-stack.ps1

param(
    [switch]$NoFrontend,
    [switch]$NoAI,
    [int]$Port = 8000
)

# Colors for output
function Write-Success { Write-Host $args[0] -ForegroundColor Green -BackgroundColor Black }
function Write-Info { Write-Host $args[0] -ForegroundColor Cyan -BackgroundColor Black }
function Write-Warning { Write-Host $args[0] -ForegroundColor Yellow -BackgroundColor Black }
function Write-Error { Write-Host $args[0] -ForegroundColor Red -BackgroundColor Black }

# Setup
$RootDir = (Get-Item $PSScriptRoot).FullName
$BackendDir = Join-Path $RootDir "backend"
$FrontendDir = Join-Path $RootDir "frontend"
$AIDir = Join-Path $RootDir "tripbond_ai_backend"

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║         TripBond Full Stack Startup Script                ║" -ForegroundColor Magenta
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Info "🚀 Starting TripBond services..."
Write-Info "📁 Root: $RootDir"

# Check Python availability
try {
    $PythonVersion = python --version 2>&1
    Write-Success "✓ Python found: $PythonVersion"
} catch {
    Write-Error "✗ Python not found in PATH"
    Write-Warning "Please install Python 3.9+ or add to PATH"
    exit 1
}

# Check venv
$VEnvPath = Join-Path $RootDir ".venv"
if (-not (Test-Path $VEnvPath)) {
    Write-Warning "⚠ Virtual environment not found at $VEnvPath"
    Write-Info "Creating virtual environment..."
    python -m venv ".venv"
    Write-Success "✓ Virtual environment created"
}

# Activate venv
Write-Info "🔌 Activating virtual environment..."
$ActivateScript = Join-Path $VEnvPath "Scripts\Activate.ps1"
& $ActivateScript

# ============================================================================
# Start FastAPI Backend
# ============================================================================
Write-Host ""
Write-Host "╔─ FastAPI Backend ──────────────────────────────────────────╗" -ForegroundColor Yellow
Write-Info "Starting FastAPI backend on port $Port..."
Write-Info "Command: python backend/run.py"

# Run in new PowerShell window
$BackendScript = @"
cd '$RootDir'
& '$ActivateScript'
Write-Host ""
Write-Host '================================' -ForegroundColor Green
Write-Host 'FastAPI Backend Starting...' -ForegroundColor Green
Write-Host '================================' -ForegroundColor Green
Write-Host ""
python backend/run.py
"@

$BackendFile = Join-Path $RootDir "start_backend_temp.ps1"
$BackendScript | Out-File $BackendFile -Encoding UTF8
Start-Process powershell -ArgumentList "-NoExit", "-File", $BackendFile
Write-Success "✓ FastAPI backend window opened (http://localhost:$Port)"
Write-Success "  📊 Swagger Docs: http://localhost:$Port/docs"
Start-Sleep -Seconds 3

# ============================================================================
# Start Flask AI Server (Optional)
# ============================================================================
if (-not $NoAI) {
    Write-Host ""
    Write-Host "╔─ Flask AI Server ──────────────────────────────────────────╗" -ForegroundColor Cyan
    Write-Info "Starting Flask AI backend on port 5000..."
    Write-Info "Command: python tripbond_ai_backend/run_ai.py"

    $AIScript = @"
cd '$RootDir'
& '$ActivateScript'
Write-Host ""
Write-Host '================================' -ForegroundColor Cyan
Write-Host 'Flask AI Server Starting...' -ForegroundColor Cyan
Write-Host '================================' -ForegroundColor Cyan
Write-Host ""
python tripbond_ai_backend/run_ai.py
"@

    $AIFile = Join-Path $RootDir "start_ai_temp.ps1"
    $AIScript | Out-File $AIFile -Encoding UTF8
    Start-Process powershell -ArgumentList "-NoExit", "-File", $AIFile
    Write-Success "✓ Flask AI server window opened (http://localhost:5000)"
    Write-Success "  🚀 Health check: http://localhost:5000/health"
    Start-Sleep -Seconds 2
} else {
    Write-Warning "⊘ AI Backend disabled (use -NoAI to enable by default)"
}

# ============================================================================
# Start Flutter Frontend (Optional)
# ============================================================================
if (-not $NoFrontend) {
    Write-Host ""
    Write-Host "╔─ Flutter Frontend ─────────────────────────────────────────╗" -ForegroundColor Magenta
    Write-Info "Starting Flutter frontend on Chrome..."
    Write-Info "Command: flutter run -d chrome"

    $FrontendScript = @"
cd '$FrontendDir'
Write-Host ""
Write-Host '================================' -ForegroundColor Magenta
Write-Host 'Flutter Frontend Starting...' -ForegroundColor Magenta
Write-Host '================================' -ForegroundColor Magenta
Write-Host ""
Write-Host 'Running Flutter on Chrome...' -ForegroundColor Magenta
flutter run -d chrome
"@

    $FrontendFile = Join-Path $RootDir "start_frontend_temp.ps1"
    $FrontendScript | Out-File $FrontendFile -Encoding UTF8
    Start-Process powershell -ArgumentList "-NoExit", "-File", $FrontendFile
    Write-Success "✓ Flutter frontend window opened"
    Write-Info "  ▶ Frontend will open in Chrome (usually port 53693)"
} else {
    Write-Warning "⊘ Frontend disabled (use -NoFrontend to skip)"
}

# ============================================================================
# Summary
# ============================================================================
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         ✅ All services started successfully!              ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green

Write-Host ""
Write-Host "📍 Service URLs:" -ForegroundColor Cyan
Write-Host "  • FastAPI Backend:  http://localhost:$Port" -ForegroundColor White
Write-Host "  • Swagger Docs:     http://localhost:$Port/docs" -ForegroundColor White

if (-not $NoAI) {
    Write-Host "  • Flask AI Server:  http://localhost:5000" -ForegroundColor White
    Write-Host "  • AI Health Check:  http://localhost:5000/health" -ForegroundColor White
}

Write-Host ""
Write-Host "📋 Quick Tests:" -ForegroundColor Cyan
Write-Host "  • Backend Health:   curl http://localhost:$Port/" -ForegroundColor Gray
Write-Host "  • AI Status:        curl http://localhost:$Port/api/ai/status" -ForegroundColor Gray
Write-Host "  • API Docs:         Open http://localhost:$Port/docs in browser" -ForegroundColor Gray
Write-Host ""
Write-Host "📝 Commands:" -ForegroundColor Cyan
Write-Host "  • Full stack:       powershell -File start-full-stack.ps1" -ForegroundColor Gray
Write-Host "  • Backend only:     python backend/run.py" -ForegroundColor Gray
Write-Host "  • Frontend only:    cd frontend && flutter run -d chrome" -ForegroundColor Gray
Write-Host ""
Write-Host "⚠️  Note: Each service runs in its own window. Close windows to stop services." -ForegroundColor Yellow
Write-Host ""
