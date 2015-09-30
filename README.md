# Cloudant
###Import data from a Cloudant database into SPPS Modeler

This node allows you to import data from a Cloudant database to be used in IBM SPSS Modeler.  You can retrieve a dump of the whole database, retrieve a document from its ID or perform a query using a preset view.  In order to use this node you must have a Bluemix account with the Cloudant service added.  By adding this service you will create “host” credentials that are needed by this node.  After adding the service in Bluemix you can access the Cloudant dashboard to create or update databases.    

![Diaglog](https://github.com/IBMPredictiveAnalytics/Cloudant/blob/master/Screenshot/Illustration3_Dialog2.png?raw=true)

---
Requirements
----
-  IBM SPSS Modeler v16 or later
-  ‘R Essentials for SPSS Modeler’ plugin: [Download here][7]
-  R 2.15.x or R 3.1
-  A Bluemix account with Cloudant activated either as a service or as part of an application

---
Installation
----

1. Download the extension: [Download][3] 
2. Close IBM SPSS Modeler. Save the .cfe file in the CDB directory, located by default on Windows in "C:\ProgramData\IBM\SPSS\Modeler\16\CDB" or under your IBM SPSS Modeler installation directory.
3. Restart IBM SPSS Modeler, the node will now appear in the Record Ops palette.

---
R Packages used
----
The R packages will be installed the first time the node is used as long as an Internet connection is available.
-  [plyr][4]
-  [R4CouchDB][9]
-  [RCurl][10]

---
License
----

[Apache 2.0][1]


Contributors
----

  - Armand Ruiz ([armand_ruiz](https://twitter.com/armand_ruiz))



[1]: http://www.apache.org/licenses/LICENSE-2.0.html
[3]: https://github.com/IBMPredictiveAnalytics/Cloudant/blob/master/Source%20Code/Cloudant.cfe
[4]:https://cran.r-project.org/web/packages/plyr/
[7]:https://developer.ibm.com/predictiveanalytics/downloads/#tab2
[8]: https://developer.ibm.com/predictiveanalytics/downloads/
[9]: https://cran.r-project.org/web/packages/R4CouchDB/
[10]: https://cran.r-project.org/web/packages/RCurl/index.html
