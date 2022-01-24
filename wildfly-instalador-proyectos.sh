#!/usr/bin/sh


# ============================================================================ #
# VERSION 1.0                                                                  #
# ---------------------------------------------------------------------------- #
# Creado por          : Juan Valenzuela Canto                                  #
# Modificado por      :                                                        #
# Version 1.0.0       : 02-02-2021.                                            #
# ============================================================================ #
# Descripcion : instala componentes de WILDFLY  #


#-----------------------------------------------------------------------------
# Decalaracion variables de tiempo real
FECHA_HORA_LOG=$(date +%d-%m-%Y-%H_%M_%S)
PROCESS_ID="wildfly-instala-componentes"
DIRECTORIO_WILDFLY="wildfly-preview-22.0.0.Final"

#-----------------------------------------------------------------------------
# Decalaracion de directorios y archivos base
#-----------------------------------------------------------------------------

export XPP_HOME=~/instaladorWildfly
export XPP_KSH=$XPP_HOME/sh
export XPP_LOG=$XPP_HOME/log

#######
# DIRECTORIO DE WILDFLY



export XPP_JBOSS_CLI=/opt/$DIRECTORIO_WILDFLY/bin/jboss-cli.sh


# Archivo de LOG
LOG_FILE="$XPP_LOG/${PROCESS_ID}_${FECHA_HORA_LOG}.log"

# Archivo WAR (input)
WAR="$1"
DIR_FECHA="$2"
REPOSITORY="$3"

export XPP_COMPILADOS=~/COMPILADOS
export XPP_WARS=$XPP_COMPILADOS/$REPOSITORY #  UBICACION DE WARS EN JBOSS

#-----------------------------------------------------------------------------
################## VARIABLES GLOBALES
#-----------------------------------------------------------------------------

JBOSS_CLI_CHECK_DEPLOYMENT=$($XPP_JBOSS_CLI --connect --commands=ls\ deployment | grep -w $WAR)
JBOSS_CLI_UNDEPLOY=$($XPP_JBOSS_CLI --connect --commands=undeploy\ $WAR)
JBOSS_CLI_DEPLOY=$($XPP_JBOSS_CLI --connect --commands=deploy\ $XPP_WARS/$DIR_FECHA/$WAR)
JBOSS_CLI_STATUS="systemctl --user is-active --quiet wildfly.service"

JBOSS_CLI_DISABLE=$($XPP_JBOSS_CLI --connect --commands=undeploy\ --keep-content\ $WAR)
JBOSS_CLI_ENABLE=$($XPP_JBOSS_CLI --connect --commands=deploy\ --name=$WAR)


# Expresión regular para validar formato de archivos
# Anadir otro formato dentro del parentesis escribiendo "|formato" EJ: (war|jar|ear|gz) 
REGEX_FILE_FORMAT='\.(war|jar|ear)$'


#-----------------------------------------------------------------------------
################### Diferenciacion para casos con Properties

#MATCH_TWO=$(echo $REPO_CHANGES | grep -P '^(?=.*Fuentes)(?=.*Properties)')
#MATCH_FUENTES=$(echo $REPO_CHANGES | grep -e "Fuentes" )
#MATCH_PROPERTIES=$(echo $REPO_CHANGES | grep -e "Properties")

#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
################# FIN VARIABLES GLOBALES
#-----------------------------------------------------------------------------

#-----------------------------------------------------------------------------
# DECLARACIÓN DE FUNCIONES
#-----------------------------------------------------------------------------


WriteLOG()
{
    FECHA_HORA_LOG=$(date +[%d/%m/%Y][%X])
    echo "EVENTO $FECHA_HORA_LOG: "$1 >> $LOG_FILE
}
CheckDirectory(){
    if [[ -d $XPP_COMPILADOS ]];then
        WriteLOG "(info): directorio COMPILADOS existe"
    else
        WriteLOG "(info): directorio COMPILADOS no existe"
        WriteLOG "(info): creando directorio...."
        mkdir ~/COMPILADOS
    fi
}

CheckFile(){
    if [[ -f $XPP_WARS/$DIR_FECHA/$WAR ]];then
        WriteLOG "(info): archivo $WAR existe"
    else
        WriteLOG "(info): archivo $WAR no existe"
        exit 1
    fi

    
}

