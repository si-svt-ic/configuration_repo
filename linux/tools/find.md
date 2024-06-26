

## ============FIND ============

  find /var/log -iname "*.log" -mtime -5 | wc -l

Tim string trong files trong thu muc
  
  find . -exec grep -l "racdb" {} \;

  find / -mount -type f -mtime -10 
  find /shrpool -mtime -80 -type f -size +10480 
Pasted from <http://www.unix.com/solaris/48675-solaris-10-proc-making-filesystem-full.html>

  fuser -cu /tmp  

  find . -name core* -mtime +15 -exec rm -f {} \;

From <http://www.unix.com/solaris/114554-delete-files-date-wise.html> 


  find . -cmin -3

Pasted from <http://stackoverflow.com/questions/14032188/how-to-find-file-accessed-created-just-few-minutes-ago> 


Find largest files
Warning: only works with GNU find ##

  find /path/to/dir/ -printf '%s %p\n'| sort -nr | head -10
  find . -printf '%s %p\n'| sort -nr | head -10
  
Pasted from <http://www.cyberciti.biz/faq/how-do-i-find-the-largest-filesdirectories-on-a-linuxunixbsd-filesystem/> 


  find / -name '*abc*' -print

From <http://www.linuxquestions.org/questions/linux-general-1/how-to-find-file-using-wildcard-104393/> 


## ==============ZIP + TAR ==============

Pasted from <https://groups.google.com/forum/?fromgroups=#!topic/comp.unix.solaris/WsjdMXoJMsY> 

  tar -cvf a.tar users-vnn3.ldif
  tar -cvf /backup/home.tar /home
  tar –tvf /dev/rmt0


  tar -czpf  /home/example/archive.tgz  folder
  tar zxvf /home/example/archive.tgz


  gzip -c etc.tar > etc.tar.gz
  tar -cvf -/data | gzip -c > data_tar.gz
  bunzip2 < foo.tar.bz2 | tar xfv -

Pasted from <http://www.techspot.com/vb/topic892.html> 
  
  Unzip \*.zip
  gunzip < file.tar.gz |tar xfv - 
  tar cf var.tar.gz /var

  tar cvf ins-tt1-pps.12.tar  ins-tt1-pps.12.*
  a ins-tt1-pps.12.df-k 910K
  a ins-tt1-pps.12.iostat-xnpc 980K
  a ins-tt1-pps.12.memory 1K
  a ins-tt1-pps.12.sar-r 84K
  a ins-tt1-pps.12.swap-l 70K
  a ins-tt1-pps.12.swap-s 63K
  a ins-tt1-pps.12.vmstat 170K