rm -rf deployed
touch start
cd releases

#ha beragadt esetleg
rm -rf ./deploying
# a legújabb 3 releases/ mappa kivételével töröljük a releaseket (ha nincs 3-nál több, akkor nem töröl semmit)
ls --sort t -r -l | grep -v total | awk '{print $9}' | head -n -3 | xargs rm -rf
cd ..

# lehúzzuk a legfrisebbet
cd ./repo
git fetch --all
git reset --hard origin/main
mv ./../start ./../start_git

# composer
./../phptorun ./../composertorun install
mv ./../start_git ./../start_git_comp

# másolás a release mappába
cd ..
dir_name=$(date +'%Y%m%d_%H%M%S')
rm -rf releases/deploying

#.git mappa kivételével átmásoljuk a lehúzott fájlokat
rsync -avq --progress ./repo/ ./releases/deploying --exclude .git

# symlink készítések
mv ./start_git_comp ./start_git_comp_cp
cd ./releases/deploying
rm -f ./app/etc/env.php
rm -f ./app/etc/config.php
rm -rf ./var
rm -rf ./pub/media
rm -rf ./pub/generated
ln -s ./../../../../shared/app/etc/env.php ./app/etc/env.php
ln -s ./../../../../shared/app/etc/config.php ./app/etc/config.php
ln -s ./../../../shared/pub/generated ./pub/generated
ln -s ./../../../shared/pub/media ./pub/media
ln -s ./../../shared/var ./var
mv ./../../start_git_comp_cp ./../../start_git_comp_cp_syml

# Magento deploy műveletek, ha nincsen -fast paraméter
if [ $1 != "fast" ]
then
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:flush
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:upgrade
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:static-content:deploy -f
fi
cd ../..
mv ./start_git_comp_cp_syml ./start_git_comp_cp_syml_mag

# Élesítjük az aktuális repo mappát
mv ./releases/deploying ./releases/${dir_name}
rm -f ./current
ln -s ./releases/${dir_name} ./current
mv ./start_git_comp_cp_syml_mag ./deployed
