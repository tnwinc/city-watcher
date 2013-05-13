Version of app running here: http://citywatcher.azurewebsites.net/watcher.html

Add your setup after the hash. The setup is a json document as below:
```json

[ 
  { 
    "protocol" : "http", 
    "address" : "10.32.10.31", 
    "friendlyName" : "Unicorn Build", 
    "buildTypes" : [ "bt71", "bt31" ] 
  },
  { 
    "protocol" : "http", 
    "address" : "10.32.2.99", 
    "friendlyName" : "Fish Builds", 
    "buildTypes" : [ "bt15" ] 
  } 
]
```
For example:
```html
http://citywatcher.azurewebsites.net/watcher.html#[ { "protocol" : "http", "address" : "10.32.10.31", "friendlyName" : "Unicorn Build", "buildTypes" : [ "bt71", "bt31" ] }, { "protocol" : "http", "address" : "10.32.2.99", "friendlyName" : "Fish Builds", "buildTypes" : [ "bt15" ] } ]
```

#Upcoming Features
* Hiding of successful builds optional
* Hiding of stale builds optional
* Hiding of Server names optional
* Hiding of build names optional
* Number of days to look back configurable in url
* Add configuration UI
* Add tests
* Refactor data gathering bits to make it clearer
