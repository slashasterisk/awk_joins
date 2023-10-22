BEGIN {
    FS=OFS=","
    maxrec = 0
}

# first file is prod so we get maxrec count
    NR == FNR {
    $1>maxrec ? maxrec=$1 : maxrec = maxrec + 0
# Process the first file (file1)
    k=$2
    # print k
    file1[k] = $0
    next
}
    FNR==1 {
     print "EXIST-NEW" maxrec,$0 > "massport_viol_table_update.txt"
     next
    }

{
# Process the second file (file2) which is new massport
    k=$1
    if (k in file1) {
    # Found a match, print both records
        print "exs", substr(file1[k],1,3), $0 >> "massport_viol_table_update.txt"
        delete file1[k] # Remove the matched record to keep track of unmatched records
    } else {
    # No match found, print the record from file2
        maxrec = maxrec + 1
        print "new", maxrec, $0 >> "massport_viol_table_update.txt"
    }
}

END {
# Print any unmatched records from file1

#    for (key in file1) {
#        print "end1" file1[key] # >> "massport_prod_table_nochange.txt"
#    }
}
