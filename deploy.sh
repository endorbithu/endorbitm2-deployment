#!/bin/bash
set -e

# a legújabb 3 releases/{datetime} mappa kivételével töröljük a releaseket (ha nincs 3-nál több, akkor nem töröl semmit)
echo "----------------------------"
cd ./releases
rm -rf ./deploying
#rollbacknél erre nevezi át a hibásat, és ha esetleg nem lett törölve
rm -rf ./failed

# ha esetleg nem sikerült ezeket törölni
rm -rf ./var/.htaccess_removing
rm -rf ./var/.regenerate.lock_removing
rm -rf ./var/cache_removing
rm -rf ./var/composer_home_removing
rm -rf ./var/page_cache_removing
rm -rf ./var/vendor_removing
rm -rf ./var/view_preprocessed_removing
rm -rf ./var/.htaccess_deploying
rm -rf ./var/.regenerate.lock_deploying
rm -rf ./var/cache_deploying
rm -rf ./var/composer_home_deploying
rm -rf ./var/page_cache_deploying
rm -rf ./var/vendor_deploying
rm -rf ./var/view_preprocessed_deploying

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
rm -f ./app/etc/config.php
rm -rf ./pub/media
rm -rf ./pub/generated
ln -s ./../../../../shared/app/etc/env.php ./app/etc/env.php
ln -s ./../../../../shared/app/etc/config.php ./app/etc/config.php
ln -s ./../../../shared/pub/generated ./pub/generated
ln -s ./../../../shared/pub/media ./pub/media

echo "Symmlinks to ./shared/.. files/directories have been created"

# Magento deploy műveletek (ha nincsen "fast" argument)
if [ "$1" != "fast" ]; then
  echo "----------------------------"
  echo "Magento deploy operations running..."
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:flush
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:upgrade
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:static-content:deploy -f
  echo "Magento deploy operations has been finished"
fi
cd ../..

#a generált var/.. mappákat alkalmazzuk, ha nem fast
if [ "$1" != "fast" ]; then
  cd ./releases/deploying
  cp ./var/.htaccess ./../../shared/var/.htaccess_deploying
  cp ./var/.regenerate.lock ./../../shared/var/.regenerate.lock_deploying
  cp ./var/cache ./../../shared/var/cache_deploying
  cp ./var/composer_home ./../../shared/var/composer_home_deploying
  cp ./var/page_cache ./../../shared/var/page_cache_deploying
  cp ./var/vendor ./../../shared/var/vendor_deploying
  cp ./var/view_preprocessed ./../../shared/var/view_preprocessed_deploying

  rm -rf ./var
  ln -s ./../../shared/var ./var

  cd ./../../shared/var
  mv ./.htaccess ./.htaccess_removing
  mv ./.htaccess_deploying ./.htaccess

  mv ./.regenerate.lock ./.regenerate.lock_removing
  mv ./.regenerate.lock_deploying ./.regenerate.lock

  mv ./cache ./cache_removing
  mv ./cache_deploying ./cache

  mv ./composer_home ./composer_home_removing
  mv ./composer_home_deploying ./composer_home

  mv ./page_cache ./page_cache_removing
  mv ./page_cache_deploying ./page_cache

  mv ./vendor ./vendor_removing
  mv ./vendor_deploying ./vendor

  mv ./view_preprocessed ./view_preprocessed_removing
  mv ./view_preprocessed_deploying ./view_preprocessed
  cd ../..
fi

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
echo "DEPLOYED SUCCESSFULLY (${git_hash})"
echo "----------------------------"
echo "----------------------------"
echo "----------------------------"

echo "Remove old var directories.."
rm -rf ./var/.htaccess_removing
rm -rf ./var/.regenerate.lock_removing
rm -rf ./var/cache_removing
rm -rf ./var/composer_home_removing
rm -rf ./var/page_cache_removing
rm -rf ./var/vendor_removing
rm -rf ./var/view_preprocessed_removing
echo "Old var directories has been deleted"
echo "Done"
