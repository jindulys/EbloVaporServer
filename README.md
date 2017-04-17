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
    // connect to other data base
    \connect your_other_database
    
    // Deploy your updates to heroku
    git push heroku master
    // Check heroku logs
    heroku logs
    
    // To clean up your database
    vapor build
    vapor run prepare --revert
    // To setup your database again
    vapor run prepare

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.

## 💧 Community

Join the welcoming community of fellow Vapor developers in [slack](http://vapor.team).

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.
