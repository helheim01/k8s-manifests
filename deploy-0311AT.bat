@echo off

REM Crear carpeta raíz
set ROOT_FOLDER=C:\taller-k8s-web
if not exist "%ROOT_FOLDER%" (
    echo Creando carpeta raiz %ROOT_FOLDER%...
    mkdir "%ROOT_FOLDER%"
) else (
    echo Ya existe el subdirectorio o el archivo %ROOT_FOLDER%.
)

cd /d "%ROOT_FOLDER%"

REM Eliminar repositorios si existen
if exist "static-website" (
    echo El repositorio static-website ya existe, eliminando...
    rmdir /s /q static-website
)

if exist "k8s-manifests" (
    echo El repositorio k8s-manifests ya existe, eliminando...
    rmdir /s /q k8s-manifests
)

REM Clonar los repositorios
echo Clonando repositorio static-website...
git clone https://github.com/helheim01/static-website

echo Clonando repositorio k8s-manifests...
git clone https://github.com/helheim01/k8s-manifests

REM Iniciar Minikube
echo Iniciando Minikube...
minikube start

REM Esperar que Minikube esté listo
echo Esperando a que Minikube y mount esten listos...
timeout /t 20

REM Aplicar los manifiestos de Kubernetes
cd k8s-manifests

kubectl apply -f volume/pv.yaml
kubectl apply -f volume/pvc.yaml
kubectl apply -f deployment/web-deployment.yaml
kubectl apply -f deployment/web-deployment-direct.yaml
kubectl apply -f service/web-service.yaml

cd ..

REM Montar la carpeta de la web estática
minikube mount "%ROOT_FOLDER%\static-website":/mnt/web

REM Esperar un momento para asegurar que el montaje esté listo
timeout /t 10

REM Ejecutar el comando para abrir el servicio web automáticamente
minikube service web-service --url

REM Mostrar el estado de los recursos
echo ---
echo Si queres ver el estado de los recursos, podes correr estos comandos manualmente:
echo kubectl get all
echo kubectl logs -l app=web
echo ---
echo Para detener el entorno mas tarde, podes usar:
echo minikube stop
echo minikube delete

pause
