#!/bin/bash

echo "🚀 Deploying Eyejack Admin Dashboard to Vercel..."
echo ""

# Check if vercel CLI is installed
if ! command -v vercel &> /dev/null; then
    echo "📦 Installing Vercel CLI..."
    npm install -g vercel
fi

# Build the project
echo "🔨 Building dashboard..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "🌐 Deploying to Vercel..."
    vercel --prod
    
    echo ""
    echo "✅ Dashboard deployed successfully!"
    echo ""
    echo "🎉 Your dashboard is now live!"
else
    echo "❌ Build failed. Please fix errors and try again."
    exit 1
fi

