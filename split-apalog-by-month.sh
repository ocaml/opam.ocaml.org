#!/usr/bin/awk

BEGIN {
    split("Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ", months, " ")
    for (a = 1; a <= 12; a++)
        m[months[a]] = a
}
{
    split($4,array,"[:/]");
    year = array[3]
    month = sprintf("%02d", m[array[2]])
    print > "access-"year"-"month".log"
}
