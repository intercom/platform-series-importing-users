# platform-series-importing-users

The sample_data.rb script reads data from a CSV file.
The sample_data.rb script can be run as follows: <br>
` ruby sample_data.rb "CSV File" "APP ID" "API Key"`


The Sameple Data is located in the sample_data.csv file. <br>
This file contains sample data for <br>
1. Standard User Attributes <br>
2. Customer Attributes <br>
Multiple Custom Attributes can be separated in the CSV as follows <br>
`KEY1:VALUE1;KEY2:VALUE2` <br>
3. Events
Multiple Events can be seperated as follows: <br>
`EVENT::EVENT::EVENT` <br>
The script will select three random events from the list supplied to each user <br>
So, for example, if there is one event, it will be applied three times. <br>
4. Tags <br>
Multiple tags can be separated as follows: <br>
`TAG1::TAG2` <br>
5. Conversations <br>
The conversations listed in the CSV file represent the users input to conversations. <br>
i.e. There are no admin responses included in the CSV file. These are supplied in the <br>
sample_data.rb script via the admin_responses lists. The script will iterate through each <br>
user quote in the CSV file and then randomly select a random response from the admin_responses list. <br>
Remember, as with any input in the csv, if you do add more user input text to remove any commas from the text. <br>
Otherwise it will be treated as a new field.




