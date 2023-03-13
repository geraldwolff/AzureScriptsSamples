# policy

Must use powershell to create the policy definition with a seperate parameters file:

New-AzPolicyDefinition -Name 'ASNDefinition-Test' -Policy C:\repos\labz4all\policy\asntaggingdefinition.json -Parameter C:\repos\labz4all\policy\asntaggingdefinition.parameters.json
