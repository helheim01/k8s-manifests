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

## Pasos para Desplegar el Proyecto:

1) Abrir un CMD como administrador y crear la carpeta raiz en el Disco C para hacer todos los clone ahí dentro. Luego, entrar a ella:
    - mkdir taller-k8s-web
    - cd taller-k8s-web

2) Poner el siguiente comando para clonar el contenido web:
     - git clone https://github.com/helheim01/static-website

3) Poner el siguiente comando para clonar los archivos de configuración: 
    - git clone https://github.com/helheim01/k8s-manifests

4) Arrancar minikube con (¡Importante!: el comando minikube mount debe quedar activo en esa consola. No la cierres ni interrumpas): 
    - minikube start
    - minikube mount C:/taller-k8s-web/static-website:/mnt/web
  
5) En una consola aparte (sin quitar la que ya tenías), ejecutar:
    - cd C:/taller-k8s-web/k8s-manifests
    - kubectl apply -f volume/pv.yaml
    - kubectl apply -f volume/pvc.yaml
    - kubectl apply -f deployment/web-deployment.yaml
    - kubectl apply -f deployment/web-deployment-direct.yaml
    - kubectl apply -f service/web-service.yaml

6) En la misna consola que usaste para el paso 5, ejecutar el siguiente comando para abrir el index en el navegador (Nota: Luego de aplicar este comando, se te dará una URL que puedes copiar y pegar en tu navegador; o puedes esperar un minuto, y volver a ejecutarlo para que lo haga de manera automática): 
    - minikube service web-service


7) (Opcional) Si queres hacer una comprobación del estado, para verificar que todos los recursos estén corriendo correctamente, usa estos comandos (En la segunda consola, la misma del paso 5 y 6):
    - kubectl get all
    - kubectl logs -l app=web

8) (Opcional) Detener el Entorno ((En la segunda consola, la misma del paso 5, 6 y 7)
    - minikube stop
    - minikube delete
