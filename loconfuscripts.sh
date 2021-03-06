#!/bin/bash

###################################################################
## You may distribute or modify it under the terms of either the ##
## GNU LESSER GENERAL PUBLIC LICENSE Version 3.0 or later,       ##
## or Mozilla Public License Version 2.0 or later.               ##
###################################################################

#EN:variables for files and paths
resource="../translations/source/ru/formula/source/core/resource.po"
core_resource="../workdir/SrsPartTarget/formula/source/core/resource/core_resource.src"
scfuncs="../workdir/SrsPartMergeTarget/sc/source/ui/src/scfuncs.src"
helpcontent="../helpcontent2/source/text/scalc/01/"
helpcontent_ls=( $(ls "$helpcontent"))
datefunc="../translations/source/ru/scaddins/source/datefunc.po"
file_datefunc="../workdir/SrsPartMergeTarget/scaddins/source/datefunc/datefunc.src"
analysis="../translations/source/ru/scaddins/source/analysis.po"
file_analysis="../workdir/SrsPartMergeTarget/scaddins/source/analysis/analysis_funcnames.src"
file_danalysis="../workdir/SrsPartMergeTarget/scaddins/source/analysis/analysis.src"
file_canalysis="../scaddins/source/analysis/analysishelper.cxx"
pricing="../translations/source/ru/scaddins/source/pricing.po"
file_pricing="../workdir/SrsPartMergeTarget/scaddins/source/pricing/pricing.src"

echo "variables were appointed"

#EN:Are there files for the work?
if [ ! -f "$resource"       ];  then echo "The file "$resource" do not exist.";         exit 0; fi
if [ ! -f "$core_resource"  ];  then echo "The file "$core_resource" do not exist.";    exit 0; fi
if [ ! -f "$scfuncs"        ];  then echo "The file "$scfuncs" do not exist.";          exit 0; fi
if [ -z "$helpcontent_ls"   ];  then echo "The file "$helpcontent" is empty" ;          exit 0; fi
if [ ! -f "$datefunc"       ];  then echo "The file "$datefunc" do not exist.";         exit 0; fi
if [ ! -f "$file_datefunc"  ];  then echo "The file "$file_datefunc" do not exist.";    exit 0; fi
if [ ! -f "$analysis"       ];  then echo "The file "$analysis" do not exist.";         exit 0; fi
if [ ! -f "$file_analysis"  ];  then echo "The file "$file_analysis" do not exist.";    exit 0; fi
if [ ! -f "$file_danalysis" ];  then echo "The file "$file_danalysis" do not exist.";   exit 0; fi
if [ ! -f "$file_canalysis" ];  then echo "The file "$file_canalysis" do not exist.";   exit 0; fi
if [ ! -f "$pricing"        ];  then echo "The file "$pricing" do not exist.";          exit 0; fi
if [ ! -f "$file_pricing"   ];  then echo "The file "$file_pricing" do not exist.";     exit 0; fi

echo "checking files were done"

#EN:Create files for writing
:> tmp_file

echo "tmp_file was created"

#EN: Declaring arrays for search of functions
declare -a sc_opcode_fun
declare -a date_funcname_fun
declare -a analysis_fun
declare -a pricing_fun
declare -a arrayFUN

echo "arrays were declared"

#EN:Make a selection of functions and codes from the formula/source/core/resource.po file 
sc_opcode_fun=( $(grep -rhA2 '\"SC_OPCODE' "$resource" | 
                sed -e '/\"string.text\"/d'  -e 's/msgid \"//;s/\\n\"//;s/\"//' -e '2~2d' |
                sed -e '/SC_OPCODE_ERROR_T/!s/SC_OPCODE_ERROR/#SC_OPCODE_ERROR/g' |
                sed -e '/ *#/d;/SC_OPCODE_TABLE_REF/d;/SC_OPCODE_NO_NAME/d'))

#EN:Make a selection of functions and codes from the scaddins/source/datefunc.po file
date_funcname_fun=( $(grep -rhA2 '\"DATE_FUNCNAME' "$datefunc" | 
               sed -e '/\"string.text\"/d'  -e 's/msgid \"//;s/\\n\"//;s/\"//' -e '2~2d' ))

#EN:Make a selection of functions and codes from the scaddins/source/analysis.po file
analysis_fun=( $(grep -rhA2 '\"ANALYSIS_FUNCNAME' "$analysis" | 
               sed -e '/\"string.text\"/d'  -e 's/msgid \"//;s/\\n\"//;s/\"//' -e '2~2d' ))

