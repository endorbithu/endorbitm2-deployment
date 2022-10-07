#!/bin/bash
#TODO: ha bármilyen upgradeSchema UpgradeData változás van, annál nem lehet rollbackelni, mert a schemát is vissza kéne
#állítani, ezt valahogy ebben a scriptben ellenőrizni kell!
set -e
start=$(date +%s)
cd ./releases
#ha nem lett valamiért törölve a ./failed mappa, azt mindenképp törölni kell, mert különben hozzáadj aa meglévő release számhoz
rm -rf ./failed

releaseCount=$(ls -lr | grep -v total | wc -l)
if [ "$releaseCount" -ge "2" ]; then
  #itt a második legújabb mappára kell tenni symlinkelni
  rollback_dir=$(ls -lr | grep -v total | awk '{print $9}' | head -n 2 | awk '(NR>1)')
  cd ..
  rm -f ./current
  ln -s ./releases/${rollback_dir} ./current
  dtstart=0
  dtend=0
  fast='_fast'
  if [[ "$rollback_dir" != *"$fast" ]]; then
    echo "Magento operations are running..."
    cd ./current
    dtstart=$(date +%s)
    ./../../phptorun -dmemory_limit=-1 ./bin/magento maintenance:enable
    ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
    ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:upgrade
    ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:di:compile
    ./../../phptorun ./../../composertorun dump-autoload -o
    ./../../phptorun -dmemory_limit=-1 ./bin/magento setup:static-content:deploy -f
    ./../../phptorun -dmemory_limit=-1 ./bin/magento maintenance:disable
    dtend=$(date +%s)
    echo "Magento operations have been finished"
    cd ..
  else
    cd ./current
    ./../../phptorun -dmemory_limit=-1 ./bin/magento cache:clean
    cd ..
  fi

  echo "----------------------------"
  echo "----------------------------"
  echo "----------------------------"
  echo "ROLLBACKED SUCCESSFULLY"
  echo "----------------------------"
  echo "----------------------------"
  echo "----------------------------"
  echo "Removing failed (newest) release..."
  cd ./releases
  # törli a legújabb mappát a releases-ben
  #ls --sort t -l | grep -v total | awk '{print $9}' | head -n 1 | xargs rm -rf
  failed_dir=$(ls --sort t -l | grep -v total | awk '{print $9}' | head -n 1)
  mv ./${failed_dir} ./failed
  rm -rf ./failed
  echo "FAILED RELEASE HAS BEEN REMOVED"
  echo "----------------------------"
  echo "DONE"
  echo "----------------------------"
  end=$(date +%s)
  echo Deployment: $(expr $end - $start) sec
  echo Downtime: $(expr $dtend - $dtstart) sec
fi
