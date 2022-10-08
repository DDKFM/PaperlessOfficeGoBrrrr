#!/bin/bash
echo "enter the filename, plz: "
read filename

ssh_remote_host="<ssh remote host>"
consume_directory="<directory on ssh remote host>"

n=1
files=()
while true; do
   echo "Scan image $n"
   scanimage -p --resolution 300dpi --format=tiff > /tmp/scan_$n.tiff
   echo "OCR scan $n"
   ocrmypdf /tmp/scan_$n.tiff /tmp/scan_$n.pdf
   files=( "${files[@]}" "/tmp/scan_$n.pdf" )
   # -n 1 to get one character at a time, -t 0.1 to set a timeout 
   echo "Next Scan? (press q to quit) "
   read -n 1 input                  # so read doesn't hang
   if [[ $input = "q" ]] || [[ $input = "Q" ]] 
   then
      echo "combine pdfs"
      pdfunite "${files[@]}" "output/$filename.pdf"
      echo "PDF saved to $filename.pdf"
      scp "output/$filename.pdf" $ssh_remote_host:$consume_directory
      echo # to get a newline after quitting
      break
   fi
   ((n=n+1))
done