#EN:Make a selection of functions and codes from the scaddins/source/pricing.po file
pricing_fun=( $(grep -rhA2 '\"PRICING_FUNCNAME' "$pricing" |
               sed -e '/\"string.text\"/d'  -e 's/msgid \"//;s/\\n\"//;s/\"//' -e '2~2d' ))

echo "sampling function names was made"

# merger arrays
arrayFUN=(${pricing_fun[@]} ${date_funcname_fun[@]} ${analysis_fun[@]} ${sc_opcode_fun[@]})

echo "arrays were merged"
i=0

while [[ ${arrayFUN[$i]} != "" ]] 
    do

    tokenFUN=${arrayFUN[$i]}
    (( i++ ))
    
    #EN:Skip function: NEG, GOALSEEK, MVALUE, MULTIRANGE, MULTIPLE.OPERATIONS
    if [[ ${arrayFUN[$i]} == "NEG"          || ${arrayFUN[$i]} == "MULTIPLE.OPERATIONS" ]] ||
       [[ ${arrayFUN[$i]} == "MULTIRANGE"   || ${arrayFUN[$i]} == "GOALSEEK"            ]] ||
       [[ ${arrayFUN[$i]} == "MVALUE"       || ${arrayFUN[$i]} == "DURATION"            ]] ||
       [[ ${arrayFUN[$i]} == "EFFECTIVE"    || ${arrayFUN[$i]} == "WEEKNUM_OOO"         ]]
    then 
        (( i++ ))
        tokenFUN=${arrayFUN[$i]}
        (( i++ ))
    fi

    strNAME=${arrayFUN[$i]}
    
    case "${tokenFUN:0:9}" in
        "SC_OPCODE" ) strQTZ=$( grep -h "‖${strNAME/\./\\\.}\"" "$core_resource" | sed 's/^[ \t]*Text\[ qtz \] = \"//;s/..$//')
                strCAT=$( grep -A17 "$tokenFUN"'$' "$scfuncs" | sed 's/^[ \t]*//;s/.$//'   | grep "ID_FUNCTION")
                strNMDG=$(grep -A17 "$tokenFUN"'$' "$scfuncs" | sed 's/^[ \t]*//;s/.$//' | grep -A1 "ID_FUNCTION_GRP" | grep "HID")
            #    strNMDG=${strNMDG:5}
                file_tac=$( grep -A17 "$tokenFUN"'$' "$scfuncs" | sed 's/^[ \t]*//;s/..$//'  | grep "qtz");;
        "ANALYSIS_" ) strQTZ=$( grep -h "‖$strNAME\"" "$file_analysis" | sed 's/^[ \t]*Text\[ qtz \] = \"//;s/..$//')
                strCAT=$( grep $( sed 's/\(\S\+\)/\L\u\1/;s/\(\S\+[A-Za-z]\)2\(\S\+[A-Za-z]\)/\L\u\1\E2\L\u\2/' \
                    <<< $strNAME)"," $file_canalysis | grep -o "FDCat.*[A-Za-z]")
                strNMDG="ANALYSIS_${tokenFUN:18}"
                file_tac=$(sed "1,/$strNMDG/ d;/}.$/,$ d;s/^[ \t]*//;s/..$//" "$file_danalysis" | grep "qtz" )
                strNMDG=$( tr "[a-z]" "[A-Z]" <<< "HID_AAI_FUNC_${tokenFUN:18}");;
        "DATE_FUNC" ) strQTZ=$( grep -h "‖$strNAME\"" "$file_datefunc" | sed 's/^[ \t]*Text\[ qtz \] = \"//;s/..$//' )
                if [ $strNAME == "ROT13" ]; then strCAT="Text"; else strCAT="Date&Time"; fi 
                strNMDG="DATE_FUNCDESC_${tokenFUN:14}"
                file_tac=$(sed "1,/$strNMDG/ d;/}.$/,$ d;s/^[ \t]*//;s/..$//" "$file_datefunc"| grep "qtz" )
                strNMDG=$( tr "[a-z]" "[A-Z]" <<< "HID_DAI_FUNC_${tokenFUN:14}");;
        "PRICING_F" ) strQTZ=$(grep -h "‖$strNAME\"" "$file_pricing" | sed 's/^[ \t]*Text\[ qtz \] = \"//;s/..$//')
                strCAT="Financial"
                strNMDG="PRICING_FUNCDESC_${tokenFUN:17}"
                file_tac=$(sed "1,/$strNMDG/ d;/}.$/,$ d;s/^[ \t]*//;s/..$//" "$file_pricing" | grep "qtz" );;
    esac
    
    strQTZ=${strQTZ:0:5}
    strKEY=${file_tac:15:5}
    strDG=${file_tac:21}
    strHELP=$(grep -rhA8 "$strNMDG\"" $helpcontent | grep "ahelp hid" | 
            sed -e :a -e 's/<[^>]*>//g;/</N;//ba;s/^[ \t]*//;' | sed '/Syntax/,$d' | tr -d '\n')
    
    if [[ $strCAT == "FDCat_Math, \"_EXCEL" && $strNAME == "GCD" ]]
    then
        strCAT="FDCat_Math"
        strNAME="GCD_EXCEL2003"
    elif [[ $strCAT == "FDCat_Math, \"_EXCEL" && $strNAME == "LCM" ]]
    then
        echo "$strNAME | ${strQTZ} | ${tokenFUN} | $strCAT | ${strDG} | ${strKEY} | ${strNMDG} | $strHELP"
        strCAT="FDCat_Math"
        strNAME="LCM_EXCEL2003"
    elif [[ $strCAT == "FDCat_DateTime, \"_EXCEL" && $strNAME == "NETWORKDAYS" ]]
    then
        strCAT="FDCat_DateTime"
        strNAME="NETWORKDAYS_EXCEL2003"
    elif [[ $strCAT == "FDCat_DateTime, \"_EXCEL" && $strNAME == "WEEKNUM" ]]
    then
        strCAT="FDCat_DateTime"
        strNAME="WEEKNUM_EXCEL2003"
    fi

   # if [[ $strNAME == "GCD*" ]]; then echo " $strNAME -- $strCAT "; fi  
    case "$strCAT" in
        "ID_FUNCTION_GRP_STATISTIC" )   strCAT="Statistic";;
        "ID_FUNCTION_GRP_MATH" )        strCAT="Mathematical";;
        "FDCat_Tech" )                  strCAT="Add-in";;
        "ID_FUNCTION_GRP_TEXT" )        strCAT="Text";;
        "FDCat_Finance" )               strCAT="Financial";;
        "ID_FUNCTION_GRP_FINANZ" )      strCAT="Financial";;
        "ID_FUNCTION_GRP_TABLE" )       strCAT="Spredsheet";;
        "ID_FUNCTION_GRP_DATETIME" )    strCAT="Date&Time";;
        "ID_FUNCTION_GRP_INFO" )        strCAT="Infirmation";;
        "ID_FUNCTION_GRP_MATRIX" )      strCAT="Array";;
        "ID_FUNCTION_GRP_DATABASE" )    strCAT="Database";;
        "ID_FUNCTION_GRP_LOGIC" )       strCAT="Logical";;
        "FDCat_Math" )                  strCAT="Mathematical";;
        "Date&Time" )                   strCAT="Date&Time";;
        "FDCat_DateTime" )              strCAT="Date&Time";;
        "Financial" )                   strCAT="Financial";;
        "FDCat_Inf" )                   strCAT="Infirmation";;
        "Text" )                        strCAT="Text";;
    esac
    
    #EN:Write CSV ans Wiki files
    echo "${strNAME}|${strQTZ}|${tokenFUN}|$strCAT|${strDG}|${strKEY}|${strNMDG}|$strHELP|" >> tmp_file
    (( i++ ))

    done

echo "loop was made"

cat tmp_file | sort > fun_list.csv

echo "file fun_list.csv was written"

echo -e "{| class=\"wikitable sortable\" style=\"text-align:center; font-size:9pt\"
|+ Names, descriptions and KeyIDs of functions \n! width=70 | Function Name \n! width=40 | Function IDKey 
! width=200 | Function Macros \n! width=50 | Сategory \n! width=200 | Function Discription
! width=40 | Discription IDKey \n! width=200 | Discription Macros \n! width=200 | Discription in Help" > fun_list.wiki
cat tmp_file | sort | sed 's/^/-‖/' | tr "‖" "\n" | sed '/^$/d;s/|/‖|/g;s/^/|/' | tr "‖" "\n" | sed '/^$/d;9~9d' >> fun_list.wiki
echo "|}" >> fun_list.wiki

echo "file fun_wiki.wiki was written"
    
rm tmp_file

echo "file tmp_file was deleted"

exit 0
