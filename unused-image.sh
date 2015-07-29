OGNAME=$(basename "$0")
PROGDIR=$(dirname "$0")

usage()
{
	echo "Usage: $PROGNAME  [option]  -p path-of-project"
	echo ""
	echo "-p          Specifyed the path of your project"
	echo "-r          Remove unused image file"
	echo "-h          Show this message"

	exit 1
}

PRJ_ROOT=$1
REMOVE=false
COUNT=0


while getopts ":rp:" optname
  do
    case "$optname" in
      "p")
        PRJ_ROOT=$OPTARG  # specifyed the project root
        ;;
      "r")
        REMOVE=true		  # remove unused image resource
        ;;
      "?")
        usage
        ;;
      ":")
        echo "No argument value for option $OPTARG"
        ;;
      *)
      # Should not occur
        echo "Unknown error while processing options"
        ;;
    esac
    #echo "OPTIND is now $OPTIND"
done


check_files=`find $PRJ_ROOT -name '*.xib' -o -name '*.storyboard' -o -name '*.[mh]'-o -name '*.mm'  -o -name '*.swift'  -o -name '*.pch' -o -name '*.java' -o -name '*.xml'`

for png in `find $PRJ_ROOT -name '*.imageset'`
do
    match_name=`basename $png`

###  Only check Images.xcassets
    suffix=".imageset"
    if [[ ${match_name/${suffix}//} != $match_name ]]; then
      match_name=${match_name%$suffix}
    fi

    dir_name=`dirname $png`
    if [[ $dir_name =~ .bundle$ ]] || [[ $dir_name =~ .appiconset$ ]] || [[ $dir_name =~ .launchimage$ ]]; then
      continue
    fi

    referenced=false

    for file  in `echo $check_files | sed 's/\n/ /g'`
  	do
  	    if  grep -sqh "$match_name" "$file"; then
  	        referenced=true
  	    fi
  	done

  	if ! $referenced ; then
  		echo "The '$png' was not referenced in any file"
  		COUNT=`expr $COUNT + 1`
  		if $REMOVE ; then
  			echo "Do remove unused image file '$png'"
  			rm -f $png
  		fi
  	fi

done

echo "============= Total $COUNT unused image files ============="
