<h3 align="center">
    <img src="Images/eblo.png" width=540 alt="Ji: a Swift XML/HTML parser" />
</h3>

# Eblo Server

This a server side app for my application **Eblo**, which is used to check tech company engineering blogs. It was built with Swift and backed by **Vapor**.

If you've ever checked some tech company's engineering blog, it's likely that you want to check them more often than you did. Some tech companys' engineering blogs are quite useful, they'd like to share their best practice, latest do & learn etc.

[This awesome repo](https://github.com/kilimchoi/engineering-blogs) collects quite a lot of those engineering blogs.

But still it is not easy for us to check whether there are updates. Why not make it easy for us to know that there are something new and check them out! You can think this app is a web crawler, it uses XPath to retrieve URL's information and saves them to database. Thanks to Vapor it is quite easy to provide access to those data through routing so you can get those information and develop your own app.

I also built an [iOS client app](https://github.com/jindulys/Eblo) which consumes data from this server app.

![](https://raw.githubusercontent.com/jindulys/EbloVaporServer/master/Images/doublelog.png)

Also you can check by using this [URL](https://ebloserver.herokuapp.com/blog/test) to see the prod data I generated.

<img src="https://raw.githubusercontent.com/jindulys/EbloVaporServer/master/Images/localhostjson.png" alt="logone" title="logone" width="500"/>

# Run locally

To run this app locally, first you need to download and install Vapor. NOTE: This app is using Vapor 1. You can follow [ray wenderlich's screencast](https://videos.raywenderlich.com/screencasts/509-server-side-swift-with-vapor-getting-started) to finish this step.

This app uses POSTGRESQL as its database, so you need to install **POSTGRESQL** first.
```bash
brew install postgres
postgres -D /usr/local/var/postgres // start your postgresql database service
```
Clone this repo to your computer.

    git clone https://github.com/jindulys/EbloVaporServer.git

Dependency management is via swift package manager, run. 
```bash
swift package reset
swift package fetch
swift package generate-xcodeproj
open *.xcodeproj
```
    
Note: You might encounter some error related to Kanna, follow it [instruction](https://github.com/tid-kijyun/Kanna) to install libs that are needed. Possibly you need
```bash  
brew install libxml2
brew link --force libxml2
brew install pkg-config
```
**Build** this app to see whether it can be compiled correctly.

Before run this app, you need to setup your local database

    psql -h localhost
    createdb yourdatabase
    
Then you can check you database

     psql
     \l  // check all your database
     \connect yourdatabase // connect to your database

At this time one more step:  update your [**postgresql.json**](/Config/secrets.postgresql.json) file's content to 
```JSON
{
  "host": "127.0.0.1",
  "user": "yourusername",
  "password": "",
  "database": "yourdatabase",
  "port": 5432
}
```

Now you can change target to **App** build and run your project and check your logs. Also you can check through your browser by http://localhost:8080/blog/article

<img src="https://raw.githubusercontent.com/jindulys/EbloVaporServer/master/Images/localhost.png" alt="logone" title="logone" width="600"/>

# Run remotely

You can follow ray wenderlich's screencast to deploy your repo to **Heroku**.

You need to update your [**postgresql.json**](/Config/secrets.postgresql.json) file's content to
```JSON
{
  "url": "yourherokupostgresqlURL",
  "user": "username",
  "password": "",
  "database": "databasename",
  "port": 5432
}
```
      
# Useful tips for your development
     
Database related
```psql
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
```
    
Heroku related
    
    // Deploy your updates to heroku
    git push heroku master
    // Check heroku logs
    heroku logs -n 1500
    // To clean up your heroku database.
    heroku pg:reset DATABASE_URL
    // Then repush your code to heroku to restart the service.
    
Sometimes you need you cleanup your database, you need the following.
    
    // Vapor clean up your database
    vapor run prepare --revert
    // Idk for why the revert step does not cleanup throughly, I need to manually delete my other tables.
    DROP TABLE IF EXISTS companys;
    DROP SEQUENCE IF EXISTS companys_id_seq;
    
    // Then to setup your database again
    // build and run your project again.
    
## TODO List

 - [ ] more companies
 - [ ] RSS feeds
 - [ ] User login support
 - [ ] Topic learning

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package.

## 💧 Community

You can join the wechat group if you are intrested.

<img src="https://raw.githubusercontent.com/jindulys/EbloVaporServer/master/Images/wechat.JPG" alt="logone" title="logone" width="300"/>

