#!/bin/bash
number_1=0
length=$(ss -ltn4Hp | wc -l)
len=$(ss -ltn4Hp | wc -l)

echo "Machine name : $(hostnamectl | grep hostname | cut -d" " -f4)"
echo "OS$(hostnamectl | grep System | cut -d ":" -f2) and kernel version is$(hostnamectl | grep Kernel | cut -d ":" -f2)"
echo "IP : $(ip a | grep "inet " | tail -n 1 | tr -s " " | cut -d " " -f3)"
echo "RAM : $(free -h | grep Mem | tr -s " " | cut -d " " -f6) RAM restante sur $(free -h | grep Mem | tr -s " " | cut -d " " -f2) RAM totale"
echo "Disque : $(df -h | grep "/$" | tr -s " " | cut -d " " -f4) space left"
echo "Top 5 processes by RAM usage :"
echo "  - $(ps aux --sort=-%mem | head -2 | tail -1 | tr -s " " | cut -d " " -f11)"
echo "  - $(ps aux --sort=-%mem | head -3 | tail -1 | tr -s " " | cut -d " " -f11)"
echo "  - $(ps aux --sort=-%mem | head -4 | tail -1 | tr -s " " | cut -d " " -f11)"
echo "  - $(ps aux --sort=-%mem | head -5 | tail -1 | tr -s " " | cut -d " " -f11)"
echo "  - $(ps aux --sort=-%mem | head -6 | tail -1 | tr -s " " | cut -d " " -f11)"
echo "Listening ports :"
while [[ ${number_1} -ne ${length} ]]
do
  echo "  -$(ss -ltn4Hp | tr -s " " | cut -d " " -f4 | cut -d ":" -f2 | tail -n ${len} | head -n 1) $(sudo ss -ltn4Hp | tr -s " " | cut -d " " -f6 | tail -n ${len} | head -n 1 | cut -d'"' -f2)"
  number_1=$(( number_1 + 1 ))
  len=$(( len - 1))
done
echo ""
curl "https://cataas.com/cat" --output cat.jpg 2> /dev/null
echo "Here is your random cat : ./cat.jpg"
