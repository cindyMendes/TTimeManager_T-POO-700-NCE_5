@echo off

REM Start Minikube with Docker driver
minikube stop
minikube start --driver=docker

REM Paths to Dockerfiles
SET FRONTEND_PATH=.\client
SET BACKEND_PATH=.\time_manager
SET K8S_CONFIG_PATH=.\kubernetes_deployment.yaml

REM Display current directory and files
echo Current directory: %CD%
dir

REM Build Docker images
echo Building Elixir image...
docker build -t elixir-app:latest %BACKEND_PATH%

echo Building Vue.js image...
docker build --build-arg API_URL=http://elixir-backend:4000 -t vuejs-app:latest %FRONTEND_PATH%


REM Set namespace for the deployments
@REM kubectl config set-context --current --namespace=time-manager

REM Install Nginx Ingress Controller
minikube addons enable ingress
kubectl apply -f time-manager-ingress.yaml

REM Start Minikube tunnel in a new command prompt window
start cmd /k "minikube tunnel"

REM Initiate Secret
kubectl apply -f secret.yaml

REM Initiate ConfigMap
kubectl apply -f config-map.yaml

REM Apply Kubernetes configuration
echo Applying Kubernetes configuration...
kubectl apply -f %K8S_CONFIG_PATH%

REM Wait for deployments to be ready
echo Waiting for PostgreSQL to be ready...
kubectl wait --for=condition=ready pod -l app=postgres

echo Waiting for Elixir backend to be ready...
kubectl wait --for=condition=ready pod -l app=elixir-backend

echo Waiting for Vue.js frontend to be ready...
kubectl wait --for=condition=ready pod -l app=vuejs-frontend

echo Deployment complete!

REM Print the IP address of the Minikube cluster
FOR /F "tokens=*" %%i IN ('minikube ip') DO SET minikubeIP=%%i
echo The IP address of the Minikube cluster is: %minikubeIP%

pause
