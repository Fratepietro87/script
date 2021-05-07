#!/bin/csh

#####################################
# Setta i corequisiti consegna DTM
#####################################
set cons_DTM_name = $1
set ver_cons = `echo $1 | awk '{print (substr($1,4,5))}'`
set sub_tsk = " FRM$ver_cons SQL$ver_cons SHE$ver_cons"
set coreq_DTM = "DTM40000,DTM4000A"
set coreq_x = ""

foreach prj ($sub_tsk)

 set coreq_DTM = "$coreq_DTM","$prj"

  foreach prk ($sub_tsk)
   
   if ($prk == $prj ) then
     echo "skip" $prk
   else
    set coreq_x = "$prk","$coreq_x"
   endif
  end
  echo "COREQUISITI "$prj":" $coreq_x$1
  set coreq_x = ""
end
 echo "COREQUISITI "$1":" $coreq_DTM

