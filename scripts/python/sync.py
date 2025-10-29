import subprocess, datetime, os
import os
import subprocess
import datetime

def sync_org_to_git():
    # Navigate to Salesforce project root (2 levels up from scripts/python/)
    project_folder = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    ORG_ALIAS = "TestOrg"    # 🔹 your Salesforce org alias
    BRANCH = "Dev-Branch"    # 🔹 your GitHub branch
    BASE_BRANCH = "master"     # 🔹 target branch for PR (adjust if different)

    try:
        # Step 1: Retrieve all metadata from Salesforce org using manifest
        subprocess.run(
            f"sf project retrieve start --target-org {ORG_ALIAS} --manifest manifest/package.xml",
            shell=True, check=True, cwd=project_folder
        )

        # Step 2: Stage changes
        subprocess.run("git add .", shell=True, check=True, cwd=project_folder)

        # Step 3: Commit only if changes exist
        result = subprocess.run("git diff --cached --quiet", shell=True, cwd=project_folder)
        if result.returncode != 0:  # non-zero = changes exist
            commit_msg = f"Sync from {ORG_ALIAS} on {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            subprocess.run(f'git commit -m "{commit_msg}"', shell=True, check=True, cwd=project_folder)
            subprocess.run(f"git push origin {BRANCH}", shell=True, check=True, cwd=project_folder)

            # Step 4: Create Pull Request using GitHub CLI
            pr_title = f"Sync from {ORG_ALIAS} - {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            pr_body = f"Automated sync from Salesforce Org **{ORG_ALIAS}** into branch `{BRANCH}`"
            subprocess.run(
                f'gh pr create --base {BASE_BRANCH} --head {BRANCH} --title "{pr_title}" --body "{pr_body}"',
                shell=True, check=True, cwd=project_folder
            )

            print(f"✅ Org '{ORG_ALIAS}' successfully synced and PR created from '{BRANCH}' → '{BASE_BRANCH}'!")
            return f"✅ Org '{ORG_ALIAS}' successfully synced and PR created from '{BRANCH}' → '{BASE_BRANCH}'!"
        else:
            print("⚡ No changes to commit.")
            return "⚡ No changes to commit."

    except subprocess.CalledProcessError as e:
        print(f"❌ Error: {e}")
        return f"❌ Error: {e}"

if __name__ == "__main__":
   sync_org_to_git()