rm -f deploying_deployed
rm -f deploying
touch deploying
cd releases

#ha beragadt esetleg
rm -rf ./deploying
echo "Removing old deploys\n"
# a legújabb 3 releases/ mappa kivételével töröljük a releaseket (ha nincs 3-nál több, akkor nem töröl semmit)
ls --sort t -r -l | grep -v total | awk '{print $9}' | head -n -3 | xargs rm -rf
echo "Removed\n"
cd ..

echo "git reset --hard origin/main... \n"
# lehúzzuk a legfrisebbet
cd ./repo
git fetch --all
git reset --hard origin/main
echo "git updated \n"
rm -f ./../deploying_git
mv ./../deploying ./../deploying_git

# composer
if [ $1 != "fast" ]
then
  echo "composer install...\n"
  ./../phptorun ./../composertorun install
  echo "composer done\n"
fi

rm -f ./../deploying_git_comp
mv ./../deploying_git ./../deploying_git_comp

# másolás a release mappába
cd ..
dir_name=$(date +'%Y%m%d_%H%M%S')
rm -rf releases/deploying
echo "copying repo directory to releases directory...\n"
#.git mappa kivételével átmásoljuk a lehúzott fájlokat
rsync -avq --progress ./repo/ ./releases/deploying --exclude .git
echo "copied\n"

# symlink készítések
rm -f ./deploying_git_comp_cp
mv ./deploying_git_comp ./deploying_git_comp_cp
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
echo "symmlinks to shared directory have been created\n"

rm -f ./../../deploying_git_comp_cp_syml
mv ./../../deploying_git_comp_cp ./../../deploying_git_comp_cp_syml

# Magento deploy műveletek, ha nincsen -fast paraméter
if [ $1 != "fast" ]
then
  echo "Magento deploy operations running...\n"
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:flush
  ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:upgrade
  ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:static-content:deploy -f
  echo "Magento done\n"
fi
cd ../..
rm -f ./deploying_git_comp_cp_syml_magentodeploy
mv ./deploying_git_comp_cp_syml ./deploying_git_comp_cp_syml_magentodeploy

# Élesítjük az aktuális repo mappát
mv ./releases/deploying ./releases/${dir_name}
echo "releases/deploying directory has been renamed to ${dir_name}"

rm -f ./current
ln -s ./releases/${dir_name} ./current
mv ./deploying_git_comp_cp_syml_magentodeploy ./deploying_deployed
echo "DEPLOYED\n"
