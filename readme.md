#Features
* Make hiding of successful builds optional
* Make hiding of stale builds optional
* Make hiding of Server names optional
* Make hiding of build names optional

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
