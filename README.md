# pull_request_another_repository_action
This GitHub Action copies a folder from the current repository to a location in another repository and create a pull request

# Example Workflow
    name: Push File

    on: push

    jobs:
      pull-request:
        runs-on: ubuntu-latest
        steps:
        - name: Checkout
          uses: actions/checkout@v2

        - name: Generate test directory and file [optional]
          run: sh generate-test-file.sh

        - name: Create pull request
          uses: paygoc6/pull-request-another-repo-action@main
          env:
            API_TOKEN_GITHUB: ${{ secrets.API_TOKEN_GITHUB }}
          with:
            source_folder: 'target'
            destination_repo: 'paygoc6/repo-name'
            destination_folder: 'folder-name'
            destination_branch: 'branch-name'
            user_email: 'user-name@paygo.com.br'
            user_name: 'user-name'

# Variables
* source_folder: The folder to be moved. Uses the same syntax as the `cp` command. Incude the path for any files not in the repositories root directory.
* destination_repo: The repository to place the file or directory in.
* destination_folder: [optional] The folder in the destination repository to place the file in, if not the root directory.
* user_email: The GitHub user email associated with the API token secret.
* user_name: The GitHub username associated with the API token secret.
* destination_branch: The branch of the source repo to update. Can't be main or master.

# Behavior Notes
The action will create any destination paths if they don't exist. It will also overwrite existing files if they already exist in the locations being copied to. It will not delete the entire destination repository.
