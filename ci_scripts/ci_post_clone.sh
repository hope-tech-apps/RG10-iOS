#!/bin/sh

echo "🧹 Starting Xcode Cloud post-clone cleanup..."

# Clean any previous builds
echo "Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Clean the specific CI derived data if it exists
if [ -n "$CI_DERIVED_DATA_PATH" ]; then
    echo "Cleaning CI derived data..."
    rm -rf "$CI_DERIVED_DATA_PATH"
fi

# Clean build artifacts
echo "Cleaning build artifacts..."
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# Clean any .stringsdata files that might be lingering
echo "Cleaning stringsdata files..."
find . -name "*.stringsdata" -type f -delete

# Ensure clean module cache
echo "Cleaning module cache..."
rm -rf ~/Library/Developer/Xcode/DerivedData/ModuleCache.noindex

echo "✅ Cleanup complete!"
