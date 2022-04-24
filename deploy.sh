#!/bin/bash

set -e
# a legújabb 3 releases/{datetime} mappa kivételével töröljük a releaseket (ha nincs 3-nál több, akkor nem töröl semmit)
echo "----------------------------"
cd ./releases
rm -rf ./deploying
#rollbacknél erre nevezi át a hibásat, és ha esetleg nem lett törölve
rm -rf ./failed
echo "Removing old releases..."
ls --sort t -r -l | grep -v total | awk '{print $9}' | head -n -3 | xargs rm -rf
echo "Removed"

# lehúzzuk a gitből a frissításeket
echo "----------------------------"
cd ..
cd ./repo
echo "git reset --hard origin/main in ./repo directory..."
git fetch --all
git reset --hard origin/main

git_hash=$(git rev-parse --short HEAD)
dir_datetime=$(date +'%Y%m%d_%H%M%S')
dir_name="${dir_datetime}_${git_hash}"
if [ "$1" == "fast" ]; then
  dir_name="${dir_name}_fast"
fi
echo "Git repo has been updated"

# composer, (ha nincs "fast" argument)
if [ "$1" != "fast" ]; then
  echo "----------------------------"
  echo "composer install..."
  ./../phptorun ./../composertorun install
  echo "composer done"
fi

# másolás a releases mappába a frissített repot mint deploying mappa
echo "----------------------------"
cd ..
echo "Copying ./repo directory to ./releases directory as ./releases/deploying..."
#.git mappa kivételével átmásoljuk a lehúzott fájlokat
rsync -avq --progress ./repo/ ./releases/deploying --exclude .git
echo "Copied"

# symlinkek készítések
echo "----------------------------"
cd ./releases/deploying
rm -f ./app/etc/env.php
rm -rf ./var
rm -rf ./pub/media
rm -rf ./pub/generated
ln -s ./../../../../shared/app/etc/env.php ./app/etc/env.php
ln -s ./../../../shared/pub/generated ./pub/generated
ln -s ./../../../shared/pub/media ./pub/media
ln -s ./../../shared/var ./var
echo "Symmlinks to ./shared/.. files/directories have been created"
dtstart=0
dtend=0
# Magento deploy műveletek (ha nincsen "fast" argument)
if [ "$1" != "fast" ]; then
  echo "----------------------------"
  echo "Magento operations are running..."
  dtstart=$(date +%s)
  ./../../phptorun -dmemory_limit=-1 ./bin/magento maintenance:enable
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:upgrade
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:static-content:deploy -f
  ./../../phptorun -dmemory_limit=-1 ./bin/magento maintenance:disable
  dtend=$(date +%s)
  echo "Magento operations have been finished"
else
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
fi
cd ../..

# Élesítjük az aktuális ./releases/${dir_name} mappát
echo "----------------------------"
mv ./releases/deploying ./releases/${dir_name}
echo "./releases/deploying directory has been renamed to ${dir_name}"
rm -f ./current
ln -s ./releases/${dir_name} ./current
echo "./current symlink has been attached to ./releases/${dir_name} directory"
echo "----------------------------"
echo "----------------------------"
echo "----------------------------"
echo "DEPLOYED SUCCESSFULLY (${dir_name})"
echo "----------------------------"
echo "----------------------------"
echo "----------------------------"
end=$(date +%s)
run_time=$((end - start))
dt_run_time=$((dtend - dtstart))
echo "Deployment: $(run_time) sec"
echo "Downtime: $(dt_run_time) sec"
