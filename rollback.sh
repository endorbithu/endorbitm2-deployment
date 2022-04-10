cd ./releases
backupCount=$(ls -lr | grep -v total | wc -l)
if [ "$backupCount" -ge "2" ];
then
  #itt a második legújabb mappára kell tenni symlinkelni
  rollback_dir=$(ls -lr | grep -v total | awk '{print $9}' | head -n 2 | awk '(NR>1)')
  cd ..
  rm -f ./current
  ln -s ./releases/${rollback_dir} ./current
  cd ./releases
  # törli a legújabb mappát a releases-ben
  ls --sort t -l | grep -v total | awk '{print $9}' | head -n 1 | xargs rm -rf
fi
