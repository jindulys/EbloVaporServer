# Eblo Server

This a server side app for my application Eblo, which is used to check tech company engineering blogs' update . It was built with Swift and backed by Vapor.

If you've ever checked some tech company's engineering blog, it's likely that you want to check them more often than you did. Some tech companys' engineering blogs are quite useful, they'd like to share their best practice, latest do & learn etc.

There is an awesome repo that collects quite a lot of those engineering blogs.

But still it is not easy for us to check whether there are some updates. Why not make it easy for us to know that there are something new and check them out!

You can think this app is a web crawler, it uses XPath to retrieve URL's information and save them to database. Thanks to Vapor it is also easy to provide routes to access those data.

# Run locally

To run this app locally, first you need to download and install Vapor. NOTE: This app is using Vapor 1. You can follow ray wenderlich's screencast.https://videos.raywenderlich.com/screencasts/509-server-side-swift-with-vapor-getting-started

This app is using POSTGRESQL as its database, so you need to install POSTGRESQL
   
    brew install postgres
    
This project is using swift package manager to manage its dependencies. 

    swift package reset
    swift package fetch
    swift package generate-xcodeproj
    open *.xcodeproj
    
Note: You might have some error about Kanna, follow that repo's instruction to install libs that are needed.

https://github.com/tid-kijyun/Kanna

Possibly you need
    
    brew install libxml2
    brew link --force libxml2
    brew install pkg-config

Build this app to see whether it can be compiled correctly.

Setup your local database

    psql -h localhost
    createdb yourdatabase
    
Then you can check you database

     psql
     \l  // check all your database
     \connect yourdatabase // connect to your database

At this time you are almost set, update your postgresql.json file to 

      {
        "host": "127.0.0.1",
        "user": "yourusername",
        "password": "",
        "database": "yourdatabase",
        "port": 5432
      }

Now you can run your project and check your logs. Also you can check through your browser by 

To run this:

     swift package update
     swift build
     ./.build/Debug/App
     
To start your postgres DataBase

    postgres -D /usr/local/var/postgres
    
Some useful commands:

    // To check your data base
    psql
    // then, for check all relations.
    \d 
    // check all database you have
    \l
    // connect to other data base
    \connect your_other_database
    // Show the schema for your table
    \d+ TABLENAME
    
    // Deploy your updates to heroku
    git push heroku master
    // Check heroku logs
    heroku logs
    
    // To clean up your database
    vapor build
    vapor run prepare --revert
    // To setup your database again
    run your project again.
    // Idk for why I need to manually delete company table.
    DROP TABLE IF EXISTS companys;
    DROP SEQUENCE IF EXISTS companys_id_seq;
    
    // To clean up your heroku database.
    heroku pg:reset DATABASE_URL
    // Then repush your code to heroku to restart the service.
    
## TODO List

 1. Add in cron job to fetch the new data everyday
 2. Create a company entity it self.
 3. For each new company xpath data, first create company entity, check whether or not we have parsed that company,
    then we can treat them differently, for those new fetch all the blogs, for those existed, only check updates.
 4. User login support.
 5. User fetch home page, pagination.
 6. Fav/Sav
 7. Search specific company's blog
 8. Topic learning.

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.

## 💧 Community

Join the welcoming community of fellow Vapor developers in [slack](http://vapor.team).

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.
