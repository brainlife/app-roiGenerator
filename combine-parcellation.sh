#!/bin/bash

# top variables
minDegree=`jq -r '.min_degree' config.json` # min degree for binning of eccentricity
maxDegree=`jq -r '.max_degree' config.json` # max degree for binning of eccentricity

# make degrees loopable
minDegree=($minDegree)
maxDegree=($maxDegree)

# loop through all bins and create single volume, then multiply binary file by number of degree bins so we can create one large parcellation
for DEG in ${!minDegree[@]}; do
	# combine hemispheres into one single volume
	[ ! -f Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz ] && fslmaths lh.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz -add rh.Ecc${minDegree[$DEG]}to${maxDegree[$DEG]} -bin Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz

	# multiply by parcellation number (i.e. DEG; +1 because 0 index)
	[ ! -f Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}_parc$((DEG+1)).nii.gz ] && fslmaths Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}.nii.gz -mul $((DEG+1)) Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}_parc$((DEG+1)).nii.gz
	
	# make combination easier by creating holder variable to pass into fslmaths
	if [[ $DEG -eq 0 ]]; then
		holder="fslmaths Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}_parc$((DEG+1)).nii.gz"
	else
		holder="$holder -add Ecc${minDegree[$DEG]}to${maxDegree[$DEG]}_parc$((DEG+1)).nii.gz"
	fi
done

# create final parcellation
if [ ! -f parc/parc.nii.gz ]; then
	${holder} ./parc/parc.nii.gz
fi

# create label and key files
FILES=(`echo "Ecc*to*_parc*.nii.gz"`)
for i in "${!FILES[@]}"
do
	name=`echo ${FILES[$i]} | cut -d'_' -f1`
	oldval=$((i+1))

	newval=$oldval
	echo -e "${oldval}\t->\t${newval}\t== ${name}" >> key.txt

	# make tmp.json containing data for labels.json
	jsonstring=`jq --arg key0 'name' --arg value0 "${name}" --arg key1 "desc" --arg value1 "value of ${newval} indicates voxel belonging to eccentricity bin ${name}" --arg key2 "voxel_value" --arg value2 ${newval} --arg key3 "label" --arg value3 ${newval} '. | .[$key0]=$value0 | .[$key1]=$value1 | .[$key2]=$value2 | .[$key3]=$value3' <<<'{}'`
	if [ ${i} -eq 0 ] && [ ${newval} -eq ${#FILES[*]} ]; then
		echo -e "[\n${jsonstring}\n]" >> tmp.json
	elif [ ${i} -eq 0 ]; then
		echo -e "[\n${jsonstring}," >> tmp.json
	elif [ ${newval} -eq ${#FILES[*]} ]; then
		echo -e "${jsonstring}\n]" >> tmp.json
	else
		echo -e "${jsonstring}," >> tmp.json
	fi
done

# move label and key files to proper location
[ ! -f parc/label.json ] & [ -f tmp.json ] && mv tmp.json ./parc/label.json
[ ! -f parc/key.txt ] & [ -f key.txt ] && mv key.txt ./parc/key.txt

# final check
if [ ! -f parc/parc.nii.gz ]; then
	echo "something went wrong. check deriviatives and logs"
	exit 1
else
	echo "parcellation generation complete."
	mv *.nii.gz *.txt *.gii *.pial ./raw/
	exit 0
fi
