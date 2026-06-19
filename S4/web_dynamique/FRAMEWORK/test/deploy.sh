#!/bin/bash

# Quitter immédiatement si une commande échoue
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# =========================
# CONFIGURATION CORRIGÉE
# =========================
APP_NAME="framework"
SRC_DIR="src/main/java"
WEBAPP_DIR="src/main/webapp" 
BUILD_DIR="build"
FRAMEWORK_DIR="../framework"
FRAMEWORK_JAR="$FRAMEWORK_DIR/build/jar/framework.jar"
SERVLET_API_JAR="lib/servlet-api.jar"
DEPLOY_DIR="/var/lib/tomcat10/webapps"
APP_DIR="$DEPLOY_DIR/test"

# Tes chemins Tomcat système

echo "===== BUILD FRAMEWORK JAR ====="
rm -rf "$FRAMEWORK_DIR/build/classes" "$FRAMEWORK_DIR/build/jar" "$FRAMEWORK_JAR"
mkdir -p "$FRAMEWORK_DIR/build/classes"
mkdir -p "$FRAMEWORK_DIR/build/jar"
find "$FRAMEWORK_DIR" -name "*.java" ! -path "*/.git/*" ! -path "*/build/*" > "$FRAMEWORK_DIR/sources.txt"
javac -cp "$SERVLET_API_JAR" -d "$FRAMEWORK_DIR/build/classes" @"$FRAMEWORK_DIR/sources.txt"
rm "$FRAMEWORK_DIR/sources.txt"
jar cvf "$FRAMEWORK_JAR" -C "$FRAMEWORK_DIR/build/classes" .

echo "===== CLEAN BUILD ====="
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/classes"

echo "===== COMPILATION JAVA ====="
if [ ! -d "$SRC_DIR" ]; then
  echo "❌ ERREUR: Dossier source $SRC_DIR introuvable."
  exit 1
fi

find "$SRC_DIR" -name "*.java" ! -path "$SRC_DIR/FrontControllerServlet.java" ! -path "$SRC_DIR/BaseController.java" ! -path "$SRC_DIR/Mapping.java" > sources.txt

if [ ! -s sources.txt ]; then
  echo "❌ ERREUR: Aucun fichier .java trouvé dans $SRC_DIR"
  rm sources.txt
  exit 1
fi

# Compile avec l'API Servlet Jakarta fournie localement.
echo "[INFO] Compilation des classes..."
javac -cp "$SERVLET_API_JAR:$FRAMEWORK_JAR" -d "$BUILD_DIR/classes" @sources.txt
rm sources.txt

echo "===== DEPLOY WEBAPP DANS TOMCAT SYSTEME ====="

# 1. Vérification que le dossier webapps de Tomcat existe
if [ ! -d "$DEPLOY_DIR" ]; then
  echo "❌ ERREUR: Le dossier de déploiement Tomcat est introuvable: $DEPLOY_DIR"
  exit 1
fi

# 2. Nettoyage de l'ancien dossier dans Tomcat (nécessite souvent sudo)
echo "[INFO] Nettoyage de l'ancien déploiement..."
if [ -w "$DEPLOY_DIR" ]; then
  rm -rf "$APP_DIR"
  mkdir -p "$APP_DIR/WEB-INF/lib"
else
  sudo rm -rf "$APP_DIR"
  sudo mkdir -p "$APP_DIR/WEB-INF/lib"
fi

# 3. Copie des fichiers Web (JSP, web.xml) et des classes compilées vers Tomcat...
if [ -d "$WEBAPP_DIR" ]; then
  echo "[INFO] Copie des fichiers Web (JSP, ressources...) vers Tomcat..."
  if [ -w "$DEPLOY_DIR" ]; then
    cp -r "$WEBAPP_DIR"/* "$APP_DIR/"
  else
    sudo cp -r "$WEBAPP_DIR"/* "$APP_DIR/"
  fi
else
  echo "⚠️ ATTENTION: Dossier local $WEBAPP_DIR introuvable. Création d'une structure vide."
fi

if [ -w "$APP_DIR/WEB-INF" ]; then
  mkdir -p "$APP_DIR/WEB-INF/classes"
  cp -r "$BUILD_DIR/classes/." "$APP_DIR/WEB-INF/classes/"
else
  sudo mkdir -p "$APP_DIR/WEB-INF/classes"
  sudo cp -r "$BUILD_DIR/classes/." "$APP_DIR/WEB-INF/classes/"
fi

# 4. Injection de ton framework.jar dans le dossier lib de l'application Tomcat
echo "[INFO] Injection de framework.jar dans la Webapp Tomcat..."
if [ -w "$APP_DIR/WEB-INF/lib" ]; then
  cp "$FRAMEWORK_JAR" "$APP_DIR/WEB-INF/lib/framework.jar"
else
  sudo mkdir -p "$APP_DIR/WEB-INF/lib"
  sudo cp "$FRAMEWORK_JAR" "$APP_DIR/WEB-INF/lib/framework.jar"
fi

echo "===== DEPLOY DONE ====="
echo "URL de ton framework de test: http://localhost:8080/test/"