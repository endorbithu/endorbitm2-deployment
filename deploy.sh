#lehúzzuk a legfrisebbet
cd ./repo
git pull
cd ..
dir_name=$(date +'%Y%m%d_%H%M%S')
#.git mappa kivételével átmásoljuk a lehúzott fájlokat
rsync -av --progress repo /${dir_name} --exclude .git
cd ./releases/${dir_name}

rm ./app/etc/env.php
rm -rf ./var
rm -rf ./pub/media
rm -rf ./pub/generated

ln -s ./../../shared/app/etc/env.php ./app/etc/env.php
ln -s ./../../shared/pub/generated ./pub/generated
ln -s ./../../shared/pub/media ./pub/media
ln -s ./../../shared/var ./var

./phptorun composer install

./phptorun -dmemory_limit=-1 bin/magento cache:flush
./phptorun -dmemory_limit=-1 bin/magento cache:clean
./phptorun -dmemory_limit=-1 bin/magento setup:di:compile
./phptorun -dmemory_limit=-1 bin/magento setup:static-content:deploy
./phptorun -dmemory_limit=-1 bin/magento setup:upgrade
cd ../..

unlink ./current
ln -s ./releases/${dir_name} ./current
