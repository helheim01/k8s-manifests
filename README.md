# Proyecto 0311AT: Sitio Web Estatico con NGINX en Minikube

Este repositorio tiene los **manifiestos de Kubernetes**  para desplegar un **sitio web estatico** usando un contenedor **NGINX**, almacenamiento **persistente** y un **servicio NodePort**, todo en un entorno **local** con **Minikube**.

---

## Requisitos Previos

Tener instalado en tu maquina local:

- Cuenta en GitHub
- [Git] – Para clonar los repositorios
- [Docker] – Para usar como driver en Minikube
- [Minikube]
- [kubectl]
- Editor de texto como [VS Code]
- Conexión a internet activa

---

## Pasos para Desplegar el Proyecto

1) Abrir un CMD como administrador y crear la carpeta raiz en el Disco C para hacer todos los clone ahí dentro. Luego, entrar a ella:
    - mkdir taller-k8s-web
    - cd taller-k8s-web

2) Poner el siguiente comando para clonar el contenido web:
     - git clone https://github.com/helheim01/static-website

3) Poner el siguiente comando para clonar los archivos de configuración: 
    - git clone https://github.com/helheim01/k8s-manifests

4) Arrancar minikube con: 
    - minikube start

5) En una consola aparte (sin quitar la que ya tenías), ejecutar: 
    - minikube mount C:/taller-k8s-web/static-website:/mnt/web
      Este comando mantiene la conexión activa para sincronizar el contenido del sitio con el volumen de Minikube.

6) Moverse a la carpeta "k8s-manifests" para poder aplicar los manifiestos:
    - cd k8s-manifests
    - kubectl apply -f volume/pv.yaml
    - kubectl apply -f volume/pvc.yaml
    - kubectl apply -f deployment/web-deployment.yaml
    - kubectl apply -f deployment/web-deployment-direct.yaml
    - kubectl apply -f service/web-service.yaml

7) Una vez aplicados, ejecutar el siguiente comando para abrir el index en el navegador: 
    - minikube service web-service


8) (Opcional) Si queres hacer una comprobación del estado, para verificar que todos los recursos estén corriendo correctamente, usa estos comandos :
    - kubectl get all
    - kubectl logs -l app=web

9) (Opcional) Detener el Entorno
    - minikube stop
    - minikube delete
