# How to Upload to GitHub

## Step 1: Create GitHub Repository

1. Go to https://github.com and sign in
2. Click the "+" icon (top right) → "New repository"
3. Name your repository (e.g., "tfs-server" or "nostalrius-tfs")
4. Choose Public or Private
5. **DO NOT** check "Initialize with README" or add .gitignore/license
6. Click "Create repository"

## Step 2: Initialize Git and Commit Locally

Run these commands in the `/home/joriku/tfs` directory:

```bash
cd /home/joriku/tfs

# Initialize git repository
git init

# Add all files (respects .gitignore - won't add config.lua, logs, etc.)
git add .

# Check what will be committed (optional)
git status

# Create initial commit
git commit -m "Initial commit: TFS server with offline training system"
```

## Step 3: Connect to GitHub and Push

After creating the repository on GitHub, you'll see a page with instructions. Use these commands:

```bash
# Add GitHub as remote (replace YOUR_USERNAME and YOUR_REPO_NAME)
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git

# Rename branch to main (if needed)
git branch -M main

# Push to GitHub
git push -u origin main
```

**Note:** You'll be prompted for your GitHub username and password/token.

### If you need to use a Personal Access Token:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Generate new token (classic)
3. Give it "repo" permissions
4. Copy the token and use it as your password when pushing

## Alternative: Using SSH (Recommended for future)

If you set up SSH keys with GitHub:

```bash
git remote add origin git@github.com:YOUR_USERNAME/YOUR_REPO_NAME.git
git push -u origin main
```

## Verify Upload

After pushing, refresh your GitHub repository page. You should see all your files there (except config.lua, logs, and other ignored files).

## Important Notes

- ✅ `config.lua.dist` (template) will be uploaded
- ❌ `config.lua` (your actual config) will NOT be uploaded (protected by .gitignore)
- ❌ Compiled binary `tfs` will NOT be uploaded
- ❌ Log files will NOT be uploaded

