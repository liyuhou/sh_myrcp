#! /bin/bash

cpf2f()
{
    if [ ! -e $1 ];then
        echo no such source file $1
        return 1
    fi
    if [ $1 -ef $2 ];then
        echo never copy a file to itself
        return 1
    fi
    if [ -L $1 ];then #symbolic link
        echo copy symlink $1
        link=$(readlink $1)
        ln -s $link $2
        return 0
    fi
    echo copy file $1 to $2
    cp $1 $2 2> /dev/null
}

cpf2d()
{
    newfile=$2/$(basename $1)
    cpf2f $1 $newfile
    RET=$?
    return $RET
}

cpd2d()
{
    if [ -e $2 ];then
        newDir=$2/$(basename $1)
        mkdir $newDir
        for ITEM in $(ls $1)
            do
                origin=$1/$ITEM
                target=$newDir/$ITEM
                if [ -f $origin ];then
                    cpf2d $origin $newDir
                else 
                    cpd2d $origin $target
                fi
            done
    else
        mkdir $2
        for ITEM in $(ls $1)
            do
                origin=$1/$ITEM
                target=$2/$ITEM
                if [ -f $origin ];then
                    cpf2d $origin $2
                else 
                    cpd2d $origin $target
                fi
            done
    fi

}
# ************ entry point ***************
n=$#
echo $*
echo n = $n
eval last=\${$n}         #only eval can work, can't use "last=${$n}}"
echo last = $last
if [ ${n} -lt 2 ];then
    echo number of arg must be greater than 1
    exit 1
elif [ ${n} -eq 2 ];then
    if [ -f $1 ];then
        if [ ! -e $2 ];then
            cpf2f $1 $2
        elif [ -f $2 ];then
            cpf2f $1 $2
        elif [ -d $2 ];then
            cpf2d $1 $2
        fi
    elif [ -d $1 ];then
        cpd2d $1 $2
    else   
        echo dir can\'t copy to file
    fi
else
    if [ ! -d $last ];then
        echo when n \> 2, last arg must be dir
        exit 1
    else
        I=1
        while [ $I -lt ${n} ]
            do
                eval NAME=\${$I}
                echo NAME = $NAME
                if [ -f $NAME ];then
                    cpf2d $NAME $last
                elif [ -d $NAME ];then
                    cpd2d $NAME $last
                else
                    echo parseArg wrong
                fi
                I=`expr $I + 1`
            done
    fi
fi

