# Instalador de Proyectos WILDFLY / JBOSS

Shell script que permite instalar proyectos java compilados (WAR,JAR,EAR) en el servidor de aplicaciones Wildfly o JBOSS instalado en el mismo sistema.

## Prerequisitos

* Wildfly instalado (cualquier versión) en /opt/ (puede cambiar dirección en el código)
* Crear en directorio de usuario ~ el directorio ~/instaladorWildfly/log para logs y ~/instaladorWildfly/sh donde estará el shell script
* Parametro DIRECTORIO_WILDFLY debe modificarse con el nombre del directorio de wildfly o JBOSS que tenga instalado



## Ejecución

Su uso está pensado para recibir los proyectos compilados desde alguna aplicación de despliegue como Jenkins con los siguientes parametros:

sh wildfly-instalador-proyectos.sh _NombreProyectoCompilado.war_ _FechaDeCompilacion_ _NombreRepositorio_

## Nota

La funcion que verifica el estado del servidor Wildfly supone que ejecuto como un daemon local de un usuario con Systemd. En caso de haberse ejecutado como root debe sacar "--user" en la variable JBOSS_CLI_STATUS quedando así:

```Shell
JBOSS_CLI_STATUS="systemctl is-active --quiet wildfly.service"
```
En caso de usar jboss , cambiar el wildfly.service por el nombre correspondiente
