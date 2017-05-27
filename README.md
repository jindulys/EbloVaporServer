# Eblo Vapor Server

This is my Eblo(Engineering Blogs App) Server, backed by wonderful vapor.

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
