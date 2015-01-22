iOSReceiptValidationHelper
==========================

A simple iOS client that helps to retrieve receipts and the validation response from the iTunes Connect server.

Setup
-----

As this app must run on a physical device, there is a script that will setup up your project quickly and prevent the user from tediously typing out long keys and product ids. 

So save yourself the hassle and before running the application, open the terminal inside project's **root folder** and run the following.

```
./script/config.sh <application bundle> <itunes secret> [product id]
```

Where parameters are described as

- *application bundle* - Your application bundle id .
- *itunes secret* - The secret key found inside the in-app purchases section of iTunes Connect web portal.  
- *product id* - An **optional** parameter defining a product id created inside the in-app purchases section of iTunes Connect web portal.  

