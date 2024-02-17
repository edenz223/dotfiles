import os
import sys
import subprocess
import argparse

def execute_command(cmd):
    try:
        subprocess.check_output(cmd)
        print(f'Successfully executed command: {cmd}')
    except subprocess.CalledProcessError as e:
        sys.exit(f'Error: {str(e)}')

def git_operations(branch_name, checkout_branch):
    # Checkout to dev branch or other specified branch, pull the newest code, create and checkout to new branch
    commands = [['git', 'checkout', checkout_branch], 
                ['git', 'pull'], 
                ['git', 'checkout', '-b', branch_name]]

    for cmd in commands:
        execute_command(cmd)

    print("Operation completed successfully!")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("branch_name", help="Name of the new branch to create.")
    parser.add_argument("-c", "--checkout_branch", default='dev', help="Name of the branch to checkout to and pull from. Defaults to 'dev'.")
    args = parser.parse_args()

    git_operations(args.branch_name, args.checkout_branch)