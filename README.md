# Lets Rails

This is a sample Rails application that talks to a backend API instead talking directly to a database.  It is a simple version of [letsbonus.com](http://letsbonus.com)

## Install

You need to install Ruby 1.9.3, Bundler, Redis, MySQL and Memcached.  You also to to setup and have the [Lets Rails API](http://github.com/livingsocial/letsrails-api) running.  Once you have that working, you run this app with:

    $ bundle
    $ foreman start
    
Then you should be able to see the site at [http://localhost:3000](http://localhost:3000)