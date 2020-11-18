cd /build
cmake /src
python3 /usr/local/share/clang/run-clang-tidy.py -j $(nproc) -quiet -header-filter="^/src/src/.*" /src/src/.* > tidy.out
cat tidy.out | sed '/^clang-tidy/,$!d' | sed '/^clang-tidy/d' | awk '!a[$0]++' RS="/src/src/" ORS="" > tidy.deduplicated
sed -i '/\/src\/src\//src\//g' tidy.deduplicated
cat tidy.deduplicated
echo "\nSummary:\n"
grep -oP '\[.*?-.*?\]' tidy.deduplicated | sort | uniq -c | sort -nr | tee /dev/tty | awk '{total = total + $1}END{print "  ",total,"warnings"}'

if [ -s tidy.deduplicated ] ; then
    # filename exists and is > 0 bytes
    exit 1
else
    # filename does not exist or is zero length
    exit 0
fi
