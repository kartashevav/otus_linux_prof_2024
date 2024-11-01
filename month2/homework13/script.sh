#!/bin/bash
# в переменную пишем текущую дату в формате 01\/Nov\/2024:13
# заменяем символы / на символ \/, так как в log файле в дате используется символ / и его нужно экранировать
CURRENT_DATE=$(date "+%d/%b/%Y:%H" | sed 's|/|\\/|g')
# в переменную пишем текущую дату минус 1 час в формате 01\/Nov\/2024:13 и также экранируем /
CURRENT_DATE_MINUS_HOUR=$(date -d "today - 1 hour" +"%d/%b/%Y:%H" | sed 's|/|\\/|g')
# делаем выборку из строк лога за последний час
sed -n "/$CURRENT_DATE_MINUS_HOUR/ , /$CURRENT_DATE/p" /vagrant/access-4560-644067.log > /vagrant/fragment.log
# пишем в файл комментарии
echo "Статистика за период $(date -d "today - 1 hour" +"%d/%b/%Y:%H")час - $(date "+%d/%b/%Y:%H")час" > /vagrant/statistic.log
echo '-------------------------------------------------------------------' >> /vagrant/statistic.log
echo 'Список IP адресов (с наибольшим кол-вом запросов)' >> /vagrant/statistic.log
echo 'с указанием кол-ва запросов c момента последнего запуска скрипта;' >> /vagrant/statistic.log
echo '-------------------------------------------------------------------' >> /vagrant/statistic.log
# по регулярному выражению ищем все ip адреса, выбираем уникальные, сортируем, выводим первые 10
grep -o -E "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}" /vagrant/fragment.log | uniq -dc | sort -nr | head >> /vagrant/statistic.log
# пишем в файл комментарии
echo 'Список запрашиваемых URL (с наибольшим кол-вом запросов)' >> /vagrant/statistic.log
echo 'с указанием кол-ва запросов c момента последнего запуска скрипта;' >> /vagrant/statistic.log
echo '-------------------------------------------------------------------' >> /vagrant/statistic.log
# по регулярному выражению ищем url запросов, убираем запросы на '/', сортируем, выбираем уникальные
sed -r "s/.*(GET|POST|HEAD|PROPFIND) (.*?) HTTP.*/\2/" /vagrant/fragment.log | grep -v "^/$" | sort | uniq -dc | sort -nr | head >> /vagrant/statistic.log
grep -o -E "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}" /vagrant/fragment.log | uniq -dc | sort -nr | head >> /vagrant/statistic.log
# пишем в файл комментарии
echo 'Ошибки веб-сервера/приложения c момента последнего запуска;' >> /vagrant/statistic.log
echo '-------------------------------------------------------------------' >> /vagrant/statistic.log
# регулярным выражением ищем строки, содержащие слово error
grep -o -E "\/.*error.*?\/" /vagrant/fragment.log >> /vagrant/statistic.log
# пишем в файл комментарии
echo 'Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта.' >> /vagrant/statistic.log
echo '-------------------------------------------------------------------' >> /vagrant/statistic.log
# регулярным выражением ищем коды ответов сервера
sed -n  's/.*GET [^ ]* HTTP[^ ]*" \([0-9]\{3\}\) .*/\1/p' /vagrant/fragment.log | sort -nr | uniq -dc >> /vagrant/statistic.log
# отправляем файл статистики по email
mail -s "Statistic log" -A /vagrant/statistic.log kartashevav@sv-en.ru

