# Template repository

This repository can be used to store workflow templates. As long as this repository is **Public**, the workflow templates will show up in the Starter workflow overview of other repositories in the same organization :tada:

:exclamation: **This is a template repository**
- Please click ***Use this template*** to clone the repo into a different organization that you own

  ## In this repo:
  - .github/workflows/pull-project-tasks.yml
    This workflow will copy issues with subissues from a source repo/project to target repo/target.
    Execute this workflow manually.
    inputs:
      org_name:
        description: 'The name of the GitHub Organization containing the project'
        required: true
        default: ''
      project_name:
        description: 'The name of the GitHub Project to update'
        required: true
        default: ''
      source_owner:
        description: 'The owner of the source repository'
        required: true
        default: 'im-infomagnus'
      source_repo:
        description: 'The name of the source repository'
        required: true
        default: 'ms-code-with-engineering-playbook'
      target_owner:
        description: 'The owner of the target repository'
        required: true
        default: ''
      target_repo:
        description: 'The name of the target repository'
        required: true
        default: ''
      pat_secret:
        description: 'The name of the secret containing the PAT'
        required: true
        default: ''

    Note: The PAT needs access to both the source and target orgs/repos
  - Supporting Actions yamls and scripts
 
    
    
