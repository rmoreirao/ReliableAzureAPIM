# Created this script because currently with Bicep ".bicepparam" files we cannot pass inline parameters 

import argparse

# Create the parser
parser = argparse.ArgumentParser(description="Replace placeholders in file")

# Add the arguments
parser.add_argument('--bicep_param_filename', type=str, required=True)
parser.add_argument('--bicep_param_output_filename', type=str, required=True)
parser.add_argument('--new_devops_password', type=str, required=True, help='The new password to replace {{DEVOPS_VMPASSWORD}}')
parser.add_argument('--new_pat', type=str, required=True, help='The new PAT to replace {{DEVOPS_PAT}}')
parser.add_argument('--new_jumpbox_password', type=str, required=True, help='The new password to replace {{JUMPBOX_VMPASSWORD}}')

# Parse the arguments
args = parser.parse_args()

file_path = args.bicep_param_filename
output_file_path = args.bicep_param_output_filename

# Read the content of the file
with open(file_path, 'r') as file:
    content = file.read()

# Replace {{DEVOPS_VMPASSWORD}} and {{DEVOPS_PAT}} with the new values
content = content.replace('{{DEVOPS_VMPASSWORD}}', args.new_devops_password)
content = content.replace('{{DEVOPS_PAT}}', args.new_pat)
content = content.replace('{{JUMPBOX_VMPASSWORD}}', args.new_jumpbox_password)

# Write the content to the new file
with open(output_file_path, 'w') as file:
    file.write(content)