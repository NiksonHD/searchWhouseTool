#!/bin/bash

function articleInfo(){ 
	IFS=$'\t';

artInfo=$(grep -i $1 apache.server/wh_app/on_stock.csv);
if [[ -n "$artInfo" ]];then
read -a articleArr <<< "$artInfo";
echo "${articleArr[0]}\n${articleArr[1]}\n"EAN: "${articleArr[9]}\n"наличност: "${articleArr[2]}" бр.;
fi

}

function extractSap(){
	IFS=$'\t';

artInfo=$(grep -i $1 apache.server/wh_app/on_stock.csv);
mapSearch=$(grep -i $1 apache.server/wh_app/whdata.csv);
if [[ -n "$artInfo" ]];then
read -a articleArr <<< "$artInfo";
echo "${articleArr[0]}";
elif [[ -n "$mapSearch" ]]; then
	read -a articleArr <<< "$mapSearch";
echo "${articleArr[1]}" | sed "s/\"//g";

fi
}

function findCells(){
	IFS=$'\t';


cells=$(grep -i -w $1 apache.server/wh_app/whdata.csv | awk -F'\t' '{ printf $1 " " $3 "\n";}');
echo $cells;

}
function findProcces(){
	IFS=$'\t';


sapNums="$(extractSap $1)";
read -a sapNumsArr <<< $sapNums;

for sapNum in ${sapNumsArr[@]};do
articleInfo="$(articleInfo $sapNum)";
cells="$(findCells $sapNum)";

echo $articleInfo;
echo $cells;

done
}



function changeCell(){
	cell=$2;
	sapNum=$1;

if [[ $cell == 'v' ]];then
	xdg-open https://praktiker.bg/bg/Granitogres/GRANITOGRES-KAI-DUROSTONE-ChERVEN/p/$sapNum;

	
fi
if [[ $cell == 'l' ]];then

echo -e "$sapNum" | tee -a downloads/lists.txt;
exit;
fi
if [ -z $cell ];then
	echo Не си въвел стойност!;exit;
fi
testCellExist=$(cut -f 1 -d$'\t' apache.server/wh_app/whdata.csv | grep  -i -w $cell);

if [ -n "$testCellExist" ];then
sed -i "s/$testCellExist.*/$testCellExist\t$sapNum\t$(date +\"%Y-%m-%d\ %H-%M-%S\")/" apache.server/wh_app/whdata.csv
echo -e "$testCellExist\t$sapNum\t$(date +\"%Y-%m-%d\ %H-%M-%S\")" | tee -a downloads/notes.txt;
grep -i $testCellExist apache.server/wh_app/whdata.csv;

else

echo $cell - Невалидна клетка!;	

fi
}




	IFS=$'\t';

input=$1;

if [[ $input == '' ]];then

IFS=$'\n';
list=$(awk -F, '{gsub(/"/,"",$1); print $1}' storage/shared/BarcodeScanner/History/* );
listArr=();
itemNumber=1
for el in ${list[@]};do
	listArr+=($el);
	echo $itemNumber $(grep -i $el apache.server/wh_app/on_stock.csv | awk -F'\t' '{ print $2;}');
	((itemNumber++))
done
echo Избери номер на артикул.
read item;
articles="$(findProcces ${listArr[$item - 1]})";
article="$(extractSap ${listArr[$item - 1]})";

	IFS=$'';
printf  $articles;
echo '';
echo "Запиши в: (Въведи клетка)";
read cell;
changeCell $article $cell
elif [[ $1 == "l" ]];then
manualArr=();
	IFS=$'\n';
mapSearchListManual=$(awk -F'\t' '{gsub(/"/,"",$1); print $1}' downloads/lists.txt );

itemNumber=1;

for el in ${mapSearchListManual[@]};do
manualArr+=($el);                
echo $itemNumber $(grep -i $el apache.server/wh_app/on_stock.csv | awk -F'\t' '{ print $2;}'); 
    ((itemNumber++)); 
done     
echo Избери номер на артикул.;

read item;
IFS=$'\t';

articles="$(findProcces ${manualArr[$item - 1]})";
article="$(extractSap ${manualArr[$item - 1]})";

printf  $articles;
echo '';
echo "Запиши в: (Въведи клетка)";
read cell;
changeCell $article $cell
elif [[ $1 == "d" ]];then
manualArr=();
	IFS=$'\n';
mapSearchListManual=$(awk -F'\t' '{gsub(/"/,"",$1); print $1}' downloads/dailySearches.txt );

itemNumber=1;

for el in ${mapSearchListManual[@]};do
manualArr+=($el);                
echo $itemNumber $(grep -i $el apache.server/wh_app/on_stock.csv | awk -F'\t' '{ print $2;}'); 
    ((itemNumber++)); 
done     
echo Избери номер на артикул.;

read item;
IFS=$'\t';

articles="$(findProcces ${manualArr[$item - 1]})";
article="$(extractSap ${manualArr[$item - 1]})";

printf  $articles;
echo '';
echo "Запиши в: (Въведи клетка)";
read cell;
changeCell $article $cell
else
articles="$(findProcces $input)";
article="$(extractSap $input)";
echo -e "$article" >> downloads/dailySearches.txt;
printf $articles;
echo '';
echo "Запиши в: (Въведи клетка)";
read cell;
changeCell $article $cell
fi


