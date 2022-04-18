#!/bin/bash
set -e
cd ./releases
#ha nem lett valamiért törölve a ./failed mappa, azt mindenképp törölni kell, mert különben hozzáadj aa meglévő release számhoz
rm -rf ./failed

releaseCount=$(ls -lr | grep -v total | wc -l)
if [ "$releaseCount" -ge "2" ];
then
  #itt a második legújabb mappára kell tenni symlinkelni
  rollback_dir=$(ls -lr | grep -v total | awk '{print $9}' | head -n 2 | awk '(NR>1)')
  cd ..
  rm -f ./current
  ln -s ./releases/${rollback_dir} ./current
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
  echo "Removed failed release
  echo "----------------------------"
  echo "Done"
  echo "----------------------------"
fi