CheckFileFormat(){
    if [[ $WAR =~ $REGEX_FILE_FORMAT ]];then
        WriteLOG "(info): formato permitido"
    else
        WriteLOG "(ERROR): Formato de archivo no permitido"
        exit 1
    fi

}
<<properties
CheckPropertiesExists(){
    WriteLOG "(info): verificando propertie "
    for propertie in $PROPERTIES_FILES
    do
        if [[ -f $XPP_JBOSS_PROPERTIES/$propertie ]];then
            WriteLOG "(info): propertie $propertie existe"
            cp $XPP_JBOSS_PROPERTIES/$propertie $XPP_JBOSS_PROPERTIES/$propertie.${FECHA_HORA_PROPERTIES}
            cp $XPP_WARS/$DIR_FECHA/$PROPERTIES/$propertie $XPP_JBOSS_PROPERTIES
        else
            WriteLOG "(info): propertie $propertie no existe"
            cp $XPP_WARS/$DIR_FECHA/$PROPERTIES/$propertie $XPP_JBOSS_PROPERTIES
        fi
    done   
}
CheckPropertiesInstalled(){
    WriteLOG "(info): verificando propertie "
    for propertie in $PROPERTIES_FILES
    do
        if [[ -f $XPP_JBOSS_PROPERTIES/$propertie ]];then
            WriteLOG "(info): propertie $propertie ya esta instalado"
        else
            WriteLOG "(info): propertie $propertie no esta instalado"
            cp $XPP_WARS/$DIR_FECHA/$PROPERTIES/$propertie $XPP_JBOSS_PROPERTIES
        fi
    done   
}
properties

CheckJbossConnection(){
    if $JBOSS_CLI_STATUS;then
        WriteLOG "(info): conexion con JBOSS exitosa"
    else
        WriteLOG "(ERROR): no hay conexion con jboss"
        exit 1
    fi 

}
<<com
ReloadDeployment(){
    WriteLOG "(info): desactivando deployment "
    if  $JBOSS_CLI_DISABLE  ; then 
        WriteLOG "(info): desactivacion de $WAR exitosa "
    else
        WriteLOG "(ERROR): Error en la desactivacion de $WAR "
        exit 1
    fi 

    WriteLOG "(info): reactivando deployment $JBOSS_CLI_ENABLE"
     if  $JBOSS_CLI_DISABLE ; then 
        WriteLOG "(info): reactivacion de $WAR exitosa "
    else
        WriteLOG "(ERROR): Error en la reactivacion de $WAR "
        exit 1
    fi 

}
com

UninstallWar(){
    if [[ $JBOSS_CLI_CHECK_DEPLOYMENT ]]; then

        WriteLOG "(info): El servicio $WAR se encuentra instalado"
        WriteLOG "(info): desintalando servicio..."

        if $JBOSS_CLI_UNDEPLOY ; then 
            WriteLOG "(info): Desintalacion exitosa "
        else
            WriteLOG "(info): Error en la desintalacion  "
            exit 1
        fi 

    else
        WriteLOG "(info): El servicio $WAR no se encuentra instalado"
    fi

    
    
}
CheckWarInstalled(){
    if [[ $JBOSS_CLI_CHECK_DEPLOYMENT ]]; then

        WriteLOG "(info): El servicio $WAR se encuentra instalado"
        UninstallWar
        InstallWar
    else
        WriteLOG "(info): El servicio $WAR no se encuentra instalado"
        InstallWar
    fi

    
    
}

InstallWar(){
    WriteLOG "(info): instalando $WAR "
    if  $JBOSS_CLI_DEPLOY ; then 
        WriteLOG "(info): instalacion de $WAR exitosa "
    else
        WriteLOG "(ERROR): Error en la intalacion de $WAR "
        exit 1
    fi 
}

## Flujo de ejecucion

# Paso 1 : Verifica si existe directorio COMPILADOS
CheckDirectory 

# Paso 2: Verifica que exista el war enviado desde jenkins
CheckFile
# Paso 3: Verifica formato de archivos permitidos (.war, .jar, .ear)
CheckFileFormat

CheckJbossConnection

# Paso 4: Chequea si el war se encuentra instalado
CheckWarInstalled




#ReloadDeployment
# desactiva y vuelve a activar el War en deployment
