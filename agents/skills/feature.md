# Feature Development Skill

Automates the complete feature development workflow from task description to release.

## Input

A task description that explains what needs to be implemented.

## Workflow

Execute these steps in sequence:

### 1. Create GitHub Issue

```bash
gh issue create --title "<short title>" --body "<task description>"
```

Extract the issue number from the response.

### 2. Create Branch

```bash
git checkout main
git pull origin main
git checkout -b <issue-number>-<short-kebab-case-name>
```

### 3. Implement Changes

- Make the required code changes
- Add RDoc documentation to new public classes and methods
- Run tests to verify: `bundle exec rspec`
- Fix any failing tests

### 4. Commit Changes

Follow atomic commit rules:
- One coherent change per commit
- Succinct commit message describing the change
- Include co-authors:
  ```
  Co-Authored-By: Leandro Marcucci <leanucci@gmail.com>
  Co-Authored-By: Claude <noreply@anthropic.com>
  ```

### 5. Push and Create PR

```bash
git push -u origin <branch-name>
gh pr create --title "<title>" --body "Closes #<issue-number>"
```

### 6. Wait for CI

```bash
gh pr checks <pr-number> --watch
```

If CI fails, fix the issues and push again.

### 7. Merge PR

```bash
gh pr merge <pr-number> --merge
```

### 8. Update CHANGELOG

Add entry to CHANGELOG under `[Unreleased]` section with:
- Short description of the change
- Reference to the issue/PR

### 9. Verify Release

The release workflow triggers automatically on merge to main.
Check that it succeeds:

```bash
gh run list --limit 1
```

## Output

Report:
- Issue URL
- PR URL
- Merge commit hash
- Release status
