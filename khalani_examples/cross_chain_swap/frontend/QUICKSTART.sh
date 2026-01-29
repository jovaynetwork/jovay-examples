#!/bin/bash

# Quick Start Script for Khalani Cross-Chain Swap dApp
# This script sets up the development environment and runs the dApp

set -e

echo "🚀 Khalani Cross-Chain Swap dApp - Quick Start"
echo "=================================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js v18 or higher."
    echo "   Visit: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js version: $(node -v)"
echo ""

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed. Please install npm."
    exit 1
fi

echo "✅ npm version: $(npm -v)"
echo ""

# Navigate to frontend directory
cd "$(dirname "$0")"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

echo ""
echo "✅ Dependencies installed successfully!"
echo ""

# Start development server
echo "🚀 Starting development server..."
echo "   The dApp will be available at http://localhost:3000"
echo ""
npm run dev
