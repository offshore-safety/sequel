#! /bin/bash
source .env

bin/sequel -s tinytds://$UAT_DATABASE_USERNAME:$UAT_DATABASE_PASSWORD@nopperdbs02.corp.nopsa.gov.au/rms_uat \
              tinytds://nopsema:nopsema@$VAGRANT_URL/rms_development -t