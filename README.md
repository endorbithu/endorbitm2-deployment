# Magcdento 2 Deployment
Szünetmentes Magento 2 deployment / rollbacking

## PHP beállítása

Először kell csinálnunk egy `./phptorun` nevű symlinket a projekt root mappájába a megfelelő php binárisról
pl:
```
ln -s /opt/cpanel/ea-php81/root/usr/bin/php ./phptorun
```
és csináljunk a composer binárisról is egy symlinket:
```
ln -s /opt/cpanel/composer/bin/composer ./composertorun
```
## Git repo beállítása
`./repo` mappában kell clone-oznunk a git repot.  
Clone-ozás után (ha nem db másolás van) kell egy `bin/magento install...` scriptet futtatni, 
és az env.php és config.php-t átmásolni a shared mappába. 


## Mappák:
```
├── current -> symlink a legfrisebb release-re
├── releases - az utolsó 4db release
│   └── 20220410_211122_d5f224798e -> release-hez tartozó commit rövid hash-je a végén
├── repo -> git repo
└── shared -> symlinkelt fájlok/mappák 
```

## Linkelt fájlok/mappák
A linkelt fájlok/mappák, (=amik nincsenek benne a git repoba, hanem a működés során kerül bele tartalom) a shared mappában vannak.
```
├── app
│   └── etc
|       ├── config.php
│       └── env.php
├── pub
│   ├── media
│   └── generated -> ide kell beállítani az összes generált cuccot, feed sitemap stb
└── var
```
 
- sitemap-ot be lehet állítani magento adminban, hogy hova generálja
- a robots.txt meg dinamikusan generálódik, itt nem kell vele foglalkozni.


## Futtatás
Ha készen áll a repo, és az env.php, config.php.
### Teljes deployment
Egyszerre 4db release-t hagy meg, minden release-nél törli a legrégebbit.  
(További részletek lsd. fájlban a commentek)  
 
```
$ ./deploy.sh 
```
### Gyors deployment (cache törlés, fordítást stb nem igénylő módosításnál)
kihagyja a composer install-t és  magentos deploy műveleteket  
```
$ ./deploy fast
```

### Rollback
Az utolsó előtti release-re rollback-kel (ha van minimum 2db release), és törli is az utolsó release-t.  
(További részletek lsd. fájlban a commentek)  
```
$ ./rollback.sh 
```


