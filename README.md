# platform-series-importing-users

The sample_data.rb script reads data from a CSV file.
The sample_data.rb script can be run as follows:
ruby sample_data.rb "<CSV File>" "<APP ID>" "<API Key>"

The Sameple Data is located in the sample_data.csv file.
This file contains sample data for
1/ Standard User Attributes
2/ Customer Attributes
Multiple Custom Attributes can be separated in the CSV as follows
<KEY1>:<VALUE1>;<KEY2>:<VALUE2>
3/ Events
Multiple Events can be seperated as follows:
<EVENT>::<EVENT>::<EVENT>
The script will select three random events from the list supplied to each user
So, for example, if there is one event, it will be applied three times.
4/ Tags
Multiple tags can be separated as follows:
<TAG1>::<TAG2>
5/ Conversations
The conversations listed in the CSV file represent the users input to conversations.
i.e. There are no admin responses included in the CSV file. These are supplied in the
sample_data.rb script via the admin_responses lists. The script will iterate through each
user quote in the CSV file and then randomly select a random response from the admin_responses list.
Remember, as with any input in the csv, if you do add more user input text to remove any commas from the text.
Otherwise it will be treated as a new field.




