.data
num_test: .word 3 
TEST1_SIZE: .word 34
TEST2_SIZE: .word 19
TEST3_SIZE: .word 29
test1: .word 3,41,18,8,40,6,45,1,18,10,24,46,37,23,43,12,3,37,0,15,11,49,47,27,23,30,16,10,45,39,1,23,40,38
test2: .word -3,-23,-22,-6,-21,-19,-1,0,-2,-47,-17,-46,-6,-30,-50,-13,-47,-9,-50
test3: .word -46,0,-29,-2,23,-46,46,9,-18,-23,35,-37,3,-24,-18,22,0,15,-43,-16,-17,-42,-49,-29,19,-44,0,-18,23

.text
.globl main

main:

# ######################################
# ### Load address of _answer to s0 
# ######################################

  addi sp, sp, -4
  sw s0, 0(sp)
  la s0, _answer

# ######################################


# ######################################
# ### Main Program
# ######################################

    addi  sp, sp, -20           # callee save
    sw    ra, 16(sp)
    sw    s0, 12(sp)
    sw    s1, 8(sp)
    sw    s2, 4(sp)
    sw    s3, 0(sp)
    la    t0, num_test          
    lw    s0, 0(t0)             # s0=numtest
    la    s1, TEST1_SIZE        # s1=TEST(n)_SIZE(location)
    la    s2, test1             # s2=test(n)(location)
    li    s3, 0x9000            # s3=ans(location)
catchdata:                      # catchdata ex:test1,test2,test3...
    lw    t0, 0(s1)
    addi  t1, t0, -1            # t1=TEST(n)_SIZE-1 
    mv    a0, s2                # sending argument
    li    a1, 0
    mv    a2, t1
    jal   ra, mergesort         # save ra & go to function "mergesort"

    lw    t2, 0(s1)             # t2=TEST(n)_SIZE
write_ans:
    lw    t4, 0(s2)             # *(answer++) = *(test++)
    sw    t4, 0(s3)
    addi  t2, t2, -1            # equal i++ of "for"
    li    t1, 1
    bne   s0, t1, renew         # if(not last one),go to renew
    bne   t2, x0, renew
    jal   x0, skip_add
renew:
    addi  s2, s2, 4             # test++(location)
    addi  s3, s3, 4             # ans++(location)
skip_add:
    bne   t2, x0, write_ans     # keep write_ans if nessesary(i != 0)

    addi  s1, s1, 4             # TEST(n)_SIZE++(locatoin)
    addi  s0, s0, -1            # numtest--(rest of data)
    bne   s0, x0, catchdata     # keep catchdata if nessesary(numtest != 0)

    lw    ra, 16(sp)            # callee save
    lw    s0, 12(sp)
    lw    s1, 8(sp)
    lw    s2, 4(sp)
    lw    s3, 0(sp)
    addi  sp, sp, -20
    ret                         # end of program
mergesort:
    addi  sp, sp, -20           # callee save
    sw    ra, 16(sp)
    sw    s0, 12(sp)
    sw    s1, 8(sp)             
    sw    s2, 4(sp)
    sw    s3, 0(sp)
    ble   a2, a1, end_mergesort # if(start < end){

    mv    s0, a0                # s0=arr(location)
    mv    s1, a1                # s1=start
    mv    s2, a2                # s2=end
    add   s3, s1, s2            # s3=mid=(start+end)/2
    srai  s3, s3, 1

    mv    a0, s0                # sending argument
    mv    a1, s1
    mv    a2, s3
    jal   ra, mergesort         # save ra & go to function "mergesort"
                                # mergesort(arr, start, mid)

    mv    a0, s0                # sending argument
    addi  a1, s3, 1
    mv    a2, s2
    jal   ra, mergesort         # save ra & go to function "mergesort"
                                # mergesort(arr, mid+1, end)

    mv    a0, s0                # sending argument
    mv    a1, s1
    mv    a2, s3
    mv    a3, s2
    jal   ra, merge             # save ra & go to function "merge"
                                # merge(arr, start, mid, end)

end_mergesort:                  # if (start >= end || end_merge)
    lw    ra, 16(sp)            # callee save
    lw    s0, 12(sp)
    lw    s1, 8(sp)
    lw    s2, 4(sp)
    lw    s3, 0(sp)
    addi  sp, sp, 20
    ret                         # end of mergesort

