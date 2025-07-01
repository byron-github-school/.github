# Pull Project Tasks Workflow - URL Replacement Fix

This document explains the changes made to fix the URL replacement issue in the `pull-project-tasks` workflow.

## Problem

The original workflow copied issues and sub-issues from a source repository to a target location, but all URLs in the copied issues still pointed to the source repository instead of the target repository.

## Solution

The workflow has been updated to:

1. **Parameterize repository information**: Added input parameters for both source and target repositories
2. **Copy issues to target repository**: Creates new issues in the target repository instead of just linking existing ones
3. **Replace URLs**: Updates all GitHub URLs in issue bodies to point to the target repository
4. **Maintain relationships**: Preserves parent-child relationships using the new target issue numbers

## New Input Parameters

| Parameter | Description | Required | Example |
|-----------|-------------|----------|---------|
| `source_owner` | Owner of the source repository | Yes | `im-infomagnus` |
| `source_repo` | Name of the source repository | Yes | `ms-code-with-engineering-playbook` |
| `target_owner` | Owner of the target repository | Yes | `my-org` |
| `target_repo` | Name of the target repository | Yes | `my-project` |
| `org_name` | Organization containing the project | Yes | `my-org` |
| `project_name` | Name of the GitHub Project | Yes | `My Project` |
| `pat_secret` | Secret containing the PAT | Yes | `MY_PAT_SECRET` |

## Workflow Steps

1. **Fetch Issues and Build Full Hierarchy**: Analyzes the source repository to identify parent-child relationships
2. **Copy Issues to Target Repository and Update URLs**: Creates new issues in the target repository with updated URLs
3. **Add Issues to GitHub Project and Maintain Relationships**: Adds the new issues to the specified project
4. **Update Parent Issues with Child Links**: Updates parent issues with links to their children using target repository URLs

## URL Replacement

The workflow automatically replaces:
- Issue URLs: `https://github.com/source-owner/source-repo/issues/123` → `https://github.com/target-owner/target-repo/issues/456`
- Pull request URLs: `https://github.com/source-owner/source-repo/pull/123` → `https://github.com/target-owner/target-repo/pull/456`
- File URLs: `https://github.com/source-owner/source-repo/blob/main/file.md` → `https://github.com/target-owner/target-repo/blob/main/file.md`

## Usage Example

```yaml
name: Copy Issues
on:
  workflow_dispatch:
    inputs:
      source_owner:
        description: 'Source repository owner'
        required: true
        default: 'im-infomagnus'
      source_repo:
        description: 'Source repository name'
        required: true
        default: 'ms-code-with-engineering-playbook'
      target_owner:
        description: 'Target repository owner'
        required: true
        default: 'my-organization'
      target_repo:
        description: 'Target repository name'
        required: true
        default: 'my-project'
      org_name:
        description: 'Organization name'
        required: true
        default: 'my-organization'
      project_name:
        description: 'Project name'
        required: true
        default: 'Engineering Playbook'
      pat_secret:
        description: 'PAT secret name'
        required: true
        default: 'PROJECT_PAT'
```

## Verification

After running the workflow:

1. Check that new issues are created in the target repository
2. Verify that URLs in issue bodies point to the target repository
3. Confirm that parent-child relationships are maintained
4. Ensure issues are added to the specified GitHub Project

The workflow ensures that all URLs resolve to valid objects in the target repository, achieving the success criteria outlined in the original issue.