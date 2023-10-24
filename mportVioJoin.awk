BEGIN {
    FS=OFS=","
    maxrec = 0
    didit=0
    str = "date +%Y%j"
    str | getline date
    close(str)
}

# first file we read is prod viol table (prfile), so we get maxrec count since that is master
    NR == FNR {
    $1>maxrec ? maxrec=$1 : maxrec = maxrec + 0
	
# Process prfile into an array, the key is the external violation code
    key=$2
    prfile[key] = $0
    next
}
    FNR==1 {
        print "EXIST-NEW" maxrec,$0 > "massport_viol_table_update.txt"
        next
    }

{
# Process file2 which is the new massport viol schedule
# this code was a duplicate, they want the first one read in
    if ($1=="AE22025" && didit == 0) {
        didit = 1
        next
    }

    $NF=="\r" ? $NF=0 : $NF=$NF 
    $(NF-1)=="" ? $(NF-1)=0:$(NF-1)=$(NF-1) 
    $(NF-2)=="" ? $(NF-2)=0:$(NF-2)=$(NF-2) 
    $(NF-3)=="" ? $(NF-3)=0:$(NF-3)=$(NF-3) 
    $(NF-4) = date

    key=$1
    if (key in prfile) {
    # Found a match add the corresponding internal code from prod to the record read & write out
        print "exs", substr(prfile[key],1,3), $0 >> "massport_viol_table_update.txt"
        delete prfile[key] # Remove the matched record to prevent dupes (if we print the unmatched prfile)
    } else {
    # No match found, print the record from file2
        maxrec = maxrec + 1
        print "new", maxrec, $0 >> "massport_viol_table_update.txt"
    }
}

END {
# Print any unmatched records from prfile to help validate

#    for (key in prfile) {
#        print "end1" prfile[key] # >> "massport_prod_table_nochange.txt"
#    }
}
