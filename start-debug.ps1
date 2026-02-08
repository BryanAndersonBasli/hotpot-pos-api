#!/usr/bin/env pwsh
# Quick Debug Script untuk Hotpot POS

Write-Host ""
Write-Host "========================================"
Write-Host "   Hotpot POS - Quick Debug Launcher" -ForegroundColor Cyan
Write-Host "========================================"
Write-Host ""
Write-Host "Platform Debugging:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Web (Chrome) - RECOMMENDED"
Write-Host "2. Web (Chrome) - Fast Mode"
Write-Host "3. Clean & Web Debug"
Write-Host "4. Show Flutter Doctor"
Write-Host "5. Exit"
Write-Host ""

$choice = Read-Host "Pilih nomor (1-5)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "Starting Flutter Web Debugging (Chrome)..." -ForegroundColor Green
        Write-Host "Tunggu 2-3 menit untuk first run" -ForegroundColor Yellow
        Write-Host ""
        flutter run -d chrome
    }
    "2" {
        Write-Host ""
        Write-Host "Starting Flutter Web Debugging (Fast Mode)..." -ForegroundColor Green
        Write-Host ""
        flutter run -d chrome --fast-start
    }
    "3" {
        Write-Host ""
        Write-Host "Cleaning Flutter project..." -ForegroundColor Yellow
        flutter clean
        flutter pub get
        Write-Host ""
        Write-Host "Starting Flutter Web Debugging..." -ForegroundColor Green
        flutter run -d chrome
    }
    "4" {
        Write-Host ""
        flutter doctor -v
        Write-Host ""
        Read-Host "Tekan Enter untuk lanjut"
    }
    "5" {
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    default {
        Write-Host "Invalid choice!" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Debug session ended." -ForegroundColor Cyan
