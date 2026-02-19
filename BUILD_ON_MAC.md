# Building Windows Application from macOS

Since Windows executables cannot be built directly on macOS, here are your options:

## Option 1: GitHub Actions (Recommended - Free & Easy)

### Setup Steps:

1. **Push your code to GitHub:**
   ```bash
   git add .
   git commit -m "Add Windows build workflow"
   git push
   ```

2. **Trigger the build:**
   - Go to your GitHub repository
   - Click on "Actions" tab
   - Select "Build Windows Application" workflow
   - Click "Run workflow" button
   - Wait for build to complete (5-10 minutes)

3. **Download the executable:**
   - After build completes, go to "Actions" tab
   - Click on the completed workflow run
   - Scroll down to "Artifacts"
   - Download `hackathon_app_windows.zip`
   - Extract and run `hackathon_app.exe`

### What's included:
- ✅ Automated Windows build
- ✅ No Windows machine needed
- ✅ Free (GitHub Actions free tier: 2000 minutes/month)
- ✅ Executable ready to download

---

## Option 2: Use a Windows VM (Local)

1. **Install VirtualBox or Parallels Desktop**
2. **Install Windows 10/11 in VM**
3. **Install Flutter SDK in Windows VM**
4. **Copy flutter folder to VM**
5. **Run build commands in VM**

---

## Option 3: Use Remote Windows Machine

1. **Rent a Windows cloud instance** (AWS, Azure, etc.)
2. **SSH/RDP into Windows machine**
3. **Clone your repository**
4. **Run build commands**

---

## Option 4: Use GitHub Actions via Web Interface

If you don't want to use git commands:

1. **Go to GitHub.com** → Create new repository (or use existing)
2. **Upload your flutter folder** via web interface
3. **Add the workflow file** (`.github/workflows/build-windows.yml`)
4. **Go to Actions tab** → Run workflow
5. **Download the artifact**

---

## Quick GitHub Actions Setup

The workflow file is already created at:
```
.github/workflows/build-windows.yml
```

Just push your code to GitHub and the workflow will be available!

---

## Alternative: Build for macOS Instead

If you want to test locally, you can build for macOS:

```bash
cd flutter
flutter build macos --release
```

The macOS app will be at:
```
build/macos/Build/Products/Release/hackathon_app.app
```

---

## Need Help?

- GitHub Actions docs: https://docs.github.com/en/actions
- Flutter Windows docs: https://docs.flutter.dev/deployment/windows

