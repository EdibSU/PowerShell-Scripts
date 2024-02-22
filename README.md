# PowerShell-Scripts
Collection of utility functions in PowerShell to stream line work with local DataMiner agent.

Configure DisableNetAdapter default parameter to include names of the all network adapters you need to disable in order to start DataMiner. If you need them reenabled configure EnableNetAdapter with the same default values. 

If you installed DataMiner somewhere other than the default location, you need to configure other functions as well to point to appropriate files.

Open PowerShell as administrator and call StartDM. That's it, your DataMiner agent should begin to start up. All DM functions require privileged PowerShell.