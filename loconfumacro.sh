#!/bin/bash

# extracted from scaddins/source/analysis
# extracted from scaddins/source/datefunc
# extracted from scaddins/source/pricing
# extracted from sc/source/ui/src

declare -a sc_opcode_fun
declare -a full_list_fun

sc_opcode_fun=( $(grep -rhA2 '\"SC_OPCODE' ../translations/source/ru/ | sed -e '/\"string.text\"/d'  -e 's/msgid \"//' -e 's/\\n\"//' -e 's/\"//' -e '2~2d' |
	sed -e '/SC_OPCODE_ERROR_T/!s/SC_OPCODE_ERROR/#SC_OPCODE_ERROR/g' -e '/ *#/d' -e '/SC_OPCODE_TABLE/d' |
	sed -e '1!G;h;$!d')) #переворачиваем сторки

i=0

echo ${sc_opcode_fun[$i]}

while [ ${sc_opcode_fun[$i]} != "" ] #Будем выполнять цикл, пока $again будет равно "yes"
	do
		echo "The name you entered is $i"
		(( i++ ))
	done

#grep -rh '\"DATE_FUNCNAME' ../translations/source/ru/ | cut -c 2- | sed 's/...$//'
#grep -rh '\"ANALYSIS_FUNCNAME' ../translations/source/ru/ | cut -c 2- | sed 's/...$//'
#grep -rh '\"PRICING_FUNCNAME' ../translations/source/ru/ | cut -c 2- | sed 's/...$//'

#echo ${sc_opcode_fun[@]}
echo "выход"

exit 0