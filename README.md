# Project 2: Shiny App Development Version 2.0

## Project Title: Citi Bike Helper
Term: Spring 2019

+ Group 1
+ Team members
	+ Huang, Shengwei:  sh3825@columbia.edu
	+ Liu, Sitong:  sl4460@columbia.edu
	+ Wang, Yujie:  yw3285@columbia.edu
	+ Yang, Zeyu: zy2327@columbia.edu
	+ Zhang, Zhicheng: zz2555@columbia.edu

+ **Project outcome**: 

 https://zyang.shinyapps.io/Citi_bike/

+ **Project summary**: 

This application mainly focuses on bringing convinence to bike users, and helping business operations.

Features:
1. Help bike users figure out the current bike station status
2. Offer bike users the best closest available bike stations
3. Give bike users bonus to encourage them to return bikes to the station with bike shortage
4. Present popular bike stations plot to help business with advertising
5. Provide updated empty bike stations to Citi bike

+ **Project highlight**(Business value added):
1. We used real time data to give the most updated information to bike users so that they can find the nearest bike station with available bike accurately.

2. We also updated the users interface, especially for our bike users so that they would find using our updated app more comfortably .(Below is the contrast before and after:) 

In our new interface, we added weather, temperature and also the updated time to provide our users useful information about: whether they should ride bike in such weather? Whether there are available bike station nearby?...

3. Besides for bike users, we also added one section for potential investor. We analyze the history data for each biker station and summarize the frequency of people come to that station to pick up or return Citi bikes. Then, we use data visualization techniques to provide our results on the map more directly so that for some investors who want to post any ads in the Manhattan, they could check our investor page for detailed information so that they could make appropriate decisions. 


+ **Contribution statement**: ([default](doc/a_note_on_contributions.md)) All team members contributed equally in all stages of this project. All team members approve our work presented in this GitHub repository including this contributions statement. 

_Huang, Shengwei_

-- Adjust and modify the base map page including fixing the zoom size, fitting the map to the entire webpage and etc.(output from Zeyu Yang)

-- Apply the google API to realize the address autocomplete in the search box on the biker user page(together with Zhicheng Zhang)

--  Read the last updated time from the data set(output from Zeyu Yang) and link the time to the users interface through the RenderText.

_Liu, Sitong_


_Wang, Yujie_

contribute to "for business" part:

-- use coordinates to locate the tract a station belongs to; group the stations by tract, calculate the average usage of bike in stations, and visualize the station popularity in tracts by different colors and popups(station popularity plot).  

-- apply real_time_data function(developed by Zeyu Yang) to visualize the stations running out of bikes(nearly empty station plot)

-- generate two interactive lists showing the data used for the two plots

_Yang, Zeyu_

-- Process real time data: real time station status data and real time weather data

-- Custom the base map with mapbox studio and draw the data points and pop up information to it

-- Develop the feature that returns the nearest available stations, if there are no available stations, then prompt a message

_Zhang, Zhicheng_

-- Adjust and stylize panels in bike user page, display expected time and distance(output from Zeyu Yang)

-- Use google API to realize search box address autocompletion in bike user page (together with Shengwei Huang)

-- Use write_csv to record email address entered by bike users (idea from Sitong Liu)


-------------------------------------------------------------------------------------------------
Following [suggestions](http://nicercode.github.io/blog/2013-04-05-projects/) by [RICH FITZJOHN](http://nicercode.github.io/about/#Team) (@richfitz). This folder is orgarnized as follows.

```
proj/
├── app/
├── lib/
├── data/
├── doc/
└── output/
```

Please see each subfolder for a README file.

