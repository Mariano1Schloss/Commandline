#!/bin/bash





#test deux arguments
#test argument 1 valid directory
#test argument 2 vali
#	sinon le créer

#Créer arboresecnce
#créer fichier index
#créer fichier thumb



mkdir $2


#if [ -d $1 ]
#then
	#jpg files are stored temporarely in list_of_pictures file
#	find $1 -type f -name "*.jpg">list_of_pictures
	#We read each line of list_of_pictures, representing a jpg file
#	while read ligne
#	do
#		#We check if each jpg file contains meta data
#		if [ $(identify -verbose $ligne|grep date:modify) == ""]
#		then
#			echo "$1 does not contain meta data, and so cannot be sotred properly"
#			exit 3
#		fi

#	done < list_of_pictures
#rm list_of_pictures
#version moins lourde?

#fi


#An  index.html file is present in OUTPUT-DIRECTORY, referencing each
#year in the album together with the number of photos taken each year.
#A click on the name of the year opens the album for this year
function general_index  () {
	echo "<!DOCTYPE html>
<html>
<body>
<h1>General index of the album</h1>
<p>">>$1/index.html
	for year in $1/*
	do
		
		if [ -d $year ]
		then
			echo "$year"
			echo "$year">>$1/index.html
			echo "number of pictures taken this year:">>$1/index.html
			echo $(find $year/ -type f | wc -l)>>$1/index.html
			#à faire: faire le lien entre chaque année et l'index.html correspondant
		fi
	done
	echo "</p>
</body>
</html>">>$1/index.html


}
function thumbnails(){
	
	image=$2
	image_name=$(echo "$image" | cut -f 1 -d '.')
	thumbnail_name="${image_name}-thumb.jpg"
	convert -define jpeg:size=500x180  $image -thumbnail 250x90  $thumbnail_name
	cp $thumbnail_name $1/.thumbs
	rm $thumbnnail_name

}



find $1 -type f -name "*.jpg">list_of_pictures
while read line
do
	echo "line $line"
	date=$(identify -verbose $line |grep date:modify|cut -b 18-27)
	year=${date:0:4}
	echo "date : $date   year : $year "
	if [ ! -d "$2/$year" ]  
	then 
		mkdir "$2/$year"
		mkdir "$2/$year/$date"
	fi

	if [ ! -d "$2/$year/$date" ]
	then
		mkdir "$2/$year/$date"
		
	fi
	thumbs=".thumbs"
	mkdir "$2/$year/$date/$thumbs"
	cp "$line"  "$2/$year/$date"
	thumbnails $2/$year/$date $line
	#echo "$image">>$2/$year/$date/image
done<list_of_pictures
rm list_of_pictures

general_index $2
