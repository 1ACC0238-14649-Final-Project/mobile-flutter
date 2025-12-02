#!/bin/bash

# Script para generar el keystore de firma de producción
# Este script genera un keystore para firmar tu aplicación Android

echo "=========================================="
echo "Generador de Keystore para Android"
echo "=========================================="
echo ""

# Solicitar información
read -p "Nombre del alias (default: upload): " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-upload}

read -p "Nombre del archivo keystore (default: upload-keystore.jks): " KEYSTORE_NAME
KEYSTORE_NAME=${KEYSTORE_NAME:-upload-keystore.jks}

read -sp "Contraseña del keystore: " STORE_PASSWORD
echo ""

read -sp "Confirmar contraseña del keystore: " STORE_PASSWORD_CONFIRM
echo ""

if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
    echo "Error: Las contraseñas no coinciden"
    exit 1
fi

read -sp "Contraseña de la clave (puede ser la misma): " KEY_PASSWORD
echo ""

KEY_PASSWORD=${KEY_PASSWORD:-$STORE_PASSWORD}

# Ruta donde se guardará el keystore
KEYSTORE_PATH="$PWD/$KEYSTORE_NAME"

echo ""
echo "Generando keystore..."
echo "Ruta: $KEYSTORE_PATH"
echo "Alias: $KEY_ALIAS"
echo ""

# Generar el keystore
keytool -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias "$KEY_ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Gigu App, OU=Development, O=Gigu, L=City, ST=State, C=PE"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generado exitosamente!"
    echo ""
    echo "Ahora crea el archivo android/key.properties con el siguiente contenido:"
    echo ""
    echo "storePassword=$STORE_PASSWORD"
    echo "keyPassword=$KEY_PASSWORD"
    echo "keyAlias=$KEY_ALIAS"
    echo "storeFile=$KEYSTORE_PATH"
    echo ""
    echo "⚠️  IMPORTANTE:"
    echo "   - Guarda el keystore en un lugar seguro"
    echo "   - NO compartas el keystore ni las contraseñas"
    echo "   - Si pierdes el keystore, NO podrás actualizar tu app en Google Play"
    echo ""
else
    echo ""
    echo "❌ Error al generar el keystore"
    exit 1
fi

