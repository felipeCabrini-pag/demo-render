#!/bin/bash

# Deploy to Render - Final Verification Script
# This script verifies that the application is ready for Render deployment

echo "🚀 Render Deployment Verification Script"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "build.gradle" ]; then
    echo "❌ Error: Please run this script from the project root directory"
    exit 1
fi

# Step 1: Clean and build the application
echo "📦 Building the application..."
./gradlew clean build -x test
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo "✅ Build successful"

# Step 2: Check Docker configuration
echo "🐳 Checking Docker configuration..."
if [ ! -f "Dockerfile" ]; then
    echo "❌ Dockerfile not found!"
    exit 1
fi
echo "✅ Dockerfile found"

# Step 3: Check Render configuration
echo "🌐 Checking Render configuration..."
if [ ! -f "render.yaml" ]; then
    echo "❌ render.yaml not found!"
    exit 1
fi

# Verify environment variables in render.yaml
if grep -q "SPRING_PROFILES_ACTIVE" render.yaml && grep -q "SPRING_DATASOURCE_URL" render.yaml; then
    echo "✅ Render configuration looks good"
else
    echo "❌ Missing required environment variables in render.yaml"
    exit 1
fi

# Step 4: Check database migration
echo "🗄️  Checking database migration..."
if [ ! -f "src/main/resources/db/migration/V1__create_tables.sql" ]; then
    echo "❌ Database migration file not found!"
    exit 1
fi
echo "✅ Database migration file found"

# Step 5: Test local build (optional - commented out to avoid database dependency)
# echo "🧪 Testing local application startup..."
# export SPRING_PROFILES_ACTIVE=dev
# timeout 30s ./gradlew bootRun > /dev/null 2>&1 &
# BOOT_PID=$!
# sleep 15
# if kill -0 $BOOT_PID 2>/dev/null; then
#     echo "✅ Application starts successfully"
#     kill $BOOT_PID
# else
#     echo "❌ Application failed to start"
#     exit 1
# fi

# Step 6: Git status check
echo "📝 Checking Git status..."
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: You have uncommitted changes"
    echo "   Consider committing your changes before deploying"
else
    echo "✅ All changes committed"
fi

echo ""
echo "🎉 Deployment verification complete!"
echo ""
echo "📋 Next steps for Render deployment:"
echo "1. Push your code to GitHub:"
echo "   git push origin main"
echo ""
echo "2. In Render dashboard:"
echo "   - Create new Web Service"
echo "   - Connect your GitHub repository"
echo "   - Select branch: main"
echo "   - Runtime: Docker"
echo "   - Use existing Dockerfile"
echo ""
echo "3. The render.yaml file will automatically configure:"
echo "   - Environment variables"
echo "   - Database connection"
echo "   - JVM settings optimized for Render free tier"
echo ""
echo "4. Your application will be available at:"
echo "   - Home page: https://your-app.onrender.com/"
echo "   - Person management: https://your-app.onrender.com/persons"
echo "   - Health check: https://your-app.onrender.com/actuator/health"
echo ""
echo "✅ Ready for deployment!"
