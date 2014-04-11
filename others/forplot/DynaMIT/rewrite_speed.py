#This code will rewrite the spe_est data to make the octave readable
#By MAWEI,27.08.2013

file4read = open('output/seg_spd_Est_070000-093000.out')
file4write = open('output/seg_spd_Est_070000-093000.csv','w')

while True:
    cur_line = file4read.readline()
    if len(cur_line) == 0:
        break
    format1='0123456789na-.'
    for c in cur_line:
        if not c in format1:
            cur_line = cur_line.replace(c,',')
    file4write.write(cur_line+'\n')

file4read.close()
file4write.close()
