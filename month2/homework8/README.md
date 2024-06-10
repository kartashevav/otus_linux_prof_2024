1. Определение алгоритма с наилучшим сжатием
Создаем 4 пула по два диска в режиме raid1
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

Добавим разные алгоритмы сжатия в каждую файловую систему:
lzjb: zfs set compression=lzjb otus1
lz4:  zfs set compression=lz4 otus2
gzip: zfs set compression=gzip-9 otus3
zle:  zfs set compression=zle otus4

Проверим что компрессия включена
[root@zfs ~]# zfs get compression
NAME   PROPERTY     VALUE     SOURCE
otus1  compression  lzjb      local
otus2  compression  lz4       local
otus3  compression  gzip-9    local
otus4  compression  zle       local

Скачаем один и тот же текстовый файл во все пулы:
for i in {1..4}; do wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log; done

Проверис степень компресии
[root@zfs ~]# zfs get compressratio
NAME   PROPERTY       VALUE  SOURCE
otus1  compressratio  1.82x  -
otus2  compressratio  2.23x  -
otus3  compressratio  3.66x  -
otus4  compressratio  1.00x  -

Алгоритм gzip-9 самый эффективный по сжатию данного файла.

2. Определение настроек пула
Скачиваем архив в домашний каталог:
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'

Разархивируем его:
tar -xzvf archive.tar.gz

Проверяем есть ли в папке пулы для импорта
zpool import -d zpoolexport/

Сделаем импорт пула otus:
zpool import -d zpoolexport/ otus

[root@zfs ~]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

        NAME                         STATE     READ WRITE CKSUM
        otus                         ONLINE       0     0     0
          mirror-0                   ONLINE       0     0     0
            /root/zpoolexport/filea  ONLINE       0     0     0
            /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

Чтобы определить параметры пула:
zpool get all otus

Чтобы определить все параметры файловой системы:
[root@zfs ~]# zfs get all otus
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              off                    default
otus  redundant_metadata    all                    default
otus  overlay               off                    default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default
[root@zfs ~]#

C помощью команды grep можно уточнить конкретный параметр, например:
[root@zfs ~]# zfs get available otus
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -

3. Работа со снапшотом, поиск сообщения от преподавателя
Скачаем файл, указанный в задании:
[root@zfs ~]# wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download

Восстановим файловую систему из снапшота:
zfs receive otus/test@today < otus_task2.file

Проверим что файловая система доступна
[root@zfs ~]# df -h | grep otus/test
otus/test       350M  2.9M  347M   1% /otus/test

ищем в каталоге /otus/test файл с именем “secret_message”:
[root@zfs ~]# find /otus/test -name "secret_message"
/otus/test/task1/file_mess/secret_message

Смотрим содержимое найденного файла:
[root@zfs ~]# cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/


