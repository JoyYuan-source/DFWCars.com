# DFWCars.com
## Scope of the Project 
The website will provide users (students) to buy and sell cars in the DFW area. The users are provided with options to input their personal information, preferences and budget into the application, and the algorithm behind will return recommendations. Students are provided with insights of the nearest dealers and private sellers including their rating, location, and a history of their vehicles sales.  The website provides students with the cars’ information that best fit their needs as below : 

● Customer: Student ID, budget, preference (make, model, year...etc.) 
● Location: Longitude, Latitude, zip code, City, School 
● Cars: VIN #, manufacture, model, year, features, Carfax report, mileage, type 
● Price: fair price, sale price 
● Recommendation: dealer rating, customer feedback 

## Goals of the Project 
The intended users for this database are students including international students from different universities  and different dealerships in the DFW area. The database will facilitate the process of buying a car for international students attending universities in the US. The application will increase efficiency in the car search by providing a special feature that enables verified students to get special promotions, and offer the eligibility of payment plan without the need of social security number.  This application benefits the dealers as well , since it assists in generating more revenues by increasing their car sales.

## Dataset 
The data used in our project was found on Kaggle – Kaggle Data. Since the dataset was not exhaustive, we had to generate a database demo and merge it with the original dataset from Kaggle. However,  Latitude, Longitude and Student ID was generated due to privacy measures. 

## ER-Diagram 
We have three main tables including student, vehicle information and dealer information in the ER-Diagram.

1-The student table: consists of student id and the student password to log into the application. Student Id is the primary key of the student table and the foreign key for the Order table. When a student signs up for the system, the UI generates a unique password for them. 

2-The Vehicle Info table:  has the VIN as its primary key. Based on the primary key, we can get the details of the cars. Dealers can list their cars by inputting price, year, manufacturer, make, odometer, paint color and even attach an image of the car. Once the car is listed into the database, it will automatically upload as part of the inventory and then when a customer makes an order it will be removed from the list of cars available and moved to the orders table. 

3-The dealer information table: uses Dealer_ID as its primary key and connects with the other two tables as a foreign key. The dealer information tables contain details pertaining to the seller of the car. Besides having personal information from the dealer in order to contact them, the table contains the physical location of the car (latitude and longitude). 

In addition, we included a car check table that allows buyers to make a check of the title status, condition, report and score of the car. This table was created in order to promote the security of the buyer and prevent any potential illegal origin, stolen cars, unauthorized software, etc. 


## Shiny/UI 
We designed a Shiny application that interacts with MySQL database and performs CRUD operations. We read data from MySQL database and used R to analyze car data. The functions of the Shiny application are listed below. 

Two accounts: In our dashboard, we designed two types of user accounts. One is for administrator, the other is for customers. The administrator has access to all the car data in database and can edit, delete any information. The customer account is for end users where they can search and enter new car’s information.  

Two search functions: two search functions where we allow our users to do some basic search operations. The “Buy a car” enables customers to enter any specs of the car they want. The “Sell a car” enables customer to enter any information of the car they want to sell.  

Insert, Update, and Delete functions: The insert function enables internal users to add a car with detailed information: name of the car, year, price, manufacture, and image URL. Besides, we also created update function, where users can edit the information they entered before. 

Finally, delete function could be used to delete any car by administrator. Once the car is sold, the information related to this car will be automatically deleted from vehicle database and pasted to order database. However, due to security control, external users are not allowed to delete any cars. 
