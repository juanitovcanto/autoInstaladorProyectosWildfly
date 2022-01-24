# Instalador de Proyectos WILDFLY / JBOSS

Shell script que permite instalar proyectos java compilados (WAR,JAR,EAR) en el servidor de aplicaciones instalado en el mismo sistema.

## Prerequisitos

* Wildfly instalado (cualquier versión) en /opt/ (puede cambiar dirección en el código)
* Crear en directorio de usuario ~ el directorio ~/instaladorWildfly/log para logs y ~/instaladorWildfly/sh donde estará el shell script



## Ejecución

Su uso está pensado para recibir los proyectos compilados desde alguna aplicación de despliegue como Jenkins con los siguientes parametros:

sh wildfly-instalador-proyectos.sh _NombreProyectoCompilado.war_ _FechaDeCompilacion_ _NombreRepositorio_



