# Proyecto Kubernetes: Sitio Web Estatico con NGINX en Minikube

Este repositorio contiene los **manifiestos de Kubernetes** necesarios para desplegar un **sitio web estatico** utilizando un contenedor **NGINX**, almacenamiento **persistente** y un **servicio NodePort**, todo en un entorno **local** con **Minikube**.

---

## Requisitos Previos

Asegurate de tener instalado en tu msquina local:

- [Git](https://git-scm.com/) – Para clonar los repositorios
- [Docker](https://www.docker.com/) – Para usar como driver en Minikube
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- Editor de texto como [VS Code](https://code.visualstudio.com/)
- Conexión a internet activa

---

## Estructura del Proyecto

- Crea las carpetas, para hacer todos los clone ahí dentro:
    - mkdir taller-k8s-web
    Dentro de la carpeta anterior, crear estas 2
        - mkdir web-content
        - mkdir k8s-manifests


## Pasos para Desplegar el Proyecto

1) Movete a la carpeta de "web-content" y pon el siguiente comando para clonar el contenido web:
     - git clone https://github.com/helheim01/static-website

2) Movete a la carpeta de "k8s-manifests" y pon el siguiente comando para clonar los archivos de configuración: 
    - git clone https://github.com/helheim01/k8s-manifests

3) Arrancar minikube con: 
    - minikube start

4) En una consola aparte (sin quitar la que ya tenías), ejecutar: 
    - minikube mount minikube mount /ruta/local/taller-k8s-web/web-content:/mnt/web (Importante: Reemplazá "/ruta/local/taller-k8s-web/web-content" por el path donde clonaste "web-content".)
    - Este comando mantiene la conexión activa para sincronizar el contenido del sitio con el volumen de Minikube.

5) Moverse a la carpeta "k8s-manifests" para poder aplicar los manifiestos:
    - kubectl apply -f volume/pv.yaml
    - kubectl apply -f volume/pvc.yaml
    - kubectl apply -f deployment/web-deployment.yaml
    - kubectl apply -f deployment/web-deployment-direct.yaml
    - kubectl apply -f service/web-service.yaml

    -Nota: Estos comandos aplican la configuración a tu clúster local. No afectan el contenido de los repositorios, por lo que no es necesario hacer commits o pushes después de este paso.

6) Una vez aplicados, ejecutar el siguiente comando para abrir el index en tu navegador: 
    - minikube service web-service

7) Hacer cambios en el Sitio Web (Opcional)
    - Si querés modificar el contenido del sitio (por ejemplo, cambiar el archivo index.html), seguí estos pasos:
    - Editá los archivos dentro de la carpeta "web-content".
    - Al estar usando un volumen montado con minikube mount, los cambios se reflejan directamente sin necesidad de reconstruir el contenedor (Solo tenes que recargar la página en el navegador para ver los cambios).
    - Recuerda: Durante todo este proceso, tenes que mantener la terminal con minikube mount activa.

8) Si queres hacer una comprobación del estado, para verificar que todos los recursos estén corriendo correctamente, usa estos comandos:
    - kubectl get all
    - kubectl logs -l app=web

9) (Opcional) Detener el Entorno
    - minikube stop
    - minikube delete