merge:
    addi  sp, sp, -12           # callee save
    sw    ra, 8(sp)
    sw    s0, 4(sp)             
    sw    s1, 0(sp)             
    mv    s0, a0                # s0=arr(location)
    sub   t0, a3, a1            # t0=temp_size= end - start + 1
    addi  t0, t0, 1
    slli  t0, t0, 2
    sub   sp, sp, t0            # int temp[temp_size]
    mv    s1, sp                # s1=temp(location)

    li    t1, 0                 # i in for
copy:
    add   t2, t1, s1            # t2=temp[i](location)
    add   t3, t1, s0            # t3=arr[i+start](location)
    slli  t4, a1, 2             
    add   t3, t3, t4
    lw    t4, 0(t3)             # temp[i] = arr[i+start]
    sw    t4, 0(t2) 
    addi  t1, t1, 4             # equal i++
    bne   t1, t0, copy          # keep copy if nessesary
    
    addi  sp, sp, -20           # callee save
    sw    s2, 16(sp)            
    sw    s3, 12(sp)            
    sw    s4, 8(sp)             
    sw    s5, 4(sp)             
    sw    s6, 0(sp)             # ↓(initial)↓
    li    s2, 0                 # s2=left_index =0
    sub   s3, a2, a1            # s3=right_index=mid-start+1
    addi  s3, s3, 1
    sub   s4, a2, a1            # s4=left_max   =mid-start
    sub   s5, a3, a1            # s5=right_max  =end-start
    mv    s6, a1                # s6=arr_index  =start
    slli  s3, s3, 2             # turn to address mode (Byte)
    slli  s4, s4, 2
    slli  s5, s5, 2
    slli  s6, s6, 2
while_1:                        # whlie(left_index <= left_max && right_index <= right_max)
    bgt   s2, s4, while_2       
    bgt   s3, s5, while_2
    add   t0, s1, s2            # t0=&temp[left_index]
    add   t1, s1, s3            # t1=&temp[right index]
    lw    t2, 0(t0)             # t2=temp[left_index]
    lw    t3, 0(t1)             # t3=temp[right_index]
    add   t4, s0, s6
    bgt   t2, t3, else
if:                             # if(temp[left_index] <= temp[right_index])
    sw    t2, 0(t4)             # arr[arr_index] = temp[left_index]
    addi  s6, s6, 4             # equal arr_index++
    addi  s2, s2, 4             # equal left_index++
    jal   x0, while_1
else:                           # if(temp[left_index] > temp[right_index])
    sw    t3, 0(t4)             # arr[arr_index] = temp[right_index]
    addi  s6, s6, 4             # equal arr_index++
    addi  s3, s3, 4             # equal right_index++
    jal   x0, while_1
while_2:                        # while(left_index <= left_max)
    bgt   s2, s4, while_3       
    add   t0, s0, s6
    add   t1, s1, s2
    lw    t2, 0(t1)             # arr[arr_index] = temp[left_index]
    sw    t2, 0(t0)
    addi  s6, s6, 4             # equal arr_index++
    addi  s2, s2, 4             # equal left_index++
    jal   x0, while_2
while_3:                        # while(right_index <= right_max)
    bgt   s3, s5, return
    add   t0, s0, s6
    add   t1, s1, s3
    lw    t2, 0(t1)             # arr[arr_index] = temp[right_index]
    sw    t2, 0(t0)
    addi  s6, s6, 4             # equal arr_index++
    addi  s3, s3, 4             # equal right_index++
    jal   x0, while_2
return:
    lw    s2, 16(sp)            # callee save
    lw    s3, 12(sp) 
    lw    s4, 8(sp)  
    lw    s5, 4(sp)  
    lw    s6, 0(sp)  
    addi  sp, sp, 20
    
    sub   t0, a3, a1
    addi  t0, t0, 1
    slli  t0, t0, 2
    add   sp, sp, t0

    lw    ra, 8(sp)
    lw    s0, 4(sp) 
    lw    s1, 0(sp) 
    addi  sp, sp, 12
    ret                         # end of merge

# ######################################


main_exit:

# ######################################
# ### Return to end the simulation
# ######################################

  lw s0, 0(sp)
  addi sp, sp, 4
  ret

# ######################################
