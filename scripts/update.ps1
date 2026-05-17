# ============================================================
#  update.ps1  —  Updater script (disimpan di folder instalasi)
#  Klik kanan → Run as Administrator, atau via shortcut menu
# ============================================================

param(
    [string]$ZipUrl = "https://example.com/app.zip"   # Ganti sesuai URL terbaru
)

$InstallDir = $PSScriptRoot   # folder tempat update.ps1 berada = folder instalasi

function Log($msg) { Write-Host "[UPDATE] $msg" }
function Ok ($msg) { Write-Host "[OK]     $msg" -ForegroundColor Green }
function Err($msg) { Write-Host "[ERROR]  $msg" -ForegroundColor Red; Read-Host "Tekan Enter untuk keluar"; exit 1 }

# ── 1. Download ZIP terbaru ──────────────────────────────────
$zipPath = "$env:TEMP\app_update.zip"
Log "Mendownload update dari $ZipUrl ..."
try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath -UseBasicParsing
    Ok "Download selesai."
} catch {
    Err "Gagal download update: $_"
}

# ── 2. Extract (overwrite) ───────────────────────────────────
Log "Mengextract ke $InstallDir ..."
try {
    Expand-Archive -Path $zipPath -DestinationPath $InstallDir -Force
    Ok "Extract selesai."
} catch {
    Err "Gagal extract: $_"
}
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# ── 3. npm install ───────────────────────────────────────────
Log "Menjalankan npm install ..."
Push-Location $InstallDir
try {
    & npm install --omit=dev 2>&1 | Tee-Object -FilePath "$InstallDir\npm-update.log"
    Ok "npm install selesai."
} catch {
    Err "npm install gagal: $_"
} finally {
    Pop-Location
}

# ── 4. PM2 restart ───────────────────────────────────────────
Log "Merestart aplikasi PM2 ..."
& pm2 restart myapp 2>&1 | Out-Null
Ok "Aplikasi berhasil direstart."

Log ""
Ok "Update selesai! Aplikasi sudah berjalan dengan versi terbaru."
Read-Host "Tekan Enter untuk menutup"
