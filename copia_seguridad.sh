#!/bin/sh   

#Script que genera una copia de seguridad                                                                              

cd /home/ubuntu                                                                                                                                                                                                                                

#Obtenemos la fecha y lo formateamos                                                                                    

CURRENTDATE=`date +"%d_%m_%Y"`                                                                                                                                                                                                                  

#Obtenemos los puntos de montaje de los volumenes CS1 y CS2                                                            

MOUNTPOINT1=$(sudo cat /proc/mounts | grep '/dev/vd.1' | tail -n 2 | awk -F '[[:space:]]+'  '{ print $2 }' | head -n 1)

MOUNTPOINT2=$(sudo cat /proc/mounts | grep '/dev/vd.1' | tail -n 2 | awk -F '[[:space:]]+'  '{ print $2 }' | tail -n 1)                                                                                                                        

#Obtenemos el nombre de la copia de seguridad y a que directorio hara la copia de seguridad                            

COPY=copia-pmm477-${CURRENTDATE}.tar.gz                                                                                

DIRECTORY=/home/                                                                                                        

tar czvf ${COPY} ${DIRECTORY}                                                                                                                                                                                                                  

#Obtenemos los bytes de la copia de seguridad y el espacio disponible del volumen (en KIBIBYTES)                        

BYTESCOPY=$(wc -c ${COPY} | awk -F '[[:space:]]+' '{ print $1 }')                                                      

VOLUMECAPACITY=$(df | grep '/dev/vd.1' | tail -n 1 | awk -F '[[:space:]]+' '{ print $4 }')                                                                                                                                                      

#Transformamos de BYTES a KIBIBYTES, el comando df utiliza bases de 2^10                                                

KIBIBYTESCOPY=$(((${BYTESCOPY}/1024)+1))                                                                                                                                                                                                        

#Comprobamos si la copia de seguridad supera el espacio disponible del volumen, hacemos solo 1 comprobacion ya que los >

#son replica del otro                                                                                                  

if [ $KIBIBYTESCOPY -gt $VOLUMECAPACITY ] ; then    

        #Si no hay suficiente espacio, se elimina la copia de seguridad mas antigua en cada volumen                            

        sudo rm $(ls ${MOUNTPOINT1}/copia-* | head -n 1)                                                                        

        sudo rm $(ls ${MOUNTPOINT2}/copia-* | head -n 1)                                                                

fi                                                                                                                                                                                                                                              

#Realizamos la transferencia de la copia de seguridad a los dos volumenes                                              

sudo cp ${COPY} ${MOUNTPOINT1}                                                                                          

sudo cp ${COPY} ${MOUNTPOINT2}                                                                                                                                                                                                                  

#Eliminamos la copia de seguridad del directorio /home/ubuntu                                                          

sudo rm ${COPY} 
