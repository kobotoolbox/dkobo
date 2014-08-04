#!/bin/sh

# usage:
# On your local installation, you can source this script to set debug 
#   source scripts/set_debug.sh true 
#      ^ sets debug values to true
#   source scripts/set_debug.sh ...anything but true
#      ^ sets debug values to false
# To set debug values on production, run "heroku configs:set DJANGO_DEBUG=False"

if [ $# -eq 0 ]; then
  echo ""
  echo "# scripts/set_debug.sh"
  echo "Usage:"
  echo ""
  echo "  LOCAL:  source scripts/set_debug.sh true"
  echo "  LOCAL:  source scripts/set_debug.sh false"
  echo ""
  echo "  HEROKU: sh scripts/set_debug.sh --heroku true"
  echo "  HEROKU: sh scripts/set_debug.sh --heroku false"
  echo ""
else
  if [ "$1" = "--heroku" ]; then
    HEROKU_INSTRUCTIONS = 1
    echo "To set debug mode on heroku, run the following commands"
    if [ "$2" = "true" ]; then
      echo "# heroku configs:set DJANGO_DEBUG=True --app=<your-heroku-app-name-here>"
      echo "# heroku configs:set DJANGO_SECRET_KEY=<secret-key-here> --app=<your-heroku-app-name-here>"
      echo "# heroku configs:set COMPRESS_ENABLED= --app=<your-heroku-app-name-here>"
    else
      echo "# heroku configs:set DJANGO_DEBUG=False --app=<your-heroku-app-name-here>"
    fi
  else
    if [ "$1" = "true" ]; then
    	export DJANGO_DEBUG=True
        export COMPRESS_OFFLINE=False
        export COMPRESS_ENABLED=False
    	export DJANGO_SECRET_KEY=AnOtSoSeCrEtKeY
    	export COMPRESS_ENABLED=False
    	echo "local debug mode set to true"
    else
    	export DJANGO_DEBUG=False
        export COMPRESS_OFFLINE=True
        export COMPRESS_ENABLED=True
    	export DJANGO_SECRET_KEY=AnOtSoSeCrEtKeY
    	export COMPRESS_ENABLED=True
    	echo "local debug mode set to false"
    fi
  fi
fi