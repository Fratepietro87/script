#!/bin/ksh

#Direcotory di LOG
LOG=`pwd`/uniscitemplate.log

#Pulisce il LOG
cat /dev/null > $LOG

#==============================================================================================

for FILE in `ls *.*.* 2>/dev/null`

do

   if [ -d "$FILE" ] ;
        then
          echo "$FILE e una directory - Niente da fare" >> $LOG

        else

        echo "" >> $LOG

        case $FILE in
          *.*.A)
        echo "Il file $FILE e da Mettere nel File A" >> $LOG
        cat $FILE >> OPER.CLONE.A
        ;;
        *.*.B)
        echo "Il file $FILE e da Mettere nel File B" >> $LOG
        cat $FILE >> OPER.CLONE.B
        ;;
        *.*.B0)
        echo "Il file $FILE e da Mettere nel File B0" >> $LOG
        cat $FILE >> OPER.CLONE.B0
        ;;
        *.*.C)
        echo "Il file $FILE e da Mettere nel File C" >> $LOG
        cat $FILE >> OPER.CLONE.C
        ;;
        *.*.C0)
        echo "Il file $FILE e da Mettere nel File C0" >> $LOG
        cat $FILE >> OPER.CLONE.C0
        ;;
        *.*.DC)
        echo "Il file $FILE e da Mettere nel File D" >> $LOG
        cat $FILE >> OPER.CLONE.DC
        ;;
        *.*.E)
        echo "Il file $FILE e da Mettere nel File E" >> $LOG
        cat $FILE >> OPER.CLONE.E
        ;;
        *.*.FC)
        echo "Il file $FILE e da Mettere nel File F" >> $LOG
        cat $FILE >> OPER.CLONE.FC
        ;;
        *.*.H)
        echo "Il file $FILE e da Mettere nel File H" >> $LOG
        cat $FILE >> OPER.CLONE.H
        ;;
        *.*.H0)
        echo "Il file $FILE e da Mettere nel File H0" >> $LOG
        cat $FILE >> OPER.CLONE.H0
        ;;
        *.*.I)
        echo "Il file $FILE e da Mettere nel File I" >> $LOG
        cat $FILE >> OPER.CLONE.I
        ;;
        *.*.J)
        echo "Il file $FILE e da Mettere nel File J" >> $LOG
        cat $FILE >> OPER.CLONE.J
        ;;
        *.*.K)
        echo "Il file $FILE e da Mettere nel File K" >> $LOG
        cat $FILE >> OPER.CLONE.K
        ;;
        *.*.L)
        echo "Il file $FILE e da Mettere nel File L" >> $LOG
        cat $FILE >> OPER.CLONE.L
        ;;
        *.*.M)
        echo "Il file $FILE e da Mettere nel File M" >> $LOG
        cat $FILE >> OPER.CLONE.M
        ;;
        *.*.N)
        echo "Il file $FILE e da Mettere nel File N" >> $LOG
        cat $FILE >> OPER.CLONE.N
        ;;
        *.*.O)
        echo "Il file $FILE e da Mettere nel File O" >> $LOG
        cat $FILE >> OPER.CLONE.O
        ;;
        *.*.P)
        echo "Il file $FILE e da Mettere nel File P" >> $LOG
        cat $FILE >> OPER.CLONE.P
        ;;
        *.*.QC)
        echo "Il file $FILE e da Mettere nel File Q" >> $LOG
        cat $FILE >> OPER.CLONE.QC
        ;;
        *.*.Q0)
        echo "Il file $FILE e da Mettere nel File Q0" >> $LOG
        cat $FILE >> OPER.CLONE.Q0
        ;;
        *.*.R)
        echo "Il file $FILE e da Mettere nel File R" >> $LOG
        cat $FILE >> OPER.CLONE.R
        ;;
        *.*.S)
        echo "Il file $FILE e da Mettere nel File S" >> $LOG
        cat $FILE >> OPER.CLONE.S
        ;;
        *.*.T)
        echo "Il file $FILE e da Mettere nel File T" >> $LOG
        cat $FILE >> OPER.CLONE.T
        ;;
        *.*.T0)
        echo "Il file $FILE e da Mettere nel File T0" >> $LOG
        cat $FILE >> OPER.CLONE.T0
        ;;
        *.*.U)
        echo "Il file $FILE e da Mettere nel File U" >> $LOG
        cat $FILE >> OPER.CLONE.U
        ;;
        *.*.V)
        echo "Il file $FILE e da Mettere nel File V" >> $LOG
        cat $FILE >> OPER.CLONE.V
        ;;
        *.*.X)
        echo "Il file $FILE e da Mettere nel File X" >> $LOG
        cat $FILE >> OPER.CLONE.X
        ;;
        *.*.YC)
        echo "Il file $FILE e da Mettere nel File Y" >> $LOG
        cat $FILE >> OPER.CLONE.YC
        ;;
        *.*.ZC)
        echo "Il file $FILE e da Mettere nel File Z" >> $LOG
        cat $FILE >> OPER.CLONE.ZC
        ;;
        *)
        echo "Il file $FILE non ha la lettera del clone come Estensione - Niente da fare" >> $LOG
        ;;

        esac
  fi

done
