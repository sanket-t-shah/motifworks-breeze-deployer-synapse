# What is this Project all about?
The purpose of this Project / demo is to show how you can use combination of ARM Templates and PowerShell along with Azure CLI / `az cli` to deploy BREEZE Framework of Motifworks.

# What will get deployed?
1. Azure Infra Resources - Resource Group, Storage Account, Azure Synapse Workspace, Azure Synapse Dedicated Pool.
2. Synapse Resources:
2.1 Schema, Tables and Stored Procedures
2.2 Integration Datasets
2.3 Python Notebook
2.4 Integration Pipelines

# I am nervous. Can I see a Video?
Sure. I can handle your nervousness well. You need to be slight techy and have Azure Knowledge to understand this. You can see two Videos here:

## Create Full Environment
https://github.com/sanket-t-shah/motifworks-breeze-deployer-synapse/assets/7502469/b0b2f7fb-8c1e-4bbe-aed0-c9e75a1fc876

## Destroy Full Environment
https://github.com/sanket-t-shah/motifworks-breeze-deployer-synapse/assets/7502469/d88b128e-2bdd-478e-b715-5cf7a8df4535

# I want to run it now!!!
Wow. Welcome to the world of wonders. Once you've the toolchain installed, you can jump into `src` folder and run `deployer.ps1`.

Online step-by-step guide is available on the screen itself.

# Am comfortable now. What I need to get started?
First things first, you need to have following toolchain installed:
1. [PowerShell Core](https://github.com/PowerShell/PowerShell/releases) 
2. [Azure CLI](https://github.com/Azure/azure-cli/releases)
3. [sqlcmd](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16#download-and-install-sqlcmd)
4. [VS Code](https://code.visualstudio.com/download)

Clone this GitHub repo and you should be good to go!!!

# I want to deploy BREEZE through GitHub and then deploy BREEZE Synapse Assets from local computer
You are all welcome for this. It is a two-step process:
1. Deploy Template (click link below)
2. Run PowerShell Script - `src/deployer.ps1` and select Option 2. You'll need to put in your values that you provided earlier in Step 1 above.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fgithub.com%2Fsanket-t-shah%2Fmotifworks-breeze-deployer-synapse%2Fraw%2Fmain%2Fsrc%2Fazuredeploy.json)

# I want to say thanks!!!
I would love to hear it along with good comments and obviously necessary feedback. Drop me a note on my personal Email ID.
