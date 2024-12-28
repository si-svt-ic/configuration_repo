

https://www.suse.com/support/kb/doc/?id=000018317
How to remove CTRL-M (^M) characters from a file in Linux

cat -vte file
sed -e "s/\r//g" file > newfile