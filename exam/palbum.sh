#!/bin/bash
#set x
#Document written by Mathieu Delbos






function check_input_directory() {
	
	if [ ! -d $1 ]
	then
		echo "$1 is not a valid directory"
		exit 2
	fi
	#jpg files are stored temporarely in list_of_pictures file
	find $1 -type f -name "*.jpg">list_of_pictures
	#We read each line of list_of_pictures, representing a jpg file
	while read ligne
		do
	#We check if each jpg file contains meta data
		if [ "$(identify -verbose $ligne|grep date:modify)" == "" ]
		then
			echo "$1 does not contain meta data, and so cannot be sotred properly"
			exit 3
		fi

	done < list_of_pictures
	rm list_of_pictures
}


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
	#we go through the years repositories
	for year in $1/*
	do
		
		if [ -d $year ]
		then
			#each year is a link to the corresponding year index
			echo "<a href=\"$year/index.html\">$year</link></a>">>$1/index.html
			echo "number of pictures taken this year:">>$1/index.html
			#we count the pictures (excluding the thumbnails)
			echo $(find $year/  -maxdepth 2 -type f | wc -l)>>$1/index.html
			
		fi
	done
	echo "</p>
</body>
</html>">>$1/index.html


}

function year_index () {
	for year in $1/*
	do
		
		#$1 is album rep $year is the year
      		index="$year/index.html"
       		echo "index $index"
		echo "<!DOCTYPE html>
<html>
<body>
<h1>$year</h1>">>$index
		#we sort the days (YYY:MM:DD format) by month in the days.txt
		ls -1 $year | sort -t":" +1nr >days.txt
		while read day
		do
			month=${day:0:7}
			echo "<h2>$month</h2>
<h3>$day</h3>
<p>">>$index
		#we go through the images taken that day
			for image in $year/$day/*
			do
				#we select the base name of the image
				image_basename=$(echo "$image" | cut -d '/' -f 4 | cut -d '.' -f 1)
				#we search for the matching thumbnail
				echo "<a> href=\"$image\"><img src=\"$year/$day/.thumbs/$(ls  $year/$day/.thumbs | grep $image_basename) \"/></a> ">>$index
			done
		echo "</p>">>$index		
		done<days.txt
		rm days.txt
	done


}


function thumbnails(){
	
	image=$2
	image_name=$(echo "$image" | cut -f 1 -d '.')
	thumbnail_name="${image_name}-thumb.jpg"
	convert -define jpeg:size=500x180  $image -thumbnail 250x90  $thumbnail_name
	#once the thumbnail is created; we move it to the right repository
	mv $thumbnail_name "$1/.thumbs"
	#rm $thumbnnail_name

}


function arborescence () {
	find $1 -type f -name "*.jpg">list_of_pictures
	#we select only the jpg files
	while read line
	do
		
		#date=$(identify -verbose $line |grep date:modify|cut -b 18-27)
		#date=$(exif -line | grep "Date and Time (Origi" | cut -d "|" -f2)
		#we extract the date of creation
		date=$(exiftime $line | grep "Image Created" | cut -d" " -f3)
		year=${date:0:4}
		thumbs=".thumbs"
		if [ ! -d "$2/$year" ]  
		then 
			mkdir "$2/$year"
			mkdir "$2/$year/$date"
			mkdir "$2/$year/$date/$thumbs" #piste amélioration : tout créer d'un coup

		fi

		if [ ! -d "$2/$year/$date" ]
		then
			mkdir "$2/$year/$date"
			mkdir "$2/$year/$date/$thumbs"
	
		fi
	cp "$line"  "$2/$year/$date"
	#we create all the thumbnails
	thumbnails $2/$year/$date $line
	done<list_of_pictures
	rm list_of_pictures
}

#MAIN
#check_input_directory $1
mkdir $2
arborescence $1 $2
general_index $2
year_index $2

