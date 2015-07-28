# Dkobo.

[![Build Status](https://travis-ci.org/kobotoolbox/dkobo.svg)](https://travis-ci.org/kobotoolbox/dkobo)

*A django project for developing components of the KoBoToolbox, including the new version of KoBoForm.*

## Installation / Building a Docker image

    git clone git@github.com:kobotoolbox/dkobo.git
    cd dkobo
    docker build -t dkobo .

## Launching the server / Running a Docker container

    docker run -d --name dkobo_container -p 5000:5000 dkobo
    boot2docker ip

## Production environment variables

    DJANGO_DEBUG=False
    DJANGO_SECRET_KEY=<use a unique django secret key here>
    
    The server should run in development / debug mode by default, but if you want to change it you can run the command

    `source scripts/set_debug.sh true` #sets development mode

or

    LOCAL:  source scripts/set_debug.sh true
    LOCAL:  source scripts/set_debug.sh false
    HEROKU: sh scripts/set_debug.sh --heroku true
    HEROKU: sh scripts/set_debug.sh --heroku false
    `source scripts/set_debug.sh false` #sets production mode

## Grunt commands

### grunt (no arguments)

  _default task: triggers `requirejs:compile_xlform`, `build_css`, and `watch` for changes_

### grunt build

  _triggers `requirejs:compile_xlform`, `build_css`_
  * Creates js and css dependencies

### grunt build_all

  * Used when launching production
  * Runs `build` and generates modernizr.js file for use when django is not in debug mode.

### grunt build_css

  * Runs `sass:dist`, `cssmin:strip_duplicates`, `cssmin:dist`

### grunt test

  * Runs `build`, `karma:unit`
