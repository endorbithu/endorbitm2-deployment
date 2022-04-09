rm -rf deployed


#lehúzzuk a legfrisebbet
cd ./repo
git fetch --all
git reset --hard origin/main
./../phptorun ./../composertorun install

cd ..
dir_name=$(date +'%Y%m%d_%H%M%S')

rm -rf releases/repo/
#.git mappa kivételével átmásoljuk a lehúzott fájlokat (ez elég lassú lehet a cp és után aa .git mappa törlése jobb lenne)
rsync -avq --progress ./repo ./releases --exclude .git

cd ./releases/repo

rm -f ./app/etc/env.php
rm -f ./app/etc/config.php
rm -f ./var
rm -f ./pub/media
rm -f ./pub/generated

ln -s ./../../../../shared/app/etc/env.php ./app/etc/env.php
ln -s ./../../../../shared/app/etc/config.php ./app/etc/config.php
ln -s ./../../../shared/pub/generated ./pub/generated
ln -s ./../../../shared/pub/media ./pub/media
ln -s ./../../shared/var ./var

 ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:flush
 ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
 ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
 ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:upgrade
 ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:static-content:deploy

cd ../..

rename ./releases/repo ./releases/${dir_name}
unlink ./current
ln -s ./releases/${dir_name} ./current
