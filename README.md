# Getting Started

## Step 1
npm install

## Step 2

Install AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html  
Run the aws configure command in the terminal, enter the access key ID and secret access key, profile name, default region name and output format.   
Run the command export AWS_DEFAULT_PROFILE={profile name} in the terminal. Now this profile is configured as default profile in your system.  

## Step 3

Create a env file (dev.env/staging.env) in the config folder with appropriate details using the .env_example

## Step 4
	
To run the code, npm run {environment(dev/staging)}
