# endorbitm2-deployment

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
## Mappák:

├── current -> symlink a legfrisebb deployra
├── releases - az utolsó 5db deploy
│   └── 20160526030129_main
├── repo - this is a bare clone of your Git repository
├── revisions.log - a line for each release with the commit hash, release date, and username of the machine that deployed
└── shared -> this is a permanent directory that contains the files/directories referenced by 


## Linkelt mappák
A linkelt mappák, (=amik nincsenek benne a git repoba, hanem a működés során kerül bele tartalom) a shared mappában vannak:
├── app
│   └── etc
│       └── env.php
├── pub
│   ├── media
│   └── generated -> ide megy az összes genewrált cucc, feed sitemap stb
└── var
    ├── backups
    ├── composer_home
    ├── importexport
    ├── import_history
    ├── log
    ├── session
    └── tmp

Amikor először lehúzzuk a repot a repo mappába (ha nem db másolás van) ott kell egy magento install scriptet futtatni, 
és az env.php és config.php-t átmásolni a shared mappába

sitemap-ot be lehet állítani adminban, hogy hova generálja
a robots.txt meg dinamikusan generálódik

./deploy fast => kihagyja a composer install-t és  magentos deploy műveleteket, 

